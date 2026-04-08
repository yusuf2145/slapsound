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

                // Current
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(t.cardBgActive).frame(width: 56, height: 56)
                        Text(appState.keyBinding.label)
                            .font(.system(size: 22, weight: .bold, design: .monospaced)).foregroundColor(t.primary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(appState.keyBinding.label == "None" ? "no key press" : "presses \"\(appState.keyBinding.label)\" on slap")
                            .font(.system(size: 13, weight: .medium, design: .monospaced)).foregroundColor(t.secondary)
                        Text("keycode \(appState.keyBinding.keyCode)")
                            .font(.system(size: 10, design: .monospaced)).foregroundColor(t.muted)
                    }
                    Spacer()
                }
                .padding(16).background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))

                // Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("quick select").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(t.tertiary)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                        ForEach(allKeys, id: \.keyCode) { key in
                            Button { appState.keyBinding = key } label: {
                                Text(key.label)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(appState.keyBinding == key ? t.primary : t.tertiary)
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 6).fill(appState.keyBinding == key ? t.cardBgActive : t.cardBg))
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(appState.keyBinding == key ? t.accent.opacity(0.3) : Color.clear, lineWidth: 1))
                            }.buttonStyle(.plain)
                        }
                    }
                }

                // Record
                VStack(alignment: .leading, spacing: 12) {
                    Text("custom key").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(t.tertiary)
                    HStack {
                        Text(isRecording ? "press any key..." : "record a custom key")
                            .font(.system(size: 12, design: .monospaced)).foregroundColor(isRecording ? t.primary : t.tertiary)
                        Spacer()
                        Button {
                            if isRecording { stopListening() } else { startListening() }
                        } label: {
                            HStack(spacing: 4) {
                                Circle().fill(isRecording ? Color.red : t.accent.opacity(0.5)).frame(width: 6, height: 6)
                                Text(isRecording ? "listening" : "record")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(isRecording ? .red : t.secondary)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Capsule().fill(isRecording ? Color.red.opacity(0.1) : t.cardBg))
                        }.buttonStyle(.plain)
                    }
                    .padding(16).background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))

                    if !recordedKey.isEmpty && !isRecording {
                        HStack(spacing: 4) {
                            Text("bound to:").font(.system(size: 10, design: .monospaced)).foregroundColor(t.muted)
                            Text(recordedKey).font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.green.opacity(0.7))
                        }
                    }
                }
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
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [self] event in
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
