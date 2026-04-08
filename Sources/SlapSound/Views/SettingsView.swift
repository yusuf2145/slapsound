import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                }

                // Detection
                SettingsCard(title: "detection") {
                    SettingsRow(label: "enabled") {
                        Toggle("", isOn: $appState.isEnabled)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    Divider().background(Color.white.opacity(0.05))

                    VStack(spacing: 4) {
                        HStack {
                            Text("sensitivity")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text(String(format: "%.3fg", appState.sensitivity))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        Slider(value: $appState.sensitivity, in: 0.02...2.0, step: 0.01)
                            .tint(.white)
                        HStack {
                            Text("ultra sensitive")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.white.opacity(0.15))
                            Spacer()
                            Text("firm")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.white.opacity(0.15))
                        }
                    }

                    Divider().background(Color.white.opacity(0.05))

                    VStack(spacing: 4) {
                        HStack {
                            Text("cooldown")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text("\(appState.cooldownMs)ms")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        Slider(value: cooldownBinding, in: 50...2000, step: 25)
                            .tint(.white)
                    }
                }

                // Audio
                SettingsCard(title: "audio") {
                    VStack(spacing: 4) {
                        HStack {
                            Text("volume")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text("\(Int(appState.masterVolume * 100))%")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        Slider(value: $appState.masterVolume, in: 0...1, step: 0.05)
                            .tint(.white)
                    }

                    Divider().background(Color.white.opacity(0.05))

                    SettingsRow(label: "force scaling") {
                        Toggle("", isOn: $appState.volumeScaling)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                }

                // Sensor
                SettingsCard(title: "sensor") {
                    SettingsRow(label: "status", value: appState.isConnected ? "connected" : "not found")
                    Divider().background(Color.white.opacity(0.05))
                    SettingsRow(label: "type", value: "IMU accelerometer")
                    Divider().background(Color.white.opacity(0.05))
                    SettingsRow(label: "rate", value: "~800 Hz")
                    Divider().background(Color.white.opacity(0.05))
                    SettingsRow(label: "requires", value: "M1 Pro+ MacBook")
                }

                // Actions
                HStack(spacing: 12) {
                    Button {
                        appState.slapCount = 0
                        appState.lastSlapForce = 0
                        appState.recentSlaps.removeAll()
                        appState.settings.slapCount = 0
                    } label: {
                        Text("reset counters")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                    }
                    .buttonStyle(.plain)

                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Text("quit app")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.red.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.05)))
                    }
                    .buttonStyle(.plain)
                }

                // About
                VStack(spacing: 4) {
                    Text("SlapSound v2.1.0")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.white.opacity(0.15))
                    Text("a product by agaro.ai")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.white.opacity(0.1))
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
    }

    private var cooldownBinding: Binding<Double> {
        Binding(get: { Double(appState.cooldownMs) }, set: { appState.cooldownMs = Int($0) })
    }
}

struct SettingsCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.2))
            VStack(spacing: 12) {
                content()
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))
        }
    }
}

struct SettingsRow<Content: View>: View {
    let label: String
    var value: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            if let value = value {
                Text(value)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }
            content()
        }
    }
}

extension SettingsRow where Content == EmptyView {
    init(label: String, value: String) {
        self.label = label
        self.value = value
        self.content = { EmptyView() }
    }
}
