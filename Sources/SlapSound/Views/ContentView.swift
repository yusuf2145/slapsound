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

    var color: Color {
        switch self {
        case .dashboard: return .blue
        case .sounds: return .purple
        case .keybinds: return .orange
        case .tonyStark: return .red
        case .settings: return .gray
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: SidebarTab = .dashboard

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            SidebarView(selectedTab: $selectedTab)

            // Divider
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(width: 1)

            // Main content
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()

                Group {
                    switch selectedTab {
                    case .dashboard:
                        DashboardView()
                    case .sounds:
                        SoundsView()
                    case .keybinds:
                        KeyBindsView()
                    case .tonyStark:
                        TonyStarkView()
                    case .settings:
                        SettingsView()
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .frame(minWidth: 900, minHeight: 640)
    }
}

// MARK: - Sidebar

struct SidebarView: View {
    @Binding var selectedTab: SidebarTab
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // App logo area
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: .orange.opacity(0.3), radius: 8)

                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("SlapSound")
                    .font(.system(size: 14, weight: .bold, design: .rounded))

                // Connection status
                HStack(spacing: 4) {
                    Circle()
                        .fill(appState.isConnected ? Color.green : Color.red)
                        .frame(width: 6, height: 6)
                        .shadow(color: appState.isConnected ? .green.opacity(0.5) : .red.opacity(0.5), radius: 3)
                    Text(appState.isConnected ? "Sensor Live" : "No Sensor")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 20)

            Divider()
                .padding(.horizontal, 16)

            // Nav items
            VStack(spacing: 4) {
                ForEach(SidebarTab.allCases) { tab in
                    SidebarButton(tab: tab, isSelected: selectedTab == tab) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)

            Spacer()

            // Slap counter at bottom
            VStack(spacing: 4) {
                Text("\(appState.slapCount)")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                    )
                Text("Total Slaps")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)

            Divider()
                .padding(.horizontal, 16)

            // Quit
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "power")
                        .font(.system(size: 11))
                    Text("Quit")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(width: 200)
        .background(Color.primary.opacity(0.02))
    }
}

struct SidebarButton: View {
    let tab: SidebarTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? tab.color : .secondary)
                    .frame(width: 20)

                Text(tab.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)

                Spacer()

                if tab == .tonyStark {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                        .opacity(AppState.shared.tonyStarkMode ? 1 : 0)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? tab.color.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? tab.color.opacity(0.2) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
