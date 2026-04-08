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
            "speechMode": false,
            "speechText": "Ouch!",
            "speechVoice": "",
            "themeName": "Midnight",
            "combosEnabled": true,
            "comboTimeout": 2.0,
            "customKeyText": "",
            "keyMode": "single",
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

    var speechMode: Bool {
        get { defaults.bool(forKey: "speechMode") }
        set { defaults.set(newValue, forKey: "speechMode") }
    }

    var speechText: String {
        get { defaults.string(forKey: "speechText") ?? "Ouch!" }
        set { defaults.set(newValue, forKey: "speechText") }
    }

    var speechVoice: String {
        get { defaults.string(forKey: "speechVoice") ?? "" }
        set { defaults.set(newValue, forKey: "speechVoice") }
    }

    var themeNameRaw: String {
        get { defaults.string(forKey: "themeName") ?? "Midnight" }
        set { defaults.set(newValue, forKey: "themeName") }
    }

    var combosEnabled: Bool {
        get { defaults.bool(forKey: "combosEnabled") }
        set { defaults.set(newValue, forKey: "combosEnabled") }
    }

    var comboTimeout: Double {
        get {
            let val = defaults.double(forKey: "comboTimeout")
            return val > 0 ? val : 2.0
        }
        set { defaults.set(newValue, forKey: "comboTimeout") }
    }

    var customKeyText: String {
        get { defaults.string(forKey: "customKeyText") ?? "" }
        set { defaults.set(newValue, forKey: "customKeyText") }
    }

    var keyMode: String {
        get { defaults.string(forKey: "keyMode") ?? "single" }
        set { defaults.set(newValue, forKey: "keyMode") }
    }
}
