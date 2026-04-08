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
    private let audioEngine = AVAudioEngine()

    @Published var isListening = false
    @Published var lastHeardText = ""

    private let triggerPhrases = [
        "jarvis are you there",
        "jarvis",
        "hey jarvis",
        "yo jarvis",
    ]

    func startListening() {
        guard !isListening else { return }

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                print("[SlapSound] Speech recognition not authorized: \(status.rawValue)")
                return
            }
            DispatchQueue.main.async {
                self?.beginRecognition()
            }
        }
    }

    private func beginRecognition() {
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isListening = true
            print("[SlapSound] Voice command listener started")
        } catch {
            print("[SlapSound] Audio engine failed to start: \(error)")
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let text = result.bestTranscription.formattedString.lowercased()

                DispatchQueue.main.async {
                    self.lastHeardText = text
                }

                // Check for trigger phrases
                for phrase in self.triggerPhrases {
                    if text.contains(phrase) {
                        print("[SlapSound] Voice command detected: \"\(phrase)\" in \"\(text)\"")
                        DispatchQueue.main.async {
                            self.delegate?.voiceCommandDetected(phrase)
                        }
                        // Restart recognition to prevent re-triggering on same phrase
                        self.restartRecognition()
                        return
                    }
                }
            }

            if error != nil || (result?.isFinal == true) {
                // Restart on timeout/error to keep listening
                self.restartRecognition()
            }
        }
    }

    private func restartRecognition() {
        stopListening()
        // Small delay before restarting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.beginRecognition()
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }
}
