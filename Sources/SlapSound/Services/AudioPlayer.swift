import AVFoundation
import Foundation

final class AudioPlayer {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let pitchEffect = AVAudioUnitTimePitch()
    private var audioBuffer: AVAudioPCMBuffer?
    private var isReady = false

    var masterVolume: Float = 1.0
    var volumeScaling: Bool = true

    func setup() {
        engine.attach(playerNode)
        engine.attach(pitchEffect)

        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(playerNode, to: pitchEffect, format: format)
        engine.connect(pitchEffect, to: engine.mainMixerNode, format: format)

        // Load the bundled sound
        loadSound(format: format)

        do {
            try engine.start()
            isReady = true
            print("[SlapSound] Audio engine started")
        } catch {
            print("[SlapSound] Failed to start audio engine: \(error)")
        }
    }

    private func loadSound(format: AVAudioFormat) {
        // Try to find the bundled sound file
        let soundPaths = [
            // SPM bundle resource path — prefer mp3 (user's real whip sound)
            Bundle.module.url(forResource: "whipcrack", withExtension: "mp3", subdirectory: "Sounds"),
            Bundle.module.url(forResource: "whipcrack", withExtension: "wav", subdirectory: "Sounds"),
            Bundle.module.url(forResource: "whipcrack", withExtension: "m4a", subdirectory: "Sounds"),
        ]

        var sourceFile: AVAudioFile?
        for path in soundPaths {
            if let url = path {
                do {
                    sourceFile = try AVAudioFile(forReading: url)
                    print("[SlapSound] Loaded sound: \(url.lastPathComponent)")
                    break
                } catch {
                    continue
                }
            }
        }

        if sourceFile == nil {
            print("[SlapSound] No sound file found. Generating synthetic whip crack...")
            audioBuffer = generateSyntheticWhipCrack(format: format)
            return
        }

        guard let file = sourceFile else { return }

        // Convert to engine format
        guard let sourceBuffer = AVAudioPCMBuffer(
            pcmFormat: file.processingFormat,
            frameCapacity: AVAudioFrameCount(file.length)
        ) else { return }

        do {
            try file.read(into: sourceBuffer)
        } catch {
            print("[SlapSound] Failed to read audio file: \(error)")
            audioBuffer = generateSyntheticWhipCrack(format: format)
            return
        }

        // If formats match, use directly
        if file.processingFormat == format {
            audioBuffer = sourceBuffer
        } else {
            // Convert format
            guard let converter = AVAudioConverter(from: file.processingFormat, to: format) else {
                audioBuffer = generateSyntheticWhipCrack(format: format)
                return
            }
            let convertedFrameCount = AVAudioFrameCount(
                Double(sourceBuffer.frameLength) * format.sampleRate / file.processingFormat.sampleRate
            )
            guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: convertedFrameCount) else {
                audioBuffer = generateSyntheticWhipCrack(format: format)
                return
            }

            var error: NSError?
            converter.convert(to: convertedBuffer, error: &error) { _, outStatus in
                outStatus.pointee = .haveData
                return sourceBuffer
            }

            if error != nil {
                audioBuffer = generateSyntheticWhipCrack(format: format)
            } else {
                audioBuffer = convertedBuffer
            }
        }
    }

    /// Generate a synthetic whip crack sound (sharp attack, quick decay with noise)
    private func generateSyntheticWhipCrack(format: AVAudioFormat) -> AVAudioPCMBuffer {
        let sampleRate = format.sampleRate
        let duration: Double = 0.3  // 300ms
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let channels = Int(format.channelCount)
        for ch in 0..<channels {
            guard let channelData = buffer.floatChannelData?[ch] else { continue }

            for i in 0..<Int(frameCount) {
                let t = Double(i) / sampleRate
                let normalizedT = t / duration

                // Sharp attack envelope: instant peak then exponential decay
                let envelope: Double
                if normalizedT < 0.01 {
                    // 1ms attack
                    envelope = normalizedT / 0.01
                } else {
                    // Exponential decay
                    envelope = exp(-15.0 * (normalizedT - 0.01))
                }

                // White noise burst (whip crack characteristic)
                let noise = Double.random(in: -1.0...1.0)

                // Add a sharp transient click at the start
                let click: Double
                if normalizedT < 0.005 {
                    click = sin(2.0 * .pi * 2000.0 * t) * (1.0 - normalizedT / 0.005)
                } else {
                    click = 0
                }

                // High-frequency content that decays faster
                let highFreq = sin(2.0 * .pi * 4000.0 * t) * exp(-30.0 * normalizedT)

                let sample = (noise * 0.7 + click * 0.8 + highFreq * 0.3) * envelope * 0.9
                channelData[i] = Float(sample)
            }
        }

        return buffer
    }

    func playSlap(force: Double) {
        guard isReady, let buffer = audioBuffer else { return }

        // Volume scaling: logarithmic mapping from force to volume
        // Minimum 50% volume even for light taps, scales up to 100%
        let volume: Float
        if volumeScaling {
            let normalized = min(max(force / 3.0, 0.0), 1.0)
            let scaled = Float(0.5 + 0.5 * log2(1.0 + normalized))
            volume = min(masterVolume * scaled * 1.5, 1.0)  // boost and cap at 1.0
        } else {
            volume = masterVolume
        }

        // Pitch scaling: harder slaps = slightly higher pitch
        let normalized = min(max(force / 5.0, 0.0), 1.0)
        let pitchCents: Float = Float(-200.0 + 600.0 * normalized)
        pitchEffect.pitch = pitchCents

        // Play
        playerNode.volume = volume
        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts)
        playerNode.play()
    }

    func stop() {
        playerNode.stop()
        engine.stop()
        isReady = false
    }
}
