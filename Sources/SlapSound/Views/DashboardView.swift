import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Dashboard")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                    // Toggle
                    HStack(spacing: 8) {
                        Circle()
                            .fill(appState.isEnabled ? Color.green : Color.red)
                            .frame(width: 6, height: 6)
                        Text(appState.isEnabled ? "Active" : "Paused")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        Toggle("", isOn: $appState.isEnabled)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                }

                // Stats
                HStack(spacing: 12) {
                    StatBox(label: "slaps", value: "\(appState.slapCount)")
                    StatBox(label: "force", value: appState.lastSlapForce > 0 ? String(format: "%.2f", appState.lastSlapForce) : "--")
                    StatBox(label: "sensor", value: appState.isConnected ? "on" : "off")
                    StatBox(label: "mode", value: appState.tonyStarkMode ? "stark" : appState.soundMode.rawValue.prefix(6).lowercased())
                }

                // Visual + activity
                HStack(spacing: 12) {
                    // Slap visual
                    SlapCircle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))

                    // Activity
                    VStack(alignment: .leading, spacing: 8) {
                        Text("recent")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.25))

                        if appState.recentSlaps.isEmpty {
                            VStack(spacing: 8) {
                                Spacer()
                                Text("no slaps yet")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.2))
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            ForEach(Array(appState.recentSlaps.suffix(8).reversed().enumerated()), id: \.offset) { _, slap in
                                HStack {
                                    Rectangle()
                                        .fill(slap.force < 0.3 ? Color.white.opacity(0.15) : (slap.force < 1.0 ? Color.white.opacity(0.3) : Color.white.opacity(0.5)))
                                        .frame(width: 2, height: 12)
                                    Text(String(format: "%.2fg", slap.force))
                                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.5))
                                    Spacer()
                                    Text(timeAgo(slap.timestamp))
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.2))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .frame(width: 220)
                    .frame(height: 280)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
                }

                // Force meter
                VStack(alignment: .leading, spacing: 6) {
                    Text("impact")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.25))
                    ForceMeter(force: appState.lastSlapForce)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
            }
            .padding(24)
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let s = Int(Date().timeIntervalSince(date))
        if s < 2 { return "now" }
        if s < 60 { return "\(s)s" }
        return "\(s / 60)m"
    }
}

struct StatBox: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.25))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
    }
}

struct SlapCircle: View {
    @EnvironmentObject var appState: AppState
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var bounce: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Ring
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 2)
                .frame(width: 120, height: 120)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            // Outer
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                .frame(width: 100, height: 100)

            // Inner
            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 100, height: 100)
                .scaleEffect(bounce)

            // Content
            VStack(spacing: 4) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(appState.isEnabled ? 0.6 : 0.15))
                if appState.lastSlapForce > 0 {
                    Text(String(format: "%.1fg", appState.lastSlapForce))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .scaleEffect(bounce)
        }
        .onChange(of: appState.slapCount) { _, _ in
            withAnimation(.easeOut(duration: 0.4)) {
                ringScale = 1.5
                ringOpacity = 0.6
            }
            withAnimation(.easeOut(duration: 0.6)) {
                ringOpacity = 0
            }
            withAnimation(.interpolatingSpring(stiffness: 500, damping: 8)) { bounce = 1.15 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.interpolatingSpring(stiffness: 400, damping: 12)) { bounce = 1.0 }
            }
        }
    }
}

struct ForceMeter: View {
    let force: Double
    @State private var width: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.05))
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: width)
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
        }
        .frame(height: 8)
    }
}
