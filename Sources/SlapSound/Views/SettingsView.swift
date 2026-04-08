import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        let t = appState.theme
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(t.primary)
                    Spacer()
                }

                SCard(title: "detection", theme: t) {
                    SRow(label: "enabled", theme: t) {
                        Toggle("", isOn: $appState.isEnabled).toggleStyle(.switch).controlSize(.small)
                    }
                    Divider().background(t.border)
                    VStack(spacing: 4) {
                        HStack {
                            Text("sensitivity").font(.system(size: 12, design: .monospaced)).foregroundColor(t.secondary)
                            Spacer()
                            Text(String(format: "%.3fg", appState.sensitivity))
                                .font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(t.primary)
                        }
                        Slider(value: $appState.sensitivity, in: 0.02...2.0, step: 0.01).tint(t.accent)
                    }
                    Divider().background(t.border)
                    VStack(spacing: 4) {
                        HStack {
                            Text("cooldown").font(.system(size: 12, design: .monospaced)).foregroundColor(t.secondary)
                            Spacer()
                            Text("\(appState.cooldownMs)ms").font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(t.primary)
                        }
                        Slider(value: cooldownBinding, in: 50...2000, step: 25).tint(t.accent)
                    }
                }

                SCard(title: "audio", theme: t) {
                    VStack(spacing: 4) {
                        HStack {
                            Text("volume").font(.system(size: 12, design: .monospaced)).foregroundColor(t.secondary)
                            Spacer()
                            Text("\(Int(appState.masterVolume * 100))%").font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(t.primary)
                        }
                        Slider(value: $appState.masterVolume, in: 0...1, step: 0.05).tint(t.accent)
                    }
                    Divider().background(t.border)
                    SRow(label: "force scaling", theme: t) {
                        Toggle("", isOn: $appState.volumeScaling).toggleStyle(.switch).controlSize(.small)
                    }
                }

                SCard(title: "combos", theme: t) {
                    SRow(label: "enabled", theme: t) {
                        Toggle("", isOn: $appState.combosEnabled).toggleStyle(.switch).controlSize(.small)
                    }
                    Divider().background(t.border)
                    VStack(spacing: 4) {
                        HStack {
                            Text("timeout").font(.system(size: 12, design: .monospaced)).foregroundColor(t.secondary)
                            Spacer()
                            Text(String(format: "%.1fs", appState.comboDetector.timeout))
                                .font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(t.primary)
                        }
                        Slider(value: Binding(
                            get: { appState.comboDetector.timeout },
                            set: { appState.comboDetector.timeout = $0; appState.settings.comboTimeout = $0 }
                        ), in: 1...5, step: 0.5).tint(t.accent)
                    }
                }

                SCard(title: "sensor", theme: t) {
                    SRow(label: "status", val: appState.isConnected ? "connected" : "not found", theme: t)
                    Divider().background(t.border)
                    SRow(label: "type", val: "IMU accelerometer", theme: t)
                    Divider().background(t.border)
                    SRow(label: "rate", val: "~800 Hz", theme: t)
                    Divider().background(t.border)
                    SRow(label: "requires", val: "M1 Pro+ MacBook", theme: t)
                }

                HStack(spacing: 12) {
                    Button {
                        appState.slapCount = 0; appState.lastSlapForce = 0
                        appState.recentSlaps.removeAll(); appState.settings.slapCount = 0
                    } label: {
                        Text("reset counters")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(t.secondary).frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(t.cardBg))
                    }.buttonStyle(.plain)

                    Button { NSApplication.shared.terminate(nil) } label: {
                        Text("quit app")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.red.opacity(0.6)).frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.05)))
                    }.buttonStyle(.plain)
                }

                Text("SlapSound v2.4.0 — a product by agaro.ai")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(t.muted)
                    .padding(.top, 8)
            }
            .padding(24)
        }
    }

    private var cooldownBinding: Binding<Double> {
        Binding(get: { Double(appState.cooldownMs) }, set: { appState.cooldownMs = Int($0) })
    }
}

struct SCard<Content: View>: View {
    let title: String; let theme: AppTheme; @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(theme.tertiary)
            VStack(spacing: 12) { content() }
                .padding(16).background(RoundedRectangle(cornerRadius: 10).fill(theme.cardBg))
        }
    }
}

struct SRow<Content: View>: View {
    let label: String; var val: String? = nil; let theme: AppTheme; @ViewBuilder let content: () -> Content
    var body: some View {
        HStack {
            Text(label).font(.system(size: 12, design: .monospaced)).foregroundColor(theme.secondary)
            Spacer()
            if let v = val { Text(v).font(.system(size: 12, weight: .medium, design: .monospaced)).foregroundColor(theme.primary) }
            content()
        }
    }
}

extension SRow where Content == EmptyView {
    init(label: String, val: String, theme: AppTheme) {
        self.label = label; self.val = val; self.theme = theme; self.content = { EmptyView() }
    }
}
