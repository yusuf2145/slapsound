import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("SlapSound")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(appState.isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(appState.isConnected ? "Connected" : "Disconnected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Status
            if !appState.isConnected {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(appState.statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }

            // Slap counter
            HStack {
                VStack(alignment: .leading) {
                    Text("Slaps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(appState.slapCount)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
                Spacer()
                if appState.lastSlapForce > 0 {
                    VStack(alignment: .trailing) {
                        Text("Last Force")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1fg", appState.lastSlapForce))
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                }
            }

            Divider()

            // Enable toggle
            Toggle("Enabled", isOn: $appState.isEnabled)

            // Sensitivity
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Sensitivity")
                        .font(.caption)
                    Spacer()
                    Text(sensitivityLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Slider(value: $appState.sensitivity, in: 0.05...3.0, step: 0.05)
            }

            // Cooldown
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Cooldown")
                        .font(.caption)
                    Spacer()
                    Text("\(appState.cooldownMs)ms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Slider(value: cooldownBinding, in: 100...2000, step: 50)
            }

            // Volume
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Volume")
                        .font(.caption)
                    Spacer()
                    Text("\(Int(appState.masterVolume * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Slider(value: $appState.masterVolume, in: 0...1, step: 0.05)
            }

            Toggle("Scale volume with force", isOn: $appState.volumeScaling)
                .font(.caption)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(16)
        .frame(width: 280)
    }

    private var sensitivityLabel: String {
        let val = appState.sensitivity
        if val < 0.8 { return "Hair Trigger" }
        if val < 1.5 { return "Sensitive" }
        if val < 2.5 { return "Normal" }
        if val < 4.0 { return "Firm" }
        return "Hammer"
    }

    private var cooldownBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(appState.cooldownMs) },
            set: { appState.cooldownMs = Int($0) }
        )
    }
}
