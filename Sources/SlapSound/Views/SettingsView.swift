import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text("Fine-tune your slap detection experience")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                // Detection settings
                SettingsSection2(title: "DETECTION", icon: "sensor.fill", color: .orange) {
                    VStack(spacing: 20) {
                        // Master toggle
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Slap Detection")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Enable or disable impact detection")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $appState.isEnabled)
                                .toggleStyle(.switch)
                        }

                        Divider()

                        // Sensitivity
                        VStack(spacing: 8) {
                            HStack {
                                Text("Sensitivity")
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                                Text(sensitivityLabel)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.orange.opacity(0.1)))
                            }
                            Slider(value: $appState.sensitivity, in: 0.02...3.0, step: 0.01)
                                .tint(.orange)
                            HStack {
                                Text("Ultra Sensitive")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Requires Force")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                            Text("Current threshold: \(String(format: "%.2f", appState.sensitivity))g")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        // Cooldown
                        VStack(spacing: 8) {
                            HStack {
                                Text("Cooldown")
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                                Text("\(appState.cooldownMs)ms")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.blue.opacity(0.1)))
                            }
                            Slider(value: cooldownBinding, in: 50...2000, step: 25)
                                .tint(.blue)
                            HStack {
                                Text("Rapid Fire (50ms)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Slow (2000ms)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // Sensor info
                SettingsSection2(title: "SENSOR STATUS", icon: "cpu", color: .green) {
                    VStack(spacing: 12) {
                        InfoRow2(label: "Connection", value: appState.isConnected ? "Connected" : "Not Found", color: appState.isConnected ? .green : .red)
                        Divider()
                        InfoRow2(label: "Sensor Type", value: "IMU Accelerometer", color: .secondary)
                        Divider()
                        InfoRow2(label: "Interface", value: "IOKit HID", color: .secondary)
                        Divider()
                        InfoRow2(label: "Sample Rate", value: "~800 Hz", color: .secondary)
                        Divider()
                        InfoRow2(label: "Report Size", value: "22 bytes", color: .secondary)
                        Divider()
                        InfoRow2(label: "Requires", value: "Apple Silicon M1 Pro+", color: .secondary)
                    }
                }

                // App info
                SettingsSection2(title: "ABOUT", icon: "info.circle.fill", color: .purple) {
                    VStack(spacing: 12) {
                        InfoRow2(label: "App", value: "SlapSound", color: .secondary)
                        Divider()
                        InfoRow2(label: "Version", value: "2.0.0", color: .secondary)
                        Divider()
                        InfoRow2(label: "Runtime", value: "sudo (root)", color: .orange)
                        Divider()

                        // Reset button
                        Button {
                            appState.slapCount = 0
                            appState.lastSlapForce = 0
                            appState.recentSlaps.removeAll()
                            appState.settings.slapCount = 0
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset All Counters")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.red)
                    }
                }
            }
            .padding(32)
        }
    }

    private var sensitivityLabel: String {
        let val = appState.sensitivity
        if val < 0.05 { return "Ultra" }
        if val < 0.15 { return "Hair Trigger" }
        if val < 0.5 { return "Sensitive" }
        if val < 1.5 { return "Normal" }
        if val < 2.5 { return "Firm" }
        return "Hammer"
    }

    private var cooldownBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(appState.cooldownMs) },
            set: { appState.cooldownMs = Int($0) }
        )
    }
}

struct SettingsSection2<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
            }

            VStack {
                content()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
    }
}

struct InfoRow2: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(color == .secondary ? .primary : color)
        }
    }
}
