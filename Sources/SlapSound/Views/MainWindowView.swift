import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case settings = "Settings"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation tabs
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.rawValue,
                        icon: tab == .dashboard ? "gauge.with.dots.needle.67percent" : "gearshape.fill",
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primary.opacity(0.04))
            )
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Content
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardTab()
                case .settings:
                    SettingsTab()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 480, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
            )
            .foregroundColor(isSelected ? .accentColor : .secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Dashboard Tab

struct DashboardTab: View {
    @EnvironmentObject var appState: AppState
    @State private var animatePulse = false

    var body: some View {
        VStack(spacing: 24) {
            // Big slap visualization
            BigSlapVisual()

            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                DashStatCard(
                    icon: "number.circle.fill",
                    title: "Total Slaps",
                    value: "\(appState.slapCount)",
                    color: .blue
                )
                DashStatCard(
                    icon: "bolt.circle.fill",
                    title: "Last Force",
                    value: appState.lastSlapForce > 0 ? String(format: "%.2fg", appState.lastSlapForce) : "--",
                    color: .orange
                )
                DashStatCard(
                    icon: "antenna.radiowaves.left.and.right.circle.fill",
                    title: "Sensor",
                    value: appState.isConnected ? "Online" : "Offline",
                    color: appState.isConnected ? .green : .red
                )
            }

            // Force meter bar
            VStack(alignment: .leading, spacing: 8) {
                Text("IMPACT FORCE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)

                ForceMeterBar(force: appState.lastSlapForce)
            }
            .padding(.horizontal, 4)

            Spacer()
        }
        .padding(24)
    }
}

// MARK: - Big Slap Visual

struct BigSlapVisual: View {
    @EnvironmentObject var appState: AppState
    @State private var ripples: [CGFloat] = [0.6, 0.6, 0.6]
    @State private var rippleOpacities: [Double] = [0, 0, 0]
    @State private var bounce: CGFloat = 1.0
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Ripple rings
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.orange, .red.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5 - CGFloat(i) * 0.5
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(ripples[i])
                    .opacity(rippleOpacities[i])
            }

            // Center orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .orange.opacity(0.25),
                            .red.opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 55
                    )
                )
                .frame(width: 110, height: 110)

            Circle()
                .fill(
                    LinearGradient(
                        colors: appState.isEnabled
                            ? [Color.orange.opacity(0.15), Color.red.opacity(0.1)]
                            : [Color.gray.opacity(0.08), Color.gray.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: appState.isEnabled
                                    ? [.orange.opacity(0.4), .red.opacity(0.2)]
                                    : [.gray.opacity(0.15), .gray.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .scaleEffect(bounce)

            // Center content
            VStack(spacing: 4) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(
                        appState.isEnabled
                            ? LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                            : LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                    )
                    .rotationEffect(.degrees(rotation))

                if appState.lastSlapForce > 0 {
                    Text(String(format: "%.1fg", appState.lastSlapForce))
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(.orange)
                }
            }
            .scaleEffect(bounce)
        }
        .frame(height: 130)
        .onChange(of: appState.slapCount) { _, _ in
            triggerAnimation()
        }
    }

    private func triggerAnimation() {
        // Staggered ripple burst
        for i in 0..<3 {
            let delay = Double(i) * 0.08
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                ripples[i] = 0.7
                rippleOpacities[i] = 0.8

                withAnimation(.easeOut(duration: 0.5)) {
                    ripples[i] = 1.6 + CGFloat(i) * 0.15
                    rippleOpacities[i] = 0
                }
            }
        }

        // Bounce
        withAnimation(.interpolatingSpring(stiffness: 500, damping: 8)) {
            bounce = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interpolatingSpring(stiffness: 400, damping: 10)) {
                bounce = 0.9
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 12)) {
                bounce = 1.0
            }
        }

        // Wiggle rotation
        withAnimation(.interpolatingSpring(stiffness: 600, damping: 6)) {
            rotation = 12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.interpolatingSpring(stiffness: 500, damping: 8)) {
                rotation = -8
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.interpolatingSpring(stiffness: 400, damping: 12)) {
                rotation = 0
            }
        }
    }
}

// MARK: - Force Meter Bar

struct ForceMeterBar: View {
    let force: Double
    @State private var animatedWidth: CGFloat = 0

    private var normalizedForce: Double {
        min(max(force / 3.0, 0), 1.0)
    }

    private var forceColor: Color {
        if normalizedForce < 0.3 { return .green }
        if normalizedForce < 0.6 { return .orange }
        return .red
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.06))

                // Filled portion
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: animatedWidth)
                    .shadow(color: forceColor.opacity(0.4), radius: 4, x: 0, y: 0)

                // Segment markers
                HStack(spacing: 0) {
                    ForEach(0..<10, id: \.self) { i in
                        Rectangle()
                            .fill(Color.primary.opacity(0.08))
                            .frame(width: 1)
                            .frame(maxHeight: .infinity)
                        if i < 9 {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            .onChange(of: force) { _, newForce in
                let normalized = min(max(newForce / 3.0, 0), 1.0)
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                    animatedWidth = geo.size.width * CGFloat(normalized)
                }
                // Decay back to zero
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        animatedWidth = 0
                    }
                }
            }
        }
        .frame(height: 14)
    }
}

// MARK: - Dashboard Stat Card

struct DashStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))

            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Settings Tab

struct SettingsTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Detection section
                SettingsSection(title: "DETECTION", icon: "sensor.fill") {
                    VStack(spacing: 16) {
                        HStack {
                            Label("Enabled", systemImage: "power")
                                .font(.system(size: 13))
                            Spacer()
                            Toggle("", isOn: $appState.isEnabled)
                                .toggleStyle(.switch)
                                .controlSize(.small)
                        }

                        VStack(spacing: 6) {
                            HStack {
                                Text("Sensitivity")
                                    .font(.system(size: 13))
                                Spacer()
                                Text(sensitivityLabel)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                            Slider(value: $appState.sensitivity, in: 0.05...3.0, step: 0.05)
                                .tint(.orange)
                            HStack {
                                Text("Hair Trigger")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Hammer")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                        }

                        VStack(spacing: 6) {
                            HStack {
                                Text("Cooldown")
                                    .font(.system(size: 13))
                                Spacer()
                                Text("\(appState.cooldownMs)ms")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(.blue)
                            }
                            Slider(value: cooldownBinding, in: 50...2000, step: 50)
                                .tint(.blue)
                            HStack {
                                Text("Fast")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Slow")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // Audio section
                SettingsSection(title: "AUDIO", icon: "speaker.wave.3.fill") {
                    VStack(spacing: 16) {
                        VStack(spacing: 6) {
                            HStack {
                                Text("Master Volume")
                                    .font(.system(size: 13))
                                Spacer()
                                Text("\(Int(appState.masterVolume * 100))%")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(.green)
                            }
                            Slider(value: $appState.masterVolume, in: 0...1, step: 0.05)
                                .tint(.green)
                        }

                        HStack {
                            Label("Scale volume with force", systemImage: "waveform.path.ecg")
                                .font(.system(size: 13))
                            Spacer()
                            Toggle("", isOn: $appState.volumeScaling)
                                .toggleStyle(.switch)
                                .controlSize(.small)
                        }
                    }
                }

                // Info section
                SettingsSection(title: "INFO", icon: "info.circle.fill") {
                    VStack(spacing: 10) {
                        InfoRow(label: "Sensor", value: appState.isConnected ? "Connected" : "Not found")
                        InfoRow(label: "Key Press", value: "1")
                        InfoRow(label: "Sound", value: "whipcrack.mp3")
                        InfoRow(label: "Version", value: "1.0.0")
                    }
                }

                // Actions
                HStack(spacing: 12) {
                    Button {
                        appState.slapCount = 0
                        appState.lastSlapForce = 0
                        appState.settings.slapCount = 0
                    } label: {
                        Label("Reset Counter", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Label("Quit App", systemImage: "power")
                            .font(.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding(24)
        }
    }

    private var sensitivityLabel: String {
        let val = appState.sensitivity
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

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
            }

            VStack {
                content()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
        }
    }
}
