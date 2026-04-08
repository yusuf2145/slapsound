import SwiftUI

struct TonyStarkView: View {
    @EnvironmentObject var appState: AppState
    @State private var pulseScale: CGFloat = 1.0
    @State private var ringRotation: Double = 0

    var body: some View {
        let t = appState.theme
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Tony Stark Mode")
                        .font(.system(size: 24, weight: .bold, design: .monospaced)).foregroundColor(t.primary)
                    if appState.tonyStarkMode {
                        Text("ON").font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(t.isDark ? .black : .white)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Capsule().fill(t.primary))
                    }
                    Spacer()
                }

                // Reactor
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color.black).frame(height: 240)
                    ZStack {
                        if appState.tonyStarkMode {
                            Circle().fill(RadialGradient(colors: [.white.opacity(0.08), .clear], center: .center, startRadius: 10, endRadius: 80))
                                .frame(width: 160, height: 160).scaleEffect(pulseScale)
                            Circle().trim(from: 0, to: 0.25).stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                                .frame(width: 100, height: 100).rotationEffect(.degrees(ringRotation))
                        }
                        Circle().stroke(Color.white.opacity(appState.tonyStarkMode ? 0.3 : 0.08), lineWidth: 2).frame(width: 80, height: 80)
                        ForEach(0..<6, id: \.self) { i in
                            Rectangle().fill(Color.white.opacity(appState.tonyStarkMode ? 0.2 : 0.05))
                                .frame(width: 2, height: 10).offset(y: -30).rotationEffect(.degrees(Double(i) * 60))
                        }
                        Circle().fill(Color.white.opacity(appState.tonyStarkMode ? 0.5 : 0.08)).frame(width: 8, height: 8)
                        VStack {
                            Spacer()
                            Text(appState.tonyStarkMode ? "J.A.R.V.I.S. ONLINE" : "OFFLINE")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(appState.tonyStarkMode ? 0.5 : 0.15)).tracking(2)
                        }.padding(.bottom, 20)
                    }
                }
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(appState.tonyStarkMode ? 0.15 : 0.05), lineWidth: 1))

                Button {
                    withAnimation { appState.tonyStarkMode.toggle() }
                    if appState.tonyStarkMode { startAnimations() } else { stopAnimations() }
                } label: {
                    Text(appState.tonyStarkMode ? "deactivate" : "activate tony stark mode")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(appState.tonyStarkMode ? t.secondary : (t.isDark ? .black : .white))
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 10).fill(appState.tonyStarkMode ? t.cardBg : t.primary))
                }.buttonStyle(.plain)

                if appState.tonyStarkMode {
                    HStack(spacing: 8) {
                        Circle().fill(appState.voiceListening ? Color.green : Color.red).frame(width: 6, height: 6)
                        Text(appState.voiceListening ? "voice active — say \"jarvis are you there\"" : "voice off")
                            .font(.system(size: 11, design: .monospaced)).foregroundColor(t.tertiary)
                        Spacer()
                    }
                    .padding(12).background(RoundedRectangle(cornerRadius: 8).fill(t.cardBg))

                    if !appState.lastHeardText.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "mic.fill").font(.system(size: 10)).foregroundColor(t.muted)
                            Text(appState.lastHeardText).font(.system(size: 10, design: .monospaced)).foregroundColor(t.muted).lineLimit(1)
                            Spacer()
                        }
                    }
                }

                HStack(spacing: 10) {
                    Button { appState.audioPlayer.playJarvisBeep() } label: {
                        Text("jarvis beep").font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundColor(t.tertiary)
                            .frame(maxWidth: .infinity).padding(.vertical, 10).background(RoundedRectangle(cornerRadius: 8).fill(t.cardBg))
                    }.buttonStyle(.plain)
                    Button { appState.audioPlayer.playIronMan() } label: {
                        Text("iron man theme").font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundColor(t.tertiary)
                            .frame(maxWidth: .infinity).padding(.vertical, 10).background(RoundedRectangle(cornerRadius: 8).fill(t.cardBg))
                    }.buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("features").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(t.tertiary)
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(["slaps play jarvis beeps", "double-clap opens terminal + claude code + iron man", "say \"jarvis are you there\" to trigger", "no sound on activation — only on triggers"], id: \.self) { text in
                            HStack(alignment: .top, spacing: 8) {
                                Text("~").font(.system(size: 11, design: .monospaced)).foregroundColor(t.muted)
                                Text(text).font(.system(size: 11, design: .monospaced)).foregroundColor(t.tertiary)
                            }
                        }
                    }
                    .padding(16).background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))
                }
            }
            .padding(24)
        }
        .onAppear { if appState.tonyStarkMode { startAnimations() } }
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { pulseScale = 1.15 }
        withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) { ringRotation = 360 }
    }
    private func stopAnimations() {
        withAnimation(.easeOut(duration: 0.3)) { pulseScale = 1.0; ringRotation = 0 }
    }
}
