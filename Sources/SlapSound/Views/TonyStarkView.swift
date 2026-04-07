import SwiftUI

struct TonyStarkView: View {
    @EnvironmentObject var appState: AppState
    @State private var arcReactorPulse: CGFloat = 1.0
    @State private var arcReactorGlow: Double = 0.3
    @State private var showActivation = false
    @State private var particleRotation: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("Tony Stark Mode")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            if appState.tonyStarkMode {
                                Text("ACTIVE")
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color.red.opacity(0.12)))
                            }
                        }
                        Text("Transform your MacBook into J.A.R.V.I.S.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                // Arc Reactor visualization
                ZStack {
                    // Dark background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black.opacity(0.85))
                        .frame(height: 320)

                    // Stars
                    ForEach(0..<20, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                            .frame(width: CGFloat.random(in: 1...3))
                            .offset(
                                x: CGFloat.random(in: -250...250),
                                y: CGFloat.random(in: -140...140)
                            )
                    }

                    VStack(spacing: 24) {
                        // Arc reactor
                        ZStack {
                            // Outer glow
                            if appState.tonyStarkMode {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [.cyan.opacity(arcReactorGlow), .blue.opacity(arcReactorGlow * 0.5), .clear],
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 100
                                        )
                                    )
                                    .frame(width: 200, height: 200)
                                    .scaleEffect(arcReactorPulse)

                                // Rotating energy ring
                                Circle()
                                    .trim(from: 0.0, to: 0.3)
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(particleRotation))

                                Circle()
                                    .trim(from: 0.5, to: 0.7)
                                    .stroke(Color.cyan.opacity(0.2), lineWidth: 1.5)
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(-particleRotation * 0.7))
                            }

                            // Outer ring
                            Circle()
                                .stroke(
                                    appState.tonyStarkMode ? Color.cyan.opacity(0.4) : Color.gray.opacity(0.2),
                                    lineWidth: 3
                                )
                                .frame(width: 90, height: 90)

                            // Inner segments
                            ForEach(0..<8, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(appState.tonyStarkMode ? Color.cyan.opacity(0.3) : Color.gray.opacity(0.1))
                                    .frame(width: 3, height: 15)
                                    .offset(y: -34)
                                    .rotationEffect(.degrees(Double(i) * 45))
                            }

                            // Core triangle
                            Triangle()
                                .fill(
                                    appState.tonyStarkMode
                                        ? LinearGradient(colors: [.cyan, .white], startPoint: .top, endPoint: .bottom)
                                        : LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 30, height: 30)
                                .rotationEffect(.degrees(180))

                            // Center dot
                            Circle()
                                .fill(appState.tonyStarkMode ? Color.white : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .shadow(color: appState.tonyStarkMode ? .cyan : .clear, radius: 8)
                        }

                        // Label
                        VStack(spacing: 4) {
                            Text(appState.tonyStarkMode ? "J.A.R.V.I.S. ONLINE" : "J.A.R.V.I.S. OFFLINE")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(appState.tonyStarkMode ? .cyan : .gray)
                                .tracking(3)

                            if appState.tonyStarkMode {
                                Text("\"At your service, sir.\"")
                                    .font(.system(size: 12, design: .serif))
                                    .italic()
                                    .foregroundColor(.cyan.opacity(0.6))
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            appState.tonyStarkMode ? Color.cyan.opacity(0.3) : Color.primary.opacity(0.06),
                            lineWidth: appState.tonyStarkMode ? 2 : 1
                        )
                )

                // Activation button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        appState.tonyStarkMode.toggle()
                    }
                    if appState.tonyStarkMode {
                        startReactorAnimation()
                    } else {
                        stopReactorAnimation()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: appState.tonyStarkMode ? "bolt.circle.fill" : "bolt.circle")
                            .font(.system(size: 18))
                        Text(appState.tonyStarkMode ? "Deactivate Tony Stark Mode" : "Activate Tony Stark Mode")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(appState.tonyStarkMode ? .white : .red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(appState.tonyStarkMode ? Color.red : Color.red.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                // Sound preview buttons
                Text("PREVIEW SOUNDS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    Button {
                        appState.previewJarvis()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 11))
                            Text("J.A.R.V.I.S. Beep")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.cyan.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        appState.previewJarvisStartup()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 11))
                            Text("Startup Sound")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }

                // Feature description
                VStack(spacing: 16) {
                    Text("WHAT TONY STARK MODE DOES")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .tracking(1.5)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        FeatureCard(
                            icon: "speaker.wave.3.fill",
                            title: "J.A.R.V.I.S. Sounds",
                            description: "Replaces slap sounds with sci-fi J.A.R.V.I.S. beeps and tones",
                            color: .cyan
                        )
                        FeatureCard(
                            icon: "power",
                            title: "Startup Sound",
                            description: "Plays an arc reactor power-up sequence when activated",
                            color: .red
                        )
                        FeatureCard(
                            icon: "hands.clap.fill",
                            title: "Double Clap",
                            description: "Clap twice to open Terminal with Claude Code + play Iron Man soundtrack",
                            color: .orange
                        )
                        FeatureCard(
                            icon: "bolt.fill",
                            title: "Visual Mode",
                            description: "Dashboard changes to a glowing arc reactor theme",
                            color: .yellow
                        )
                    }
                }
            }
            .padding(32)
        }
        .onAppear {
            if appState.tonyStarkMode {
                startReactorAnimation()
            }
        }
    }

    private func startReactorAnimation() {
        // Pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            arcReactorPulse = 1.1
            arcReactorGlow = 0.5
        }
        // Rotate
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            particleRotation = 360
        }
    }

    private func stopReactorAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            arcReactorPulse = 1.0
            arcReactorGlow = 0
            particleRotation = 0
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
            Text(description)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

// Triangle shape for arc reactor core
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
