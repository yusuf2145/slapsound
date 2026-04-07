import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Page header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dashboard")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text("Real-time slap detection and monitoring")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()

                    // Master toggle
                    HStack(spacing: 10) {
                        Text(appState.isEnabled ? "Active" : "Paused")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(appState.isEnabled ? .green : .secondary)
                        Toggle("", isOn: $appState.isEnabled)
                            .toggleStyle(.switch)
                            .controlSize(.regular)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(appState.isEnabled ? Color.green.opacity(0.08) : Color.primary.opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(appState.isEnabled ? Color.green.opacity(0.2) : Color.primary.opacity(0.06), lineWidth: 1)
                    )
                }

                // Stats cards row
                HStack(spacing: 16) {
                    DashCard(
                        icon: "number.circle.fill",
                        title: "Total Slaps",
                        value: "\(appState.slapCount)",
                        subtitle: "all time",
                        color: .blue
                    )
                    DashCard(
                        icon: "bolt.circle.fill",
                        title: "Last Force",
                        value: appState.lastSlapForce > 0 ? String(format: "%.2f", appState.lastSlapForce) : "--",
                        subtitle: "g-force",
                        color: .orange
                    )
                    DashCard(
                        icon: "antenna.radiowaves.left.and.right.circle.fill",
                        title: "Sensor",
                        value: appState.isConnected ? "Online" : "Offline",
                        subtitle: appState.isConnected ? "accelerometer" : "not found",
                        color: appState.isConnected ? .green : .red
                    )
                    DashCard(
                        icon: "speaker.wave.3.fill",
                        title: "Sound",
                        value: appState.tonyStarkMode ? "J.A.R.V.I.S." : appState.soundMode.rawValue,
                        subtitle: appState.tonyStarkMode ? "tony stark mode" : "current mode",
                        color: appState.tonyStarkMode ? .red : .purple
                    )
                }

                // Main visualization area
                HStack(spacing: 16) {
                    // Big slap visual
                    DashSlapVisual()
                        .frame(maxWidth: .infinity)

                    // Force meter + recent activity
                    VStack(spacing: 16) {
                        // Force meter
                        VStack(alignment: .leading, spacing: 10) {
                            Text("IMPACT FORCE")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .tracking(1.5)

                            DashForceMeter(force: appState.lastSlapForce)

                            HStack {
                                Text("Light")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Medium")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Heavy")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.primary.opacity(0.03))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )

                        // Recent slaps
                        VStack(alignment: .leading, spacing: 10) {
                            Text("RECENT ACTIVITY")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .tracking(1.5)

                            if appState.recentSlaps.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "hand.raised")
                                            .font(.system(size: 24))
                                            .foregroundColor(.secondary.opacity(0.5))
                                        Text("No slaps yet")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                        Text("Give your MacBook a whack!")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary.opacity(0.6))
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                            } else {
                                ForEach(appState.recentSlaps.suffix(5).reversed().indices, id: \.self) { i in
                                    let slap = appState.recentSlaps.suffix(5).reversed()[i]
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(forceColor(slap.force))
                                            .frame(width: 8, height: 8)
                                        Text(String(format: "%.2fg", slap.force))
                                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                        Spacer()
                                        Text(timeAgo(slap.timestamp))
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }
                                    if i < 4 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.primary.opacity(0.03))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                    }
                    .frame(width: 260)
                }
            }
            .padding(32)
        }
    }

    private func forceColor(_ force: Double) -> Color {
        if force < 0.3 { return .green }
        if force < 1.0 { return .orange }
        return .red
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 2 { return "just now" }
        if seconds < 60 { return "\(seconds)s ago" }
        return "\(seconds / 60)m ago"
    }
}

// MARK: - Dashboard Card

struct DashCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - Dashboard Slap Visual

struct DashSlapVisual: View {
    @EnvironmentObject var appState: AppState
    @State private var ripples: [CGFloat] = [0.5, 0.5, 0.5, 0.5]
    @State private var rippleOpacities: [Double] = [0, 0, 0, 0]
    @State private var bounce: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var glowRadius: CGFloat = 0

    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.orange.opacity(0.08), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .scaleEffect(1.0 + glowRadius * 0.3)

            // Ripple rings
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.6), .red.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3 - CGFloat(i) * 0.5
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(ripples[i])
                    .opacity(rippleOpacities[i])
            }

            // Outer ring
            Circle()
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                .frame(width: 140, height: 140)

            // Inner filled circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: appState.isEnabled
                            ? [Color.orange.opacity(0.12), Color.red.opacity(0.08)]
                            : [Color.gray.opacity(0.06), Color.gray.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: appState.isEnabled
                                    ? [.orange.opacity(0.3), .red.opacity(0.15)]
                                    : [.gray.opacity(0.1), .gray.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .scaleEffect(bounce)

            // Content
            VStack(spacing: 6) {
                Image(systemName: appState.tonyStarkMode ? "bolt.fill" : "hand.raised.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(
                        appState.isEnabled
                            ? (appState.tonyStarkMode
                                ? LinearGradient(colors: [.red, .yellow], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                            : LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                    )
                    .rotationEffect(.degrees(rotation))

                if appState.lastSlapForce > 0 {
                    Text(String(format: "%.1fg", appState.lastSlapForce))
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.orange)
                } else {
                    Text(appState.isEnabled ? "Ready" : "Paused")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .scaleEffect(bounce)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.primary.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .onChange(of: appState.slapCount) { _, _ in
            triggerAnimation()
        }
    }

    private func triggerAnimation() {
        // Staggered ripples
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.06) {
                ripples[i] = 0.6
                rippleOpacities[i] = 0.9
                withAnimation(.easeOut(duration: 0.6)) {
                    ripples[i] = 1.8 + CGFloat(i) * 0.2
                    rippleOpacities[i] = 0
                }
            }
        }

        // Glow
        glowRadius = 1
        withAnimation(.easeOut(duration: 0.5)) { glowRadius = 0 }

        // Bounce
        withAnimation(.interpolatingSpring(stiffness: 500, damping: 8)) { bounce = 1.25 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interpolatingSpring(stiffness: 400, damping: 10)) { bounce = 0.9 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 12)) { bounce = 1.0 }
        }

        // Wiggle
        withAnimation(.interpolatingSpring(stiffness: 600, damping: 6)) { rotation = 15 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.interpolatingSpring(stiffness: 500, damping: 8)) { rotation = -10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.interpolatingSpring(stiffness: 400, damping: 12)) { rotation = 0 }
        }
    }
}

// MARK: - Force Meter

struct DashForceMeter: View {
    let force: Double
    @State private var animatedWidth: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.06))

                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: animatedWidth)
                    .shadow(color: .orange.opacity(0.3), radius: 6)

                // Tick marks
                HStack(spacing: 0) {
                    ForEach(0..<20, id: \.self) { i in
                        Rectangle()
                            .fill(Color.primary.opacity(0.06))
                            .frame(width: 1)
                            .frame(maxHeight: .infinity)
                        if i < 19 { Spacer() }
                    }
                }
                .padding(.horizontal, 2)
            }
            .onChange(of: force) { _, newForce in
                let normalized = min(max(newForce / 3.0, 0), 1.0)
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                    animatedWidth = geo.size.width * CGFloat(normalized)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        animatedWidth = 0
                    }
                }
            }
        }
        .frame(height: 20)
    }
}
