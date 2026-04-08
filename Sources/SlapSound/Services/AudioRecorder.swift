import AVFoundation
import Foundation

final class AudioRecorder: ObservableObject {
    private var recorder: AVAudioRecorder?
    private var timer: Timer?

    @Published var isRecording = false
    @Published var timeRemaining: Double = 4.0
    @Published var hasRecording = false

    let maxDuration: Double = 4.0

    // Save custom recording to app support directory
    var recordingURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("SlapSound", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("custom_sound.m4a")
    }

    init() {
        hasRecording = FileManager.default.fileExists(atPath: recordingURL.path)
    }

    func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            recorder?.record(forDuration: maxDuration)
            isRecording = true
            timeRemaining = maxDuration

            // Countdown timer
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.timeRemaining -= 0.1
                    if self.timeRemaining <= 0 {
                        self.stopRecording()
                    }
                }
            }

            print("[SlapSound] Recording started: \(recordingURL.path)")
        } catch {
            print("[SlapSound] Recording failed: \(error)")
        }
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        timer?.invalidate()
        timer = nil
        isRecording = false
        timeRemaining = maxDuration
        hasRecording = FileManager.default.fileExists(atPath: recordingURL.path)
        print("[SlapSound] Recording saved: \(hasRecording)")
    }

    func deleteRecording() {
        try? FileManager.default.removeItem(at: recordingURL)
        hasRecording = false
        print("[SlapSound] Custom recording deleted")
    }
}
