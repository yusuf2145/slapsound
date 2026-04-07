import AVFoundation
import Foundation

final class AudioPlayer {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let pitchEffect = AVAudioUnitTimePitch()

    // Sound buffers for different modes
    private var soundBuffers: [String: AVAudioPCMBuffer] = [:]
    private var currentSoundKey: String = "whipcrack"
    private var isReady = false
    private var engineFormat: AVAudioFormat?

    var masterVolume: Float = 1.0
    var volumeScaling: Bool = true

    func setup() {
        engine.attach(playerNode)
        engine.attach(pitchEffect)

        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engineFormat = format
        engine.connect(playerNode, to: pitchEffect, format: format)
        engine.connect(pitchEffect, to: engine.mainMixerNode, format: format)

        // Load all bundled sounds
        loadAllSounds(format: format)

        do {
            try engine.start()
            isReady = true
            print("[SlapSound] Audio engine started")
        } catch {
            print("[SlapSound] Failed to start audio engine: \(error)")
        }
    }

    private func loadAllSounds(format: AVAudioFormat) {
        // Try to load each sound file
        let soundNames = ["whipcrack", "slap", "punch", "airhorn", "moan", "jarvis", "jarvis_welcome"]
        let extensions = ["mp3", "wav", "m4a"]

        for name in soundNames {
            for ext in extensions {
                if let url = Bundle.module.url(forResource: name, withExtension: ext, subdirectory: "Sounds") {
                    if let buffer = loadSoundFile(url: url, format: format) {
                        soundBuffers[name] = buffer
                        print("[SlapSound] Loaded: \(name).\(ext)")
                        break
                    }
                }
            }
        }

        // Generate synthetic sounds for any that are missing
        if soundBuffers["whipcrack"] == nil {
            soundBuffers["whipcrack"] = generateSyntheticWhipCrack(format: format)
            print("[SlapSound] Generated synthetic whip crack")
        }
        if soundBuffers["slap"] == nil {
            soundBuffers["slap"] = generateSyntheticSlap(format: format)
            print("[SlapSound] Generated synthetic slap")
        }
        if soundBuffers["punch"] == nil {
            soundBuffers["punch"] = generateSyntheticPunch(format: format)
            print("[SlapSound] Generated synthetic punch")
        }
        if soundBuffers["airhorn"] == nil {
            soundBuffers["airhorn"] = generateSyntheticAirHorn(format: format)
            print("[SlapSound] Generated synthetic air horn")
        }
        if soundBuffers["jarvis"] == nil {
            soundBuffers["jarvis"] = generateJarvisBeep(format: format)
            print("[SlapSound] Generated synthetic Jarvis beep")
        }
        if soundBuffers["jarvis_welcome"] == nil {
            soundBuffers["jarvis_welcome"] = generateJarvisStartup(format: format)
            print("[SlapSound] Generated synthetic Jarvis startup")
        }
    }

    private func loadSoundFile(url: URL, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        guard let sourceBuffer = AVAudioPCMBuffer(
            pcmFormat: file.processingFormat,
            frameCapacity: AVAudioFrameCount(file.length)
        ) else { return nil }

        do { try file.read(into: sourceBuffer) } catch { return nil }

        if file.processingFormat == format {
            return sourceBuffer
        }

        guard let converter = AVAudioConverter(from: file.processingFormat, to: format) else { return nil }
        let convertedFrameCount = AVAudioFrameCount(
            Double(sourceBuffer.frameLength) * format.sampleRate / file.processingFormat.sampleRate
        )
        guard let converted = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: convertedFrameCount) else { return nil }

        var error: NSError?
        converter.convert(to: converted, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return sourceBuffer
        }
        return error == nil ? converted : nil
    }

    func setSoundMode(_ mode: SoundMode) {
        switch mode {
        case .whipCrack: currentSoundKey = "whipcrack"
        case .slap: currentSoundKey = "slap"
        case .punch: currentSoundKey = "punch"
        case .airHorn: currentSoundKey = "airhorn"
        case .moan: currentSoundKey = "moan"
        case .custom: currentSoundKey = "whipcrack" // fallback
        }
        print("[SlapSound] Sound set to: \(currentSoundKey) (has buffer: \(soundBuffers[currentSoundKey] != nil))")
    }

    /// Preview a specific sound mode at full volume
    func playPreview(mode: SoundMode) {
        guard isReady else { return }
        let key: String
        switch mode {
        case .whipCrack: key = "whipcrack"
        case .slap: key = "slap"
        case .punch: key = "punch"
        case .airHorn: key = "airhorn"
        case .moan: key = "moan"
        case .custom: key = "whipcrack"
        }
        guard let buffer = soundBuffers[key] else {
            print("[SlapSound] No buffer for \(key)")
            return
        }
        pitchEffect.pitch = 0
        playerNode.volume = masterVolume
        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts)
        playerNode.play()
        print("[SlapSound] Playing preview: \(key)")
    }

    func playSlap(force: Double) {
        guard isReady else { return }
        guard let buffer = soundBuffers[currentSoundKey] ?? soundBuffers["whipcrack"] else { return }

        let volume: Float
        if volumeScaling {
            let normalized = min(max(force / 3.0, 0.0), 1.0)
            let scaled = Float(0.5 + 0.5 * log2(1.0 + normalized))
            volume = min(masterVolume * scaled * 1.5, 1.0)
        } else {
            volume = masterVolume
        }

        let normalized = min(max(force / 5.0, 0.0), 1.0)
        pitchEffect.pitch = Float(-200.0 + 600.0 * normalized)

        playerNode.volume = volume
        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts)
        playerNode.play()
    }

    func playJarvisBeep() {
        guard isReady else { return }
        guard let buffer = soundBuffers["jarvis"] else { return }
        pitchEffect.pitch = 0
        playerNode.volume = masterVolume
        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts)
        playerNode.play()
    }

    func playJarvisStartup() {
        guard isReady else { return }
        guard let buffer = soundBuffers["jarvis_welcome"] else { return }
        pitchEffect.pitch = 0
        playerNode.volume = masterVolume
        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts)
        playerNode.play()
    }

    func stop() {
        playerNode.stop()
        engine.stop()
        isReady = false
    }

    // MARK: - Synthetic Sound Generators

    private func generateSyntheticWhipCrack(format: AVAudioFormat) -> AVAudioPCMBuffer {
        let sr = format.sampleRate
        let dur = 0.3
        let count = AVAudioFrameCount(sr * dur)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: count)!
        buf.frameLength = count
        for ch in 0..<Int(format.channelCount) {
            guard let data = buf.floatChannelData?[ch] else { continue }
            for i in 0..<Int(count) {
                let t = Double(i) / sr
                let n = t / dur
                let env = n < 0.01 ? n / 0.01 : exp(-15.0 * (n - 0.01))
                let noise = Double.random(in: -1...1)
                let click = n < 0.005 ? sin(2 * .pi * 2000 * t) * (1 - n / 0.005) : 0
                let hi = sin(2 * .pi * 4000 * t) * exp(-30 * n)
                data[i] = Float((noise * 0.7 + click * 0.8 + hi * 0.3) * env * 0.9)
            }
        }
        return buf
    }

    private func generateSyntheticSlap(format: AVAudioFormat) -> AVAudioPCMBuffer {
        let sr = format.sampleRate
        let dur = 0.2
        let count = AVAudioFrameCount(sr * dur)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: count)!
        buf.frameLength = count
        for ch in 0..<Int(format.channelCount) {
            guard let data = buf.floatChannelData?[ch] else { continue }
            for i in 0..<Int(count) {
                let t = Double(i) / sr
                let n = t / dur
                let env = n < 0.005 ? n / 0.005 : exp(-20 * (n - 0.005))
                let noise = Double.random(in: -1...1)
                let low = sin(2 * .pi * 300 * t) * exp(-12 * n) * 0.5
                data[i] = Float((noise * 0.8 + low) * env * 0.95)
            }
        }
        return buf
    }

    private func generateSyntheticPunch(format: AVAudioFormat) -> AVAudioPCMBuffer {
        let sr = format.sampleRate
        let dur = 0.25
        let count = AVAudioFrameCount(sr * dur)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: count)!
        buf.frameLength = count
        for ch in 0..<Int(format.channelCount) {
            guard let data = buf.floatChannelData?[ch] else { continue }
            for i in 0..<Int(count) {
                let t = Double(i) / sr
                let n = t / dur
                let env = n < 0.003 ? n / 0.003 : exp(-18 * (n - 0.003))
                let thud = sin(2 * .pi * 80 * t) * exp(-10 * n) * 0.8
                let crack = Double.random(in: -1...1) * exp(-25 * n) * 0.6
                let mid = sin(2 * .pi * 400 * t) * exp(-20 * n) * 0.4
                data[i] = Float((thud + crack + mid) * env)
            }
        }
        return buf
    }

    private func generateSyntheticAirHorn(format: AVAudioFormat) -> AVAudioPCMBuffer {
        let sr = format.sampleRate
        let dur = 0.8
        let count = AVAudioFrameCount(sr * dur)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: count)!
        buf.frameLength = count
        for ch in 0..<Int(format.channelCount) {
            guard let data = buf.floatChannelData?[ch] else { continue }
            for i in 0..<Int(count) {
                let t = Double(i) / sr
                let n = t / dur
                let env = n < 0.05 ? n / 0.05 : (n > 0.85 ? (1 - n) / 0.15 : 1.0)
                let f1 = sin(2 * .pi * 480 * t)
                let f2 = sin(2 * .pi * 580 * t) * 0.8
                let f3 = sin(2 * .pi * 720 * t) * 0.5
                let vibrato = sin(2 * .pi * 6 * t) * 0.03
                data[i] = Float((f1 + f2 + f3) * env * (0.3 + vibrato))
            }
        }
        return buf
    }

    private func generateJarvisBeep(format: AVAudioFormat) -> AVAudioPCMBuffer {
        let sr = format.sampleRate
        let dur = 0.15
        let count = AVAudioFrameCount(sr * dur)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: count)!
        buf.frameLength = count
        for ch in 0..<Int(format.channelCount) {
            guard let data = buf.floatChannelData?[ch] else { continue }
            for i in 0..<Int(count) {
                let t = Double(i) / sr
                let n = t / dur
                let env = n < 0.1 ? n / 0.1 : (n > 0.7 ? (1 - n) / 0.3 : 1.0)
                let tone = sin(2 * .pi * 1200 * t) * 0.5 + sin(2 * .pi * 1800 * t) * 0.3
                data[i] = Float(tone * env * 0.6)
            }
        }
        return buf
    }

    private func generateJarvisStartup(format: AVAudioFormat) -> AVAudioPCMBuffer {
        let sr = format.sampleRate
        let dur = 1.5
        let count = AVAudioFrameCount(sr * dur)
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: count)!
        buf.frameLength = count
        for ch in 0..<Int(format.channelCount) {
            guard let data = buf.floatChannelData?[ch] else { continue }
            for i in 0..<Int(count) {
                let t = Double(i) / sr
                let n = t / dur

                // Rising sweep
                let sweepFreq = 400 + 1200 * n
                let sweep = sin(2 * .pi * sweepFreq * t)

                // Harmonic chord that builds
                let chord = sin(2 * .pi * 800 * t) * 0.3 + sin(2 * .pi * 1200 * t) * 0.2 + sin(2 * .pi * 1600 * t) * 0.15

                // Envelope: fade in, sustain, fade out
                let env: Double
                if n < 0.15 { env = n / 0.15 }
                else if n > 0.8 { env = (1 - n) / 0.2 }
                else { env = 1.0 }

                // Shimmer
                let shimmer = sin(2 * .pi * 12 * t) * 0.05

                data[i] = Float((sweep * 0.4 + chord) * env * (0.5 + shimmer))
            }
        }
        return buf
    }
}
