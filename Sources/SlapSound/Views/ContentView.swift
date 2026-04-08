import SwiftUI

enum SidebarTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case sounds = "Sounds"
    case keybinds = "Key Binds"
    case tonyStark = "Tony Stark"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.67percent"
        case .sounds: return "speaker.wave.3.fill"
        case .keybinds: return "keyboard.fill"
        case .tonyStark: return "bolt.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: SidebarTab = .dashboard

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 0) {
                // Logo
                VStack(spacing: 6) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("SlapSound")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(appState.isConnected ? Color.green : Color.red)
                            .frame(width: 5, height: 5)
                        Text(appState.isConnected ? "Live" : "Off")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 20)

                // Nav
                VStack(spacing: 2) {
                    ForEach(SidebarTab.allCases) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.12)) { selectedTab = tab }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 12))
                                    .frame(width: 16)
                                Text(tab.rawValue)
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                Spacer()
                            }
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.35))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(selectedTab == tab ? Color.white.opacity(0.1) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)

                Spacer()

                // Slap count
                VStack(spacing: 2) {
                    Text("\(appState.slapCount)")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    Text("slaps")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.bottom, 16)

                // Quit
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Text("Quit")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.25))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.bottom, 12)
            }
            .frame(width: 170)
            .background(Color.black)

            // Content
            ZStack {
                Color(white: 0.06).ignoresSafeArea()

                Group {
                    switch selectedTab {
                    case .dashboard: DashboardView()
                    case .sounds: SoundsView()
                    case .keybinds: KeyBindsView()
                    case .tonyStark: TonyStarkView()
                    case .settings: SettingsView()
                    }
                }
            }
        }
        .frame(minWidth: 860, minHeight: 580)
        .preferredColorScheme(.dark)
    }
}
