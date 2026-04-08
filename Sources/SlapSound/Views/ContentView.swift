import SwiftUI

enum SidebarTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case history = "History"
    case sounds = "Sounds"
    case speech = "Speech"
    case keybinds = "Key Binds"
    case tonyStark = "Tony Stark"
    case themes = "Themes"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.67percent"
        case .history: return "chart.bar.fill"
        case .sounds: return "speaker.wave.3.fill"
        case .speech: return "text.bubble.fill"
        case .keybinds: return "keyboard.fill"
        case .tonyStark: return "bolt.circle.fill"
        case .themes: return "paintbrush.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: SidebarTab = .dashboard

    var body: some View {
        let t = appState.theme
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(t.primary)
                    Text("SlapSound")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(t.primary)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(appState.isConnected ? Color.green : Color.red)
                            .frame(width: 5, height: 5)
                        Text(appState.isConnected ? "Live" : "Off")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(t.secondary)
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 20)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 2) {
                        ForEach(SidebarTab.allCases) { tab in
                            Button {
                                withAnimation(.easeInOut(duration: 0.12)) { selectedTab = tab }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 11))
                                        .frame(width: 14)
                                    Text(tab.rawValue)
                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    Spacer()
                                }
                                .foregroundColor(selectedTab == tab ? t.primary : t.tertiary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedTab == tab ? t.cardBgActive : Color.clear)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                }

                Spacer()

                // Combo display
                if appState.currentCombo >= 2 {
                    Text("\(appState.currentCombo)x")
                        .font(.system(size: 20, weight: .black, design: .monospaced))
                        .foregroundColor(t.accent)
                        .padding(.bottom, 4)
                }

                // Slap count
                VStack(spacing: 2) {
                    Text("\(appState.slapCount)")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(t.primary)
                    Text("slaps")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(t.muted)
                }
                .padding(.bottom, 16)

                Button { NSApplication.shared.terminate(nil) } label: {
                    Text("Quit")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(t.muted)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.bottom, 12)
            }
            .frame(width: 165)
            .background(t.sidebarBg)

            // Content
            ZStack {
                t.contentBg.ignoresSafeArea()

                Group {
                    switch selectedTab {
                    case .dashboard: DashboardView()
                    case .history: HistoryView()
                    case .sounds: SoundsView()
                    case .speech: SpeechView()
                    case .keybinds: KeyBindsView()
                    case .tonyStark: TonyStarkView()
                    case .themes: ThemesView()
                    case .settings: SettingsView()
                    }
                }

                // Combo overlay
                ComboOverlayView()
            }
        }
        .frame(minWidth: 880, minHeight: 600)
        .preferredColorScheme(t.isDark ? .dark : .light)
    }
}
