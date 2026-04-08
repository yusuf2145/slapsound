import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        let t = appState.theme
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dashboard")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(t.primary)
                        Text(appState.statusMessage)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(t.muted)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Circle().fill(appState.isEnabled ? Color.green : Color.red).frame(width: 8, height: 8)
                            .shadow(color: appState.isEnabled ? .green.opacity(0.5) : .clear, radius: 4)
                        Toggle("", isOn: $appState.isEnabled).toggleStyle(.switch).controlSize(.small)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))
                }

                // Colorful stats
                HStack(spacing: 10) {
                    ColorStatBox(label: "Slaps", value: "\(appState.slapCount)", color: .blue, theme: t)
                    ColorStatBox(label: "Force", value: appState.lastSlapForce > 0 ? String(format: "%.2f", appState.lastSlapForce) : "--", color: .orange, theme: t)
                    ColorStatBox(label: "Sensor", value: appState.isConnected ? "Live" : "Off", color: appState.isConnected ? .green : .red, theme: t)
                    ColorStatBox(label: "Combo", value: appState.currentCombo > 1 ? "\(appState.currentCombo)x" : "--", color: .purple, theme: t)
                }

                // Main area
                HStack(spacing: 14) {
                    // Slap visualization
                    ZStack {
                        DashSlapCircle()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(t.cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(t.border, lineWidth: 1)
                            )
                    )

                    // Right panel
                    VStack(spacing: 12) {
                        // Mode indicator
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: appState.tonyStarkMode ? "bolt.circle.fill" : "speaker.wave.3.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(appState.tonyStarkMode ? .cyan : .orange)
                                Text(appState.tonyStarkMode ? "Tony Stark" : appState.soundMode.rawValue)
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(t.primary)
                                Spacer()
                            }
                            HStack(spacing: 6) {
                                Image(systemName: appState.speechMode ? "text.bubble.fill" : "keyboard.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(appState.speechMode ? .cyan : .orange)
                                Text(appState.speechMode ? "Speech" : "Key: \(appState.keyBinding.label)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(t.tertiary)
                                Spacer()
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))

                        // Recent
                        VStack(alignment: .leading, spacing: 6) {
                            Text("recent")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(t.tertiary)

                            if appState.recentSlaps.isEmpty {
                                VStack(spacing: 6) {
                                    Image(systemName: "hand.raised")
                                        .font(.system(size: 20))
                                        .foregroundColor(t.muted)
                                    Text("hit your mac")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(t.muted)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                ForEach(Array(appState.recentSlaps.suffix(7).reversed().enumerated()), id: \.offset) { _, slap in
                                    HStack(spacing: 8) {
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(forceColor(slap.force))
                                            .frame(width: 3, height: 12)
                                        Text(String(format: "%.2fg", slap.force))
                                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                                            .foregroundColor(t.secondary)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(12)
                        .frame(maxHeight: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))
                    }
                    .frame(width: 190)
                }
                .frame(height: 280)

                // Force meter
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("impact force")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(t.tertiary)
                        Spacer()
                        if appState.lastSlapForce > 0 {
                            Text(String(format: "%.3fg", appState.lastSlapForce))
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                        }
                    }
                    ColorForceMeter(force: appState.lastSlapForce, theme: t)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(t.cardBg))
            }
            .padding(24)
        }
    }

    private func forceColor(_ force: Double) -> Color {
        if force < 0.2 { return .green }
        if force < 0.5 { return .yellow }
        if force < 1.0 { return .orange }
        return .red
    }
}

struct ColorStatBox: View {
    let label: String; let value: String; let color: Color; let theme: AppTheme
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(theme.tertiary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.12), lineWidth: 1)
        )
    }
}

struct DashSlapCircle: View {
    @EnvironmentObject var appState: AppState
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var bounce: CGFloat = 1.0
    @State private var rotation: Double = 0

    var body: some View {
        let t = appState.theme
        ZStack {
            // Outer ring animation
            Circle()
                .stroke(
                    LinearGradient(colors: [.orange, .red, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 2.5
                )
                .frame(width: 140, height: 140)
                .scaleEffect(ringScale).opacity(ringOpacity)

            // Subtle ring
            Circle().stroke(t.border, lineWidth: 1).frame(width: 110, height: 110)

            // Inner circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.orange.opacity(0.08), t.cardBg],
                        center: .center, startRadius: 5, endRadius: 55
                    )
                )
                .frame(width: 110, height: 110)
                .scaleEffect(bounce)

            // Content
            VStack(spacing: 6) {
                Image(systemName: appState.tonyStarkMode ? "bolt.fill" : "hand.raised.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: appState.isEnabled ? [.orange, .red] : [Color.gray.opacity(0.3), Color.gray.opacity(0.15)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(rotation))

                if appState.lastSlapForce > 0 {
                    Text(String(format: "%.1fg", appState.lastSlapForce))
                        .font(.system(size: 14, weight: .heavy, design: .monospaced))
                        .foregroundColor(.orange)
                } else {
                    Text(appState.isEnabled ? "ready" : "paused")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(t.muted)
                }
            }
            .scaleEffect(bounce)
        }
        .onChange(of: appState.slapCount) { _, _ in
            // Ripple
            ringScale = 0.7; ringOpacity = 0.8
            withAnimation(.easeOut(duration: 0.5)) { ringScale = 1.6; ringOpacity = 0 }
            // Bounce
            withAnimation(.interpolatingSpring(stiffness: 500, damping: 8)) { bounce = 1.2 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.interpolatingSpring(stiffness: 400, damping: 12)) { bounce = 1.0 }
            }
            // Wiggle
            withAnimation(.interpolatingSpring(stiffness: 600, damping: 6)) { rotation = 12 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.interpolatingSpring(stiffness: 500, damping: 8)) { rotation = -8 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                withAnimation(.interpolatingSpring(stiffness: 400, damping: 12)) { rotation = 0 }
            }
        }
    }
}

struct ColorForceMeter: View {
    let force: Double; let theme: AppTheme
    @State private var width: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5).fill(theme.cardBgActive)
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .orange, .red],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: width)
                    .shadow(color: .orange.opacity(0.3), radius: 4)
            }
            .onChange(of: force) { _, f in
                let n = min(max(f / 3.0, 0), 1)
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                    width = geo.size.width * CGFloat(n)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.5)) { width = 0 }
                }
            }
        }.frame(height: 10)
    }
}
