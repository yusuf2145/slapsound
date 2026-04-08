import SwiftUI
import Combine

// MARK: - Sound Mode
enum SoundMode: String, CaseIterable, Identifiable {
    case whipCrack = "Whip Crack"
    case slap = "Slap"
    case punch = "Punch"
    case airHorn = "Air Horn"
    case moan = "Sussy UwU"
    case custom = "Custom"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .whipCrack: return "waveform.path"
        case .slap: return "hand.raised.fill"
        case .punch: return "figure.boxing"
        case .airHorn: return "megaphone.fill"
        case .moan: return "face.smiling.inverse"
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

    static var presets: [KeyBinding] = [.none, .key1, .key2, .key3, .spaceBar, .returnKey]
}

// MARK: - App Settings (UserDefaults wrapper)
final class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard

    // Register defaults once so fresh installs get good values
    init() {
        defaults.register(defaults: [
            "isEnabled": true,
            "sensitivity": 0.05,
            "cooldownMs": 150,
            "masterVolume": 1.0,
            "volumeScaling": true,
            "slapCount": 0,
            "soundMode": SoundMode.whipCrack.rawValue,
            "tonyStarkMode": false,
            "keyBindingCode": 18,
            "keyBindingLabel": "1",
            "clapDetection": false,
        ])
    }

    var isEnabled: Bool {
        get { defaults.bool(forKey: "isEnabled") }
        set { defaults.set(newValue, forKey: "isEnabled") }
    }

    var sensitivity: Double {
        get {
            let val = defaults.double(forKey: "sensitivity")
            // If it's 0 or absurdly high, return sensible default
            return (val > 0 && val <= 10) ? val : 0.05
        }
        set { defaults.set(newValue, forKey: "sensitivity") }
    }

    var cooldownMs: Int {
        get {
            let val = defaults.integer(forKey: "cooldownMs")
            return val > 0 ? val : 150
        }
        set { defaults.set(newValue, forKey: "cooldownMs") }
    }

    var masterVolume: Double {
        get {
            let val = defaults.double(forKey: "masterVolume")
            return (val >= 0 && val <= 1) ? val : 1.0
        }
        set { defaults.set(newValue, forKey: "masterVolume") }
    }

    var volumeScaling: Bool {
        get { defaults.bool(forKey: "volumeScaling") }
        set { defaults.set(newValue, forKey: "volumeScaling") }
    }

    var slapCount: Int {
        get { defaults.integer(forKey: "slapCount") }
        set { defaults.set(newValue, forKey: "slapCount") }
    }

    var soundModeRaw: String {
        get { defaults.string(forKey: "soundMode") ?? SoundMode.whipCrack.rawValue }
        set { defaults.set(newValue, forKey: "soundMode") }
    }

    var soundMode: SoundMode {
        get { SoundMode(rawValue: soundModeRaw) ?? .whipCrack }
        set { soundModeRaw = newValue.rawValue }
    }

    var tonyStarkMode: Bool {
        get { defaults.bool(forKey: "tonyStarkMode") }
        set { defaults.set(newValue, forKey: "tonyStarkMode") }
    }

    var keyBindingCode: Int {
        get { defaults.integer(forKey: "keyBindingCode") }
        set { defaults.set(newValue, forKey: "keyBindingCode") }
    }

    var keyBindingLabel: String {
        get { defaults.string(forKey: "keyBindingLabel") ?? "1" }
        set { defaults.set(newValue, forKey: "keyBindingLabel") }
    }

    var keyBinding: KeyBinding {
        get { KeyBinding(keyCode: UInt16(keyBindingCode), label: keyBindingLabel) }
        set {
            keyBindingCode = Int(newValue.keyCode)
            keyBindingLabel = newValue.label
        }
    }
}
