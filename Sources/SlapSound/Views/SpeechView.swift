import SwiftUI

struct SpeechView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        let t = appState.theme
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Speech")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(t.primary)
                    Spacer()
                }

                // Mode toggle
                VStack(alignment: .leading, spacing: 12) {
                    Text("slap action")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(t.tertiary)

                    HStack(spacing: 8) {
                        ModeButton(label: "key bind", isActive: !appState.speechMode, theme: t) {
                            appState.speechMode = false
                        }
                        ModeButton(label: "speak text", isActive: appState.speechMode, theme: t) {
                            appState.speechMode = true
                        }
                    }
                }

                if appState.speechMode {
                    // Text input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("what to say on slap")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(t.tertiary)

                        VStack(spacing: 12) {
                            TextField("Type text to speak...", text: $appState.speechText)
                                .font(.system(size: 14, design: .monospaced))
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 8).fill(t.cardBgActive))

                            // Quick phrases
                            Text("quick phrases")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(t.muted)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                                ForEach(quickPhrases, id: \.self) { phrase in
                                    Button {
                                        appState.speechText = phrase
                                    } label: {
                                        Text(phrase)
                                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                                            .foregroundColor(appState.speechText == phrase ? t.primary : t.tertiary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 6)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(appState.speechText == phrase ? t.cardBgActive : t.cardBg)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))
                    }

                    // Voice picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("voice")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(t.tertiary)

                        VStack(spacing: 4) {
                            ForEach(appState.speechService.availableVoices.prefix(12)) { voice in
                                Button {
                                    appState.speechVoice = voice.id
                                } label: {
                                    HStack {
                                        Text(voice.name)
                                            .font(.system(size: 12, design: .monospaced))
                                            .foregroundColor(appState.speechVoice == voice.id ? t.primary : t.secondary)
                                        Spacer()
                                        if appState.speechVoice == voice.id {
                                            Text("active")
                                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                                .foregroundColor(t.accent)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(appState.speechVoice == voice.id ? t.cardBgActive : Color.clear)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))
                    }

                    // Preview
                    Button {
                        appState.speechService.speak(text: appState.speechText, voiceID: appState.speechVoice)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 11))
                            Text("preview")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(t.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(t.cardBgActive))
                    }
                    .buttonStyle(.plain)
                } else {
                    // Key bind mode active — show message
                    VStack(spacing: 8) {
                        Text("key bind mode is active")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(t.secondary)
                        Text("slaps simulate a key press. switch to speak text mode to have your mac talk on every slap.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(t.muted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(t.cardBg))
                }
            }
            .padding(24)
        }
    }

    private var quickPhrases: [String] {
        ["Ouch!", "Slap!", "Hey!", "Wow!", "Damn!", "Stop!", "Yes!", "No!", "Bruh", "What!", "Ow!", "Yeet!"]
    }
}

struct ModeButton: View {
    let label: String
    let isActive: Bool
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(isActive ? theme.primary : theme.tertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isActive ? theme.cardBgActive : theme.cardBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive ? theme.accent.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
