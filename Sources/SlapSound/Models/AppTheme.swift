import SwiftUI

enum ThemeName: String, CaseIterable, Identifiable, Codable {
    case midnight = "Midnight"
    case neon = "Neon"
    case sunset = "Sunset"
    case clean = "Clean"

    var id: String { rawValue }
}

struct AppTheme {
    let name: ThemeName
    let sidebarBg: Color
    let contentBg: Color
    let cardBg: Color
    let cardBgActive: Color
    let primary: Color
    let secondary: Color
    let tertiary: Color
    let muted: Color
    let accent: Color
    let accentAlt: Color
    let border: Color
    let isDark: Bool

    static let midnight = AppTheme(
        name: .midnight,
        sidebarBg: .black,
        contentBg: Color(white: 0.06),
        cardBg: Color.white.opacity(0.03),
        cardBgActive: Color.white.opacity(0.08),
        primary: .white,
        secondary: Color.white.opacity(0.5),
        tertiary: Color.white.opacity(0.25),
        muted: Color.white.opacity(0.15),
        accent: .white,
        accentAlt: Color.white.opacity(0.6),
        border: Color.white.opacity(0.1),
        isDark: true
    )

    static let neon = AppTheme(
        name: .neon,
        sidebarBg: Color(red: 0.02, green: 0.02, blue: 0.06),
        contentBg: Color(red: 0.04, green: 0.04, blue: 0.08),
        cardBg: Color(red: 0, green: 1, blue: 1).opacity(0.04),
        cardBgActive: Color(red: 0, green: 1, blue: 1).opacity(0.1),
        primary: .white,
        secondary: Color(red: 0, green: 1, blue: 1).opacity(0.6),
        tertiary: Color(red: 0, green: 1, blue: 1).opacity(0.3),
        muted: Color(red: 1, green: 0, blue: 1).opacity(0.2),
        accent: Color(red: 0, green: 1, blue: 1),
        accentAlt: Color(red: 1, green: 0, blue: 1),
        border: Color(red: 0, green: 1, blue: 1).opacity(0.15),
        isDark: true
    )

    static let sunset = AppTheme(
        name: .sunset,
        sidebarBg: Color(red: 0.08, green: 0.03, blue: 0.02),
        contentBg: Color(red: 0.1, green: 0.05, blue: 0.03),
        cardBg: Color.orange.opacity(0.05),
        cardBgActive: Color.orange.opacity(0.12),
        primary: .white,
        secondary: Color.orange.opacity(0.6),
        tertiary: Color.orange.opacity(0.35),
        muted: Color.red.opacity(0.2),
        accent: .orange,
        accentAlt: .red,
        border: Color.orange.opacity(0.15),
        isDark: true
    )

    static let clean = AppTheme(
        name: .clean,
        sidebarBg: Color(white: 0.95),
        contentBg: .white,
        cardBg: Color.black.opacity(0.03),
        cardBgActive: Color.black.opacity(0.07),
        primary: .black,
        secondary: Color.black.opacity(0.5),
        tertiary: Color.black.opacity(0.25),
        muted: Color.black.opacity(0.12),
        accent: .black,
        accentAlt: Color.black.opacity(0.6),
        border: Color.black.opacity(0.08),
        isDark: false
    )

    static func forName(_ name: ThemeName) -> AppTheme {
        switch name {
        case .midnight: return .midnight
        case .neon: return .neon
        case .sunset: return .sunset
        case .clean: return .clean
        }
    }
}
