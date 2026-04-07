import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with title and status
            HeaderSection()

            // Main content
            VStack(spacing: 16) {
                // Slap visualization
                SlapVisualization()

                // Stats row
                StatsRow()

                Divider()
                    .background(Color.white.opacity(0.1))

                // Controls
                ControlsSection()

                Divider()
                    .background(Color.white.opacity(0.1))

                // Bottom actions
                BottomActions()
            }
            .padding(20)
        }
        .frame(width: 320)
        .background(Color(nsColor: .windowBackgroundColor))
        .environmentObject(appState)
    }
}

// MARK: - Header

struct HeaderSection: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("SlapSound")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }

            Spacer()

            // Status pill
            HStack(spacing: 5) {
                Circle()
                    .fill(appState.isConnected ? Color.green : Color.red)
                    .frame(width: 6, height: 6)
                    .shadow(color: appState.isConnected ? .green.opacity(0.5) : .red.opacity(0.5), radius: 3)
                Text(appState.isConnected ? "Live" : "Off")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.primary.opacity(0.06))
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.primary.opacity(0.03))
    }
}

// MARK: - Slap Visualization

struct SlapVisualization: View {
    @EnvironmentObject var appState: AppState
    @State private var rippleScale: CGFloat = 0.5
    @State private var rippleOpacity: Double = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var glowIntensity: Double = 0

    var body: some View {
        ZStack {
            // Ripple rings
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.6), .red.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(rippleScale + CGFloat(i) * 0.15)
                    .opacity(rippleOpacity * (1.0 - Double(i) * 0.3))
            }

            // Center circle with force indicator
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(glowIntensity * 0.4), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)

                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: appState.isEnabled
                                ? [Color.orange.opacity(0.2), Color.red.opacity(0.15)]
                                : [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: appState.isEnabled
                                        ? [.orange.opacity(0.5), .red.opacity(0.3)]
                                        : [.gray.opacity(0.2), .gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                // Icon
                VStack(spacing: 2) {
                    Image(systemName: appState.lastSlapForce > 0 ? "hand.raised.fill" : "hand.raised")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            appState.isEnabled
                                ? LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [.gray, .gray], startPoint: .top, endPoint: .bottom)
                        )

                    if appState.lastSlapForce > 0 {
                        Text(String(format: "%.1fg", appState.lastSlapForce))
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                }
            }
            .offset(x: shakeOffset)
        }
        .frame(height: 110)
        .onChange(of: appState.slapCount) { _, _ in
            triggerSlapAnimation()
        }
    }

    private func triggerSlapAnimation() {
        // Ripple burst
        rippleScale = 0.6
        rippleOpacity = 1.0
        glowIntensity = 1.0

        withAnimation(.easeOut(duration: 0.6)) {
            rippleScale = 1.3
            rippleOpacity = 0
        }

        withAnimation(.easeOut(duration: 0.4)) {
            glowIntensity = 0
        }

        // Shake
        withAnimation(.interpolatingSpring(stiffness: 800, damping: 5)) {
            shakeOffset = 8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.interpolatingSpring(stiffness: 800, damping: 8)) {
                shakeOffset = -5
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interpolatingSpring(stiffness: 600, damping: 12)) {
                shakeOffset = 0
            }
        }
    }
}

// MARK: - Stats Row

struct StatsRow: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {
            // Slap count
            StatCard(
                icon: "number",
                label: "Slaps",
                value: "\(appState.slapCount)",
                color: .blue
            )

            Divider()
                .frame(height: 36)
                .background(Color.primary.opacity(0.1))

            // Last force
            StatCard(
                icon: "bolt.fill",
                label: "Force",
                value: appState.lastSlapForce > 0 ? String(format: "%.2fg", appState.lastSlapForce) : "--",
                color: .orange
            )

            Divider()
                .frame(height: 36)
                .background(Color.primary.opacity(0.1))

            // Status
            StatCard(
                icon: appState.isEnabled ? "waveform" : "pause.fill",
                label: "Status",
                value: appState.isEnabled ? "Active" : "Paused",
                color: appState.isEnabled ? .green : .gray
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.primary.opacity(0.04))
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color.opacity(0.7))
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

// MARK: - Controls

struct ControlsSection: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 14) {
            // Enable toggle
            HStack {
                Label("Detection", systemImage: "sensor.fill")
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Toggle("", isOn: $appState.isEnabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }

            // Sensitivity
            SliderControl(
                icon: "gauge.with.needle",
                label: "Sensitivity",
                value: $appState.sensitivity,
                range: 0.05...3.0,
                step: 0.05,
                displayValue: sensitivityLabel,
                accentColor: .orange
            )

            // Cooldown
            SliderControl(
                icon: "timer",
                label: "Cooldown",
                value: cooldownBinding,
                range: 50...2000,
                step: 50,
                displayValue: "\(appState.cooldownMs)ms",
                accentColor: .blue
            )

            // Volume
            SliderControl(
                icon: "speaker.wave.3.fill",
                label: "Volume",
                value: $appState.masterVolume,
                range: 0...1,
                step: 0.05,
                displayValue: "\(Int(appState.masterVolume * 100))%",
                accentColor: .green
            )

            // Force scaling toggle
            HStack {
                Label("Force-scaled volume", systemImage: "waveform.path.ecg")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("", isOn: $appState.volumeScaling)
                    .toggleStyle(.switch)
                    .controlSize(.mini)
            }
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

struct SliderControl: View {
    let icon: String
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let displayValue: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(accentColor.opacity(0.7))
                    .frame(width: 14)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                Spacer()
                Text(displayValue)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(accentColor.opacity(0.1))
                    )
            }
            Slider(value: $value, in: range, step: step)
                .tint(accentColor)
                .controlSize(.small)
        }
    }
}

// MARK: - Bottom Actions

struct BottomActions: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack {
            // Reset counter
            Button {
                appState.slapCount = 0
                appState.lastSlapForce = 0
                appState.settings.slapCount = 0
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 11, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)

            Spacer()

            // Quit
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
                    .font(.system(size: 11, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(.top, 2)
    }
}
