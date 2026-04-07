import Foundation
import IOKit
import IOKit.hid

protocol AccelerometerReaderDelegate: AnyObject {
    func accelerometerReader(_ reader: AccelerometerReader, didReceiveSample sample: AccelerometerSample)
}

final class AccelerometerReader {
    // Apple Silicon MacBook accelerometer constants
    private static let sensorUsagePage: Int = 0xFF00
    private static let sensorUsage: Int = 3
    private static let reportLength: Int = 22
    private static let xOffset: Int = 6
    private static let yOffset: Int = 10
    private static let zOffset: Int = 14
    private static let rawToGForce: Double = 65536.0

    weak var delegate: AccelerometerReaderDelegate?

    private var manager: IOHIDManager?
    private var device: IOHIDDevice?
    private var reportBuffer: UnsafeMutablePointer<UInt8>?
    private var isRunning = false

    var isConnected: Bool { device != nil && isRunning }

    func start() -> Bool {
        guard !isRunning else { return true }

        // Create HID Manager
        let mgr = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        manager = mgr

        // Set matching dictionary for the accelerometer
        let matching: [String: Any] = [
            kIOHIDPrimaryUsagePageKey as String: AccelerometerReader.sensorUsagePage,
            kIOHIDPrimaryUsageKey as String: AccelerometerReader.sensorUsage
        ]
        IOHIDManagerSetDeviceMatching(mgr, matching as CFDictionary)

        // Schedule on main run loop
        IOHIDManagerScheduleWithRunLoop(mgr, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)

        // Open the manager (requires root)
        let openResult = IOHIDManagerOpen(mgr, IOOptionBits(kIOHIDOptionsTypeNone))
        if openResult != kIOReturnSuccess {
            print("[SlapSound] IOHIDManagerOpen failed with: \(openResult). Are you running with sudo?")
            stop()
            return false
        }

        // Find the accelerometer device
        guard let deviceSet = IOHIDManagerCopyDevices(mgr) as? Set<IOHIDDevice> else {
            print("[SlapSound] No HID devices matched. Your Mac may not have an accelerometer.")
            stop()
            return false
        }

        // Find the Apple accelerometer (vendor 0x05AC, report size 22)
        let accelDevice = deviceSet.first { dev in
            let vendorID = IOHIDDeviceGetProperty(dev, kIOHIDVendorIDKey as CFString) as? Int
            let reportSize = IOHIDDeviceGetProperty(dev, kIOHIDMaxInputReportSizeKey as CFString) as? Int
            return vendorID == 0x05AC && reportSize == AccelerometerReader.reportLength
        }

        if let foundDevice = accelDevice {
            device = foundDevice
        } else if let fallbackDevice = deviceSet.first {
            print("[SlapSound] Using fallback HID device (not Apple 0x05AC with 22-byte reports)")
            device = fallbackDevice
        } else {
            print("[SlapSound] No accelerometer found. This Mac may not have one (requires M1 Pro+ MacBook).")
            stop()
            return false
        }

        print("[SlapSound] Accelerometer connected!")

        // Allocate report buffer
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
        buffer.initialize(repeating: 0, count: 64)
        reportBuffer = buffer

        // Register input report callback
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        IOHIDDeviceRegisterInputReportCallback(
            device!,
            buffer,
            64,
            accelerometerReportCallback,
            selfPtr
        )

        isRunning = true
        return true
    }

    func stop() {
        isRunning = false

        if let dev = device {
            IOHIDDeviceRegisterInputReportCallback(dev, reportBuffer!, 64, nil, nil)
        }

        if let mgr = manager {
            IOHIDManagerClose(mgr, IOOptionBits(kIOHIDOptionsTypeNone))
            IOHIDManagerUnscheduleFromRunLoop(mgr, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        }

        reportBuffer?.deallocate()
        reportBuffer = nil
        device = nil
        manager = nil
    }

    fileprivate func handleReport(_ report: UnsafePointer<UInt8>, length: CFIndex) {
        guard length >= AccelerometerReader.reportLength else { return }

        let x = readInt32LE(report, offset: AccelerometerReader.xOffset)
        let y = readInt32LE(report, offset: AccelerometerReader.yOffset)
        let z = readInt32LE(report, offset: AccelerometerReader.zOffset)

        let sample = AccelerometerSample(
            x: Double(x) / AccelerometerReader.rawToGForce,
            y: Double(y) / AccelerometerReader.rawToGForce,
            z: Double(z) / AccelerometerReader.rawToGForce,
            timestamp: ProcessInfo.processInfo.systemUptime
        )

        delegate?.accelerometerReader(self, didReceiveSample: sample)
    }

    private func readInt32LE(_ buffer: UnsafePointer<UInt8>, offset: Int) -> Int32 {
        let b0 = Int32(buffer[offset])
        let b1 = Int32(buffer[offset + 1]) << 8
        let b2 = Int32(buffer[offset + 2]) << 16
        let b3 = Int32(buffer[offset + 3]) << 24
        return b0 | b1 | b2 | b3
    }

    deinit {
        stop()
    }
}

// C-compatible callback trampoline
private func accelerometerReportCallback(
    context: UnsafeMutableRawPointer?,
    result: IOReturn,
    sender: UnsafeMutableRawPointer?,
    type: IOHIDReportType,
    reportID: UInt32,
    report: UnsafeMutablePointer<UInt8>,
    reportLength: CFIndex
) {
    guard let ctx = context else { return }
    let reader = Unmanaged<AccelerometerReader>.fromOpaque(ctx).takeUnretainedValue()
    reader.handleReport(report, length: reportLength)
}
