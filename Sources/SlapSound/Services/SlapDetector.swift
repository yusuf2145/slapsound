import Foundation

protocol SlapDetectorDelegate: AnyObject {
    func slapDetector(_ detector: SlapDetector, didDetectSlap event: SlapEvent)
}

final class SlapDetector: AccelerometerReaderDelegate {
    weak var delegate: SlapDetectorDelegate?

    var sensitivity: Double = 0.05    // g-force threshold — ultra sensitive
    var cooldownMs: Int = 150         // short cooldown for rapid slaps
    var isEnabled: Bool = true

    // Gravity estimation (exponential moving average)
    private var gravityEstimate: Double = 1.0
    private let gravityAlpha: Double = 0.002  // slightly faster adaptation

    // STA/LTA ratio detection
    private var shortTermBuffer: [Double] = []  // ~40 samples
    private var longTermBuffer: [Double] = []   // ~800 samples
    private let shortTermSize = 40
    private let longTermSize = 800
    private let staLtaThreshold: Double = 2.0   // lower threshold

    // Cooldown
    private var lastSlapTime: Date = .distantPast

    // Sample counter for startup settling
    private var sampleCount: Int = 0
    private let settlingPeriod: Int = 50   // shorter settle time

    // Debug logging
    private var logCounter: Int = 0

    func processSample(_ sample: AccelerometerSample) {
        guard isEnabled else { return }

        sampleCount += 1
        logCounter += 1

        let magnitude = sample.magnitude

        // Log every 800 samples (~1 sec) so we can see it's alive
        if logCounter % 800 == 0 {
            let excess = magnitude - gravityEstimate
            print("[SlapSound] accel: mag=\(String(format: "%.3f", magnitude))g gravity=\(String(format: "%.3f", gravityEstimate))g excess=\(String(format: "%.3f", excess))g threshold=\(String(format: "%.3f", sensitivity))g")
        }

        // Update gravity estimate
        gravityEstimate = gravityEstimate * (1.0 - gravityAlpha) + magnitude * gravityAlpha

        // Update STA/LTA buffers with energy (magnitude squared)
        let energy = magnitude * magnitude
        shortTermBuffer.append(energy)
        longTermBuffer.append(energy)

        if shortTermBuffer.count > shortTermSize {
            shortTermBuffer.removeFirst()
        }
        if longTermBuffer.count > longTermSize {
            longTermBuffer.removeFirst()
        }

        // Don't detect during settling period
        guard sampleCount > settlingPeriod else { return }

        // Algorithm 1: Magnitude threshold
        let excess = magnitude - gravityEstimate
        let thresholdTriggered = excess > sensitivity

        // Algorithm 2: STA/LTA ratio
        var staLtaTriggered = false
        if shortTermBuffer.count >= shortTermSize && longTermBuffer.count >= longTermSize {
            let sta = shortTermBuffer.reduce(0.0, +) / Double(shortTermBuffer.count)
            let lta = longTermBuffer.reduce(0.0, +) / Double(longTermBuffer.count)
            if lta > 0 {
                let ratio = sta / lta
                staLtaTriggered = ratio > staLtaThreshold
            }
        }

        // Require magnitude threshold (primary) with optional STA/LTA confirmation
        guard thresholdTriggered else { return }

        // Apply cooldown
        let now = Date()
        let elapsed = now.timeIntervalSince(lastSlapTime) * 1000 // ms
        guard elapsed >= Double(cooldownMs) else { return }

        // Compute force (boost if both algorithms agree)
        var force = excess
        if staLtaTriggered {
            force *= 1.2
        }

        lastSlapTime = now

        print("[SlapSound] *** SLAP DETECTED! *** force=\(String(format: "%.2f", force))g magnitude=\(String(format: "%.2f", sample.magnitude))g")

        let event = SlapEvent(force: force, timestamp: now)
        delegate?.slapDetector(self, didDetectSlap: event)
    }

    // MARK: - AccelerometerReaderDelegate

    func accelerometerReader(_ reader: AccelerometerReader, didReceiveSample sample: AccelerometerSample) {
        processSample(sample)
    }
}
