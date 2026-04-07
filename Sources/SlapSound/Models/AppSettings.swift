import SwiftUI
import Combine

// MARK: - Sound Mode
enum SoundMode: String, CaseIterable, Identifiable {
    case whipCrack = "Whip Crack"
    case slap = "Slap"
    case punch = "Punch"
    case airHorn = "Air Horn"
    case custom = "Custom"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .whipCrack: return "waveform.path"
        case .slap: return "hand.raised.fill"
        case .punch: return "figure.boxing"
        case .airHorn: return "megaphone.fill"
        case .custom: return "music.note"
        }
    }
}

// MARK: - Key Binding
struct KeyBinding: Codable, Equatable {
    var keyCode: UInt16
    var label: String

    static let key1 = KeyBinding(keyCode: 18, label: "1")
    static let key2 = KeyBinding(keyCode: 19, label: "2")
    static let key3 = KeyBinding(keyCode: 20, label: "3")
    static let spaceBar = KeyBinding(keyCode: 49, label: "Space")
    static let returnKey = KeyBinding(keyCode: 36, label: "Return")
    static let none = KeyBinding(keyCode: 0, label: "None")

    static let presets: [KeyBinding] = [.none, .key1, .key2, .key3, .spaceBar, .returnKey]
}

// MARK: - App Settings
final class AppSettings: ObservableObject {
    @AppStorage("isEnabled") var isEnabled: Bool = true
    @AppStorage("sensitivity") var sensitivity: Double = 0.05
    @AppStorage("cooldownMs") var cooldownMs: Int = 150
    @AppStorage("masterVolume") var masterVolume: Double = 1.0
    @AppStorage("volumeScaling") var volumeScaling: Bool = true
    @AppStorage("slapCount") var slapCount: Int = 0
    @AppStorage("soundMode") var soundModeRaw: String = SoundMode.whipCrack.rawValue
    @AppStorage("tonyStarkMode") var tonyStarkMode: Bool = false
    @AppStorage("keyBindingCode") var keyBindingCode: Int = 18
    @AppStorage("keyBindingLabel") var keyBindingLabel: String = "1"
    @AppStorage("clapDetection") var clapDetection: Bool = false

    var soundMode: SoundMode {
        get { SoundMode(rawValue: soundModeRaw) ?? .whipCrack }
        set { soundModeRaw = newValue.rawValue }
    }

    var keyBinding: KeyBinding {
        get { KeyBinding(keyCode: UInt16(keyBindingCode), label: keyBindingLabel) }
        set {
            keyBindingCode = Int(newValue.keyCode)
            keyBindingLabel = newValue.label
        }
    }
}
