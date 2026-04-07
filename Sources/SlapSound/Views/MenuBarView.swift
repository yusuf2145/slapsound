import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                        )
                    Text("SlapSound")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(appState.isConnected ? Color.green : Color.red)
                        .frame(width: 6, height: 6)
                    Text(appState.isConnected ? "Live" : "Off")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.primary.opacity(0.05)))
            }

            Divider()

            // Quick stats
            HStack(spacing: 0) {
                MiniStat(icon: "number", value: "\(appState.slapCount)", label: "Slaps", color: .blue)
                Divider().frame(height: 30)
                MiniStat(icon: "bolt.fill", value: appState.lastSlapForce > 0 ? String(format: "%.1f", appState.lastSlapForce) : "--", label: "Force", color: .orange)
                Divider().frame(height: 30)
                MiniStat(icon: "speaker.wave.2.fill", value: "\(Int(appState.masterVolume * 100))%", label: "Vol", color: .green)
            }
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.03)))

            // Toggle
            HStack {
                Text("Detection")
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Toggle("", isOn: $appState.isEnabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }

            // Tony Stark indicator
            if appState.tonyStarkMode {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.circle.fill")
                        .foregroundColor(.red)
                    Text("Tony Stark Mode Active")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.red.opacity(0.08)))
            }

            // Sound mode
            HStack {
                Text("Sound")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                Text(appState.tonyStarkMode ? "J.A.R.V.I.S." : appState.soundMode.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(appState.tonyStarkMode ? .cyan : .purple)
            }

            // Key binding
            HStack {
                Text("Key Press")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                Text(appState.keyBinding.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.orange)
            }

            Divider()

            // Open main window
            Button {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first(where: { $0.title.contains("SlapSound") || $0.contentView != nil }) {
                    window.makeKeyAndOrderFront(nil)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "macwindow")
                    Text("Open Dashboard")
                }
                .font(.system(size: 11, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.accentColor.opacity(0.1)))
            }
            .buttonStyle(.plain)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(width: 260)
    }
}

struct MiniStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color.opacity(0.7))
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
