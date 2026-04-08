import SwiftUI

struct KeyBindsView: View {
    @EnvironmentObject var appState: AppState
    @State private var isRecording = false
    @State private var recordedKey = ""
    @State private var localMonitor: Any? = nil

    var body: some View {
        let t = appState.theme
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Key Binds")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(t.primary)
                    Spacer()
                }

                // Mode toggle: single key vs text
                VStack(alignment: .leading, spacing: 12) {
                    Text("key mode")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(t.tertiary)

                    HStack(spacing: 8) {
                        ActionModeBtn(label: "Single Key", icon: "keyboard.fill", isActive: appState.keyMode == "single", color: .orange, theme: t) {
                            appState.keyMode = "single"
                        }
                        ActionModeBtn(label: "Type Text", icon: "text.cursor", isActive: appState.keyMode == "text", color: .green, theme: t) {
                            appState.keyMode = "text"
                        }
                    }
                }

                if appState.keyMode == "text" {
                    // Full text input mode
                    VStack(alignment: .leading, spacing: 12) {
                        Text("text to type on slap")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(t.tertiary)

                        VStack(spacing: 8) {
                            TextEditor(text: $appState.customKeyText)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(t.primary)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .frame(minHeight: 80, maxHeight: 120)
                                .background(RoundedRectangle(cornerRadius: 8).fill(t.cardBgActive))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(t.border, lineWidth: 1))

                            HStack {
                                Text("\(appState.customKeyText.count) chars")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(t.muted)
                                Spacer()
                                Text("typed on every slap")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(t.muted)
                            }

                            // Quick text presets
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                                ForEach(["Hello! ", "LOL ", "GG ", "Nice! ", "Wow ", "bruh "], id: \.self) { text in
                                    Button {
                                        appState.customKeyText = text
                                    } label: {
                                        Text(text.trimmingCharacters(in: .whitespaces))
                                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                                            .foregroundColor(appState.customKeyText == text ? .green : t.tertiary)
                                            .padding(.horizontal, 8).padding(.vertical, 6)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(appState.customKeyText == text ? Color.green.opacity(0.1) : t.cardBg)
                                            )
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))
                    }
                } else {
                    // Single key mode
                    // Current binding display
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(t.cardBgActive).frame(width: 56, height: 56)
                            Text(appState.keyBinding.label)
                                .font(.system(size: 22, weight: .bold, design: .monospaced)).foregroundColor(.orange)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(appState.keyBinding.label == "None" ? "no key press" : "presses \"\(appState.keyBinding.label)\"")
                                .font(.system(size: 13, weight: .medium, design: .monospaced)).foregroundColor(t.secondary)
                            Text("keycode \(appState.keyBinding.keyCode)")
                                .font(.system(size: 10, design: .monospaced)).foregroundColor(t.muted)
                        }
                        Spacer()
                    }
                    .padding(16).background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.orange.opacity(0.15), lineWidth: 1))

                    // Quick select grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("quick select").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(t.tertiary)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                            ForEach(allKeys, id: \.label) { key in
                                Button { appState.keyBinding = key } label: {
                                    Text(key.label)
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(appState.keyBinding == key ? .orange : t.tertiary)
                                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(appState.keyBinding == key ? Color.orange.opacity(0.1) : t.cardBg)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(appState.keyBinding == key ? Color.orange.opacity(0.25) : Color.clear, lineWidth: 1)
                                        )
                                }.buttonStyle(.plain)
                            }
                        }
                    }

                    // Record custom key
                    VStack(alignment: .leading, spacing: 12) {
                        Text("custom key").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(t.tertiary)
                        HStack {
                            Text(isRecording ? "press any key..." : "record a custom key")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(isRecording ? .orange : t.tertiary)
                            Spacer()
                            Button {
                                if isRecording { stopListening() } else { startListening() }
                            } label: {
                                HStack(spacing: 4) {
                                    Circle().fill(isRecording ? Color.red : Color.orange.opacity(0.5)).frame(width: 6, height: 6)
                                    Text(isRecording ? "listening" : "record")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                }
                                .foregroundColor(isRecording ? .red : t.secondary)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Capsule().fill(isRecording ? Color.red.opacity(0.1) : t.cardBgActive))
                            }.buttonStyle(.plain)
                        }
                        .padding(16).background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))

                        if !recordedKey.isEmpty && !isRecording {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 10)).foregroundColor(.green)
                                Text("bound to: \(recordedKey)").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.green.opacity(0.7))
                            }
                        }
                    }
                }

                // Info
                HStack(spacing: 8) {
                    Image(systemName: "info.circle").font(.system(size: 11)).foregroundColor(.blue)
                    Text("Key simulation requires Accessibility permissions in System Settings.")
                        .font(.system(size: 10, design: .monospaced)).foregroundColor(t.muted)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.05)))
            }
            .padding(24)
        }
    }

    private var allKeys: [KeyBinding] {
        [
            KeyBinding(keyCode: 0, label: "None"),
            KeyBinding(keyCode: 18, label: "1"), KeyBinding(keyCode: 19, label: "2"),
            KeyBinding(keyCode: 20, label: "3"), KeyBinding(keyCode: 21, label: "4"),
            KeyBinding(keyCode: 23, label: "5"),
            KeyBinding(keyCode: 0, label: "A"), KeyBinding(keyCode: 11, label: "B"),
            KeyBinding(keyCode: 8, label: "C"), KeyBinding(keyCode: 2, label: "D"),
            KeyBinding(keyCode: 14, label: "E"), KeyBinding(keyCode: 3, label: "F"),
            KeyBinding(keyCode: 49, label: "Space"), KeyBinding(keyCode: 36, label: "Return"),
            KeyBinding(keyCode: 48, label: "Tab"), KeyBinding(keyCode: 53, label: "Esc"),
            KeyBinding(keyCode: 126, label: "Up"), KeyBinding(keyCode: 125, label: "Down"),
        ]
    }

    private func startListening() {
        isRecording = true; recordedKey = ""
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let label = event.charactersIgnoringModifiers?.uppercased() ?? "Key \(event.keyCode)"
            appState.keyBinding = KeyBinding(keyCode: event.keyCode, label: label)
            recordedKey = label; stopListening(); return nil
        }
    }

    private func stopListening() {
        isRecording = false
        if let m = localMonitor { NSEvent.removeMonitor(m); localMonitor = nil }
    }
}
