import Foundation
import Speech
import AVFoundation

protocol VoiceCommandDelegate: AnyObject {
    func voiceCommandDetected(_ command: String)
}

final class VoiceCommandListener: ObservableObject {
    weak var delegate: VoiceCommandDelegate?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let micEngine = AVAudioEngine()

    @Published var isListening = false
    @Published var lastHeardText = ""

    private let triggerPhrases = [
        "are you there",
        "jarvis are you there",
        "jarvis",
        "hey jarvis",
    ]

    // Debounce — don't re-trigger within 3 seconds
    private var lastTriggerTime: Date = .distantPast

    func startListening() {
        guard !isListening else { return }

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("[Voice] Speech recognition authorized")
                    self?.beginRecognition()
                case .denied:
                    print("[Voice] Speech recognition denied by user")
                case .restricted:
                    print("[Voice] Speech recognition restricted")
                case .notDetermined:
                    print("[Voice] Speech recognition not determined")
                @unknown default:
                    print("[Voice] Speech recognition unknown status")
                }
            }
        }
    }

    private func beginRecognition() {
        // Stop any existing recognition
        stopListening()

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("[Voice] Speech recognizer not available")
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        // Use a separate audio engine for mic input (not the playback engine)
        let inputNode = micEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Check format is valid
        guard recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 else {
            print("[Voice] Invalid audio format: \(recordingFormat)")
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        micEngine.prepare()

        do {
            try micEngine.start()
        } catch {
            print("[Voice] Mic engine failed: \(error)")
            return
        }

        isListening = true
        print("[Voice] Listening for voice commands...")

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let text = result.bestTranscription.formattedString.lowercased()

                DispatchQueue.main.async {
                    self.lastHeardText = text
                }

                // Check for trigger
                for phrase in self.triggerPhrases {
                    if text.contains(phrase) {
                        let now = Date()
                        guard now.timeIntervalSince(self.lastTriggerTime) > 3.0 else { return }
                        self.lastTriggerTime = now

                        print("[Voice] *** TRIGGER: \"\(phrase)\" detected in \"\(text)\" ***")
                        DispatchQueue.main.async {
                            self.delegate?.voiceCommandDetected(phrase)
                        }
                        // Restart to clear the buffer
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.restartRecognition()
                        }
                        return
                    }
                }
            }

            // Restart on error or final result (Apple cuts off after ~60s)
            if error != nil || (result?.isFinal == true) {
                print("[Voice] Recognition ended, restarting... error=\(String(describing: error))")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.isListening {
                        self.restartRecognition()
                    }
                }
            }
        }
    }

    private func restartRecognition() {
        guard isListening else { return }
        let wasListening = isListening
        cleanupRecognition()
        if wasListening {
            beginRecognition()
        }
    }

    private func cleanupRecognition() {
        micEngine.stop()
        micEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }

    func stopListening() {
        isListening = false
        cleanupRecognition()
        print("[Voice] Stopped listening")
    }
}
