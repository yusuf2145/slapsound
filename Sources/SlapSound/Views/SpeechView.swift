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
                    Text("slap action mode")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(t.tertiary)

                    HStack(spacing: 8) {
                        ActionModeBtn(label: "Key Bind", icon: "keyboard.fill", isActive: !appState.speechMode, color: .orange, theme: t) {
                            appState.speechMode = false
                        }
                        ActionModeBtn(label: "Speak Text", icon: "text.bubble.fill", isActive: appState.speechMode, color: .cyan, theme: t) {
                            appState.speechMode = true
                        }
                    }
                }

                if appState.speechMode {
                    // Text input — full TextEditor for long sentences
                    VStack(alignment: .leading, spacing: 12) {
                        Text("what to say on slap")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(t.tertiary)

                        VStack(spacing: 12) {
                            TextEditor(text: $appState.speechText)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(t.primary)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .frame(minHeight: 80, maxHeight: 120)
                                .background(RoundedRectangle(cornerRadius: 8).fill(t.cardBgActive))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(t.border, lineWidth: 1)
                                )

                            Text("\(appState.speechText.count) characters")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(t.muted)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                            // Quick phrases grid
                            Text("quick phrases")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(t.muted)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                                ForEach(quickPhrases, id: \.self) { phrase in
                                    Button {
                                        appState.speechText = phrase
                                    } label: {
                                        Text(phrase)
                                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                                            .foregroundColor(appState.speechText == phrase ? .cyan : t.tertiary)
                                            .padding(.horizontal, 6).padding(.vertical, 6)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(appState.speechText == phrase ? Color.cyan.opacity(0.1) : t.cardBg)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(appState.speechText == phrase ? Color.cyan.opacity(0.3) : Color.clear, lineWidth: 1)
                                            )
                                    }.buttonStyle(.plain)
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

                        VStack(spacing: 2) {
                            ForEach(appState.speechService.availableVoices.prefix(12)) { voice in
                                Button {
                                    appState.speechVoice = voice.id
                                } label: {
                                    HStack {
                                        Text(voice.name)
                                            .font(.system(size: 12, design: .monospaced))
                                            .foregroundColor(appState.speechVoice == voice.id ? .cyan : t.secondary)
                                        Spacer()
                                        if appState.speechVoice == voice.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.cyan)
                                        }
                                    }
                                    .padding(.horizontal, 12).padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(appState.speechVoice == voice.id ? Color.cyan.opacity(0.08) : Color.clear)
                                    )
                                }.buttonStyle(.plain)
                            }
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))
                    }

                    // Preview button
                    Button {
                        appState.speechService.speak(text: appState.speechText, voiceID: appState.speechVoice.isEmpty ? nil : appState.speechVoice)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill").font(.system(size: 12))
                            Text("Preview Speech")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.cyan.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cyan.opacity(0.2), lineWidth: 1))
                    }.buttonStyle(.plain)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "keyboard.fill")
                            .font(.system(size: 32))
                            .foregroundColor(t.muted)
                        Text("Key bind mode is active")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(t.secondary)
                        Text("Slaps simulate a key press. Switch to Speak Text mode above to have your Mac talk on every slap instead.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(t.muted)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(32).frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(t.cardBg))
                }
            }
            .padding(24)
        }
    }

    private var quickPhrases: [String] {
        ["Ouch!", "Slap!", "Hey!", "Wow!", "Damn!", "Stop!", "Yes!", "No!", "Bruh", "What!", "Ow!", "Yeet!", "Hello!", "Goodbye!", "Why!", "Haha!"]
    }
}

struct ActionModeBtn: View {
    let label: String
    let icon: String
    let isActive: Bool
    let color: Color
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 14))
                Text(label).font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .foregroundColor(isActive ? color : theme.tertiary)
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? color.opacity(0.1) : theme.cardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isActive ? color.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }.buttonStyle(.plain)
    }
}
