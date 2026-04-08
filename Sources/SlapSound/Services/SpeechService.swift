import AppKit
import Foundation

final class SpeechService {
    private var synth = NSSpeechSynthesizer()

    struct VoiceInfo: Identifiable {
        let id: String       // voice identifier
        let name: String     // display name
        let language: String
    }

    var availableVoices: [VoiceInfo] {
        NSSpeechSynthesizer.availableVoices.compactMap { voiceID in
            let attrs = NSSpeechSynthesizer.attributes(forVoice: voiceID)
            let name = attrs[.name] as? String ?? voiceID.rawValue
            let lang = attrs[.localeIdentifier] as? String ?? "en"
            // Only english voices
            guard lang.hasPrefix("en") else { return nil }
            return VoiceInfo(id: voiceID.rawValue, name: name, language: lang)
        }
    }

    func speak(text: String, voiceID: String? = nil) {
        if synth.isSpeaking { synth.stopSpeaking() }
        if let vid = voiceID {
            synth = NSSpeechSynthesizer(voice: NSSpeechSynthesizer.VoiceName(rawValue: vid)) ?? NSSpeechSynthesizer()
        }
        synth.startSpeaking(text)
    }

    func stop() {
        synth.stopSpeaking()
    }
}
