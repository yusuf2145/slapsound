import Foundation

protocol SlapDetectorDelegate: AnyObject {
    func slapDetector(_ detector: SlapDetector, didDetectSlap event: SlapEvent)
    func slapDetectorDidDetectDoubleClap(_ detector: SlapDetector)
}

final class SlapDetector: AccelerometerReaderDelegate {
    weak var delegate: SlapDetectorDelegate?

    var sensitivity: Double = 0.05 {
        didSet {
            print("[SlapDetector] Threshold: \(String(format: "%.3f", sensitivity))g")
        }
    }
    var cooldownMs: Int = 150
    var isEnabled: Bool = true

    // Gravity baseline — very slow moving average so impacts don't shift it
    private var gravity: Double = 1.0
    private let gravityAlpha: Double = 0.0005  // ultra slow — only tracks orientation changes

    // Cooldown
    private var lastSlapTime: Date = .distantPast

    // Settling
    private var sampleCount: Int = 0

    // Double-tap/clap detection
    private var slapTimestamps: [Date] = []
    private var lastDoubleTapTime: Date = .distantPast

    // Debug
    private var logCounter: Int = 0
    private var maxExcessSeen: Double = 0

    func processSample(_ sample: AccelerometerSample) {
        guard isEnabled else { return }

        sampleCount += 1
        logCounter += 1

        let mag = sample.magnitude
        let excess = mag - gravity

        // Track max excess for debugging
        if excess > maxExcessSeen { maxExcessSeen = excess }

        // Log every ~1 second
        if logCounter % 800 == 0 {
            print("[Sensor] mag=\(String(format: "%.3f", mag))g gravity=\(String(format: "%.3f", gravity))g excess=\(String(format: "%.3f", excess))g threshold=\(String(format: "%.3f", sensitivity))g maxSeen=\(String(format: "%.3f", maxExcessSeen))g")
            maxExcessSeen = 0
        }

        // Only update gravity when NOT in an impact (excess below threshold)
        // This prevents impacts from shifting the baseline
        if excess < sensitivity {
            gravity = gravity * (1.0 - gravityAlpha) + mag * gravityAlpha
        }

        // Skip first 50 samples for settling
        guard sampleCount > 50 else { return }

        // Simple threshold check — fire immediately when exceeded
        guard excess > sensitivity else { return }

        // Cooldown check
        let now = Date()
        let elapsed = now.timeIntervalSince(lastSlapTime) * 1000
        guard elapsed >= Double(cooldownMs) else { return }

        lastSlapTime = now

        print("[SlapSound] *** SLAP! *** excess=\(String(format: "%.3f", excess))g mag=\(String(format: "%.3f", mag))g")

        let event = SlapEvent(force: excess, timestamp: now)
        delegate?.slapDetector(self, didDetectSlap: event)

        // Double-tap/clap detection
        // Clean old timestamps
        slapTimestamps = slapTimestamps.filter { now.timeIntervalSince($0) < 0.8 }
        slapTimestamps.append(now)

        if slapTimestamps.count >= 2 {
            // Check the gap between last two slaps is 150-800ms (not too fast, not too slow)
            let gap = slapTimestamps[slapTimestamps.count - 1].timeIntervalSince(slapTimestamps[slapTimestamps.count - 2])
            if gap >= 0.15 && gap <= 0.8 {
                // Don't re-trigger within 2 seconds
                let sinceLastDouble = now.timeIntervalSince(lastDoubleTapTime)
                if sinceLastDouble > 2.0 {
                    lastDoubleTapTime = now
                    slapTimestamps.removeAll()
                    print("[SlapSound] *** DOUBLE TAP/CLAP! *** gap=\(String(format: "%.2f", gap))s")
                    delegate?.slapDetectorDidDetectDoubleClap(self)
                }
            }
        }
    }

    // MARK: - AccelerometerReaderDelegate

    func accelerometerReader(_ reader: AccelerometerReader, didReceiveSample sample: AccelerometerSample) {
        processSample(sample)
    }
}
