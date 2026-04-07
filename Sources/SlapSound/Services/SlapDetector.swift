import Foundation

protocol SlapDetectorDelegate: AnyObject {
    func slapDetector(_ detector: SlapDetector, didDetectSlap event: SlapEvent)
}

final class SlapDetector: AccelerometerReaderDelegate {
    weak var delegate: SlapDetectorDelegate?

    var sensitivity: Double = 0.05 {
        didSet {
            print("[SlapDetector] Threshold updated: \(String(format: "%.3f", sensitivity))g")
        }
    }
    var cooldownMs: Int = 150
    var isEnabled: Bool = true

    // Gravity estimation (exponential moving average)
    private var gravityEstimate: Double = 1.0
    private let gravityAlpha: Double = 0.002

    // STA/LTA ratio detection
    private var shortTermBuffer: [Double] = []
    private var longTermBuffer: [Double] = []
    private let shortTermSize = 40
    private let longTermSize = 800
    private let staLtaThreshold: Double = 2.0

    // Cooldown
    private var lastSlapTime: Date = .distantPast

    // Settling
    private var sampleCount: Int = 0
    private let settlingPeriod: Int = 50

    // Peak tracking within a slap event
    private var peakExcess: Double = 0
    private var peakSample: AccelerometerSample?
    private var inImpact = false
    private var impactStartTime: Date = .distantPast

    // Debug logging
    private var logCounter: Int = 0

    func processSample(_ sample: AccelerometerSample) {
        guard isEnabled else { return }

        sampleCount += 1
        logCounter += 1

        let magnitude = sample.magnitude

        // Log every ~1 second with current threshold
        if logCounter % 800 == 0 {
            let excess = magnitude - gravityEstimate
            print("[Sensor] mag=\(String(format: "%.3f", magnitude))g excess=\(String(format: "%.3f", excess))g threshold=\(String(format: "%.3f", sensitivity))g \(isEnabled ? "ACTIVE" : "PAUSED")")
        }

        // Update gravity estimate
        gravityEstimate = gravityEstimate * (1.0 - gravityAlpha) + magnitude * gravityAlpha

        // Update STA/LTA buffers
        let energy = magnitude * magnitude
        shortTermBuffer.append(energy)
        longTermBuffer.append(energy)
        if shortTermBuffer.count > shortTermSize { shortTermBuffer.removeFirst() }
        if longTermBuffer.count > longTermSize { longTermBuffer.removeFirst() }

        // Don't detect during settling period
        guard sampleCount > settlingPeriod else { return }

        let excess = magnitude - gravityEstimate

        // Check if we're above threshold
        if excess > sensitivity {
            if !inImpact {
                // Start of a new impact
                inImpact = true
                impactStartTime = Date()
                peakExcess = excess
                peakSample = sample
            } else {
                // Still in impact — track peak
                if excess > peakExcess {
                    peakExcess = excess
                    peakSample = sample
                }
            }
        } else if inImpact {
            // Impact just ended — fire the event with peak force
            inImpact = false

            // Apply cooldown
            let now = Date()
            let elapsed = now.timeIntervalSince(lastSlapTime) * 1000
            guard elapsed >= Double(cooldownMs) else {
                peakExcess = 0
                peakSample = nil
                return
            }

            // STA/LTA check for bonus
            var force = peakExcess
            if shortTermBuffer.count >= shortTermSize && longTermBuffer.count >= longTermSize {
                let sta = shortTermBuffer.reduce(0.0, +) / Double(shortTermBuffer.count)
                let lta = longTermBuffer.reduce(0.0, +) / Double(longTermBuffer.count)
                if lta > 0 && sta / lta > staLtaThreshold {
                    force *= 1.2
                }
            }

            lastSlapTime = now

            print("[SlapSound] *** SLAP! *** force=\(String(format: "%.2f", force))g peak_mag=\(String(format: "%.2f", peakSample?.magnitude ?? 0))g")

            let event = SlapEvent(force: force, timestamp: now)
            delegate?.slapDetector(self, didDetectSlap: event)

            peakExcess = 0
            peakSample = nil
        }
    }

    // MARK: - AccelerometerReaderDelegate

    func accelerometerReader(_ reader: AccelerometerReader, didReceiveSample sample: AccelerometerSample) {
        processSample(sample)
    }
}
