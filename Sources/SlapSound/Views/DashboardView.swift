import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        let t = appState.theme
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Dashboard")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(t.primary)
                    Spacer()
                    HStack(spacing: 8) {
                        Circle().fill(appState.isEnabled ? Color.green : Color.red).frame(width: 6, height: 6)
                        Text(appState.isEnabled ? "Active" : "Paused")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(t.secondary)
                        Toggle("", isOn: $appState.isEnabled).toggleStyle(.switch).controlSize(.small)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 8).fill(t.cardBg))
                }

                HStack(spacing: 12) {
                    StatBox(label: "slaps", value: "\(appState.slapCount)", theme: t)
                    StatBox(label: "force", value: appState.lastSlapForce > 0 ? String(format: "%.2f", appState.lastSlapForce) : "--", theme: t)
                    StatBox(label: "sensor", value: appState.isConnected ? "on" : "off", theme: t)
                    StatBox(label: "combo", value: appState.currentCombo > 1 ? "\(appState.currentCombo)x" : "--", theme: t)
                }

                HStack(spacing: 12) {
                    SlapCircle().frame(maxWidth: .infinity).frame(height: 260)
                        .background(RoundedRectangle(cornerRadius: 12).fill(t.cardBg))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("recent")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(t.tertiary)

                        if appState.recentSlaps.isEmpty {
                            Spacer()
                            Text("no slaps yet")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(t.muted)
                                .frame(maxWidth: .infinity)
                            Spacer()
                        } else {
                            ForEach(Array(appState.recentSlaps.suffix(8).reversed().enumerated()), id: \.offset) { _, slap in
                                HStack {
                                    Rectangle().fill(t.accent.opacity(min(slap.force / 2, 1)))
                                        .frame(width: 2, height: 12)
                                    Text(String(format: "%.2fg", slap.force))
                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                        .foregroundColor(t.secondary)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(16).frame(width: 200, height: 260)
                    .background(RoundedRectangle(cornerRadius: 12).fill(t.cardBg))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("impact")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(t.tertiary)
                    ForceMeter(force: appState.lastSlapForce, theme: t)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(t.cardBg))
            }
            .padding(24)
        }
    }
}

struct StatBox: View {
    let label: String; let value: String; let theme: AppTheme
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 18, weight: .bold, design: .monospaced)).foregroundColor(theme.primary)
            Text(label).font(.system(size: 9, weight: .medium, design: .monospaced)).foregroundColor(theme.tertiary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 12).fill(theme.cardBg))
    }
}

struct SlapCircle: View {
    @EnvironmentObject var appState: AppState
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var bounce: CGFloat = 1.0

    var body: some View {
        let t = appState.theme
        ZStack {
            Circle().stroke(t.accent.opacity(0.3), lineWidth: 2).frame(width: 120, height: 120)
                .scaleEffect(ringScale).opacity(ringOpacity)
            Circle().stroke(t.border, lineWidth: 1).frame(width: 100, height: 100)
            Circle().fill(t.cardBg).frame(width: 100, height: 100).scaleEffect(bounce)
            VStack(spacing: 4) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 28))
                    .foregroundColor(t.accent.opacity(appState.isEnabled ? 0.6 : 0.15))
                if appState.lastSlapForce > 0 {
                    Text(String(format: "%.1fg", appState.lastSlapForce))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(t.secondary)
                }
            }.scaleEffect(bounce)
        }
        .onChange(of: appState.slapCount) { _, _ in
            withAnimation(.easeOut(duration: 0.4)) { ringScale = 1.5; ringOpacity = 0.6 }
            withAnimation(.easeOut(duration: 0.6)) { ringOpacity = 0 }
            withAnimation(.interpolatingSpring(stiffness: 500, damping: 8)) { bounce = 1.15 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.interpolatingSpring(stiffness: 400, damping: 12)) { bounce = 1.0 }
            }
        }
    }
}

struct ForceMeter: View {
    let force: Double; let theme: AppTheme
    @State private var width: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4).fill(theme.cardBgActive)
                RoundedRectangle(cornerRadius: 4).fill(theme.accent.opacity(0.5)).frame(width: width)
            }
            .onChange(of: force) { _, f in
                let n = min(max(f / 3.0, 0), 1)
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) { width = geo.size.width * CGFloat(n) }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.5)) { width = 0 }
                }
            }
        }.frame(height: 8)
    }
}
