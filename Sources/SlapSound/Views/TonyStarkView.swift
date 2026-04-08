import SwiftUI

struct TonyStarkView: View {
    @EnvironmentObject var appState: AppState
    @State private var pulseScale: CGFloat = 1.0
    @State private var ringRotation: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Tony Stark Mode")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    if appState.tonyStarkMode {
                        Text("ON")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.white))
                    }
                    Spacer()
                }

                // Arc reactor
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .frame(height: 260)

                    ZStack {
                        if appState.tonyStarkMode {
                            // Glow
                            Circle()
                                .fill(RadialGradient(colors: [.white.opacity(0.08), .clear], center: .center, startRadius: 10, endRadius: 80))
                                .frame(width: 160, height: 160)
                                .scaleEffect(pulseScale)

                            // Spinning ring
                            Circle()
                                .trim(from: 0, to: 0.25)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(ringRotation))
                        }

                        // Outer ring
                        Circle()
                            .stroke(Color.white.opacity(appState.tonyStarkMode ? 0.3 : 0.08), lineWidth: 2)
                            .frame(width: 80, height: 80)

                        // Segments
                        ForEach(0..<6, id: \.self) { i in
                            Rectangle()
                                .fill(Color.white.opacity(appState.tonyStarkMode ? 0.2 : 0.05))
                                .frame(width: 2, height: 10)
                                .offset(y: -30)
                                .rotationEffect(.degrees(Double(i) * 60))
                        }

                        // Core
                        Circle()
                            .fill(Color.white.opacity(appState.tonyStarkMode ? 0.5 : 0.08))
                            .frame(width: 8, height: 8)

                        // Label
                        VStack {
                            Spacer()
                            Text(appState.tonyStarkMode ? "J.A.R.V.I.S. ONLINE" : "OFFLINE")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(appState.tonyStarkMode ? 0.5 : 0.15))
                                .tracking(2)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(appState.tonyStarkMode ? 0.15 : 0.05), lineWidth: 1)
                )

                // Activate button
                Button {
                    withAnimation { appState.tonyStarkMode.toggle() }
                    if appState.tonyStarkMode { startAnimations() } else { stopAnimations() }
                } label: {
                    Text(appState.tonyStarkMode ? "deactivate" : "activate tony stark mode")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(appState.tonyStarkMode ? .white.opacity(0.5) : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(appState.tonyStarkMode ? Color.white.opacity(0.05) : Color.white)
                        )
                }
                .buttonStyle(.plain)

                // Voice status
                if appState.tonyStarkMode {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(appState.voiceListening ? Color.green : Color.red)
                            .frame(width: 6, height: 6)
                        Text(appState.voiceListening ? "voice active — say \"jarvis are you there\"" : "voice off")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                        Spacer()
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.03)))

                    if !appState.lastHeardText.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.2))
                            Text(appState.lastHeardText)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.25))
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                }

                // Preview buttons
                HStack(spacing: 10) {
                    Button { appState.audioPlayer.playJarvisBeep() } label: {
                        Text("jarvis beep")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.04)))
                    }
                    .buttonStyle(.plain)

                    Button { appState.audioPlayer.playIronMan() } label: {
                        Text("iron man theme")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.04)))
                    }
                    .buttonStyle(.plain)
                }

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    Text("features")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.2))

                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(text: "slaps play jarvis beeps instead of normal sounds")
                        FeatureRow(text: "double-tap/clap opens terminal + claude code + iron man theme")
                        FeatureRow(text: "say \"jarvis are you there\" to trigger the same action")
                        FeatureRow(text: "iron man theme plays on double-clap or voice command only")
                        FeatureRow(text: "no sound plays when you activate — only on triggers")
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))
                }
            }
            .padding(24)
        }
        .onAppear {
            if appState.tonyStarkMode { startAnimations() }
        }
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
        withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
    }

    private func stopAnimations() {
        withAnimation(.easeOut(duration: 0.3)) {
            pulseScale = 1.0
            ringRotation = 0
        }
    }
}

struct FeatureRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("~")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white.opacity(0.15))
            Text(text)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white.opacity(0.35))
        }
    }
}
