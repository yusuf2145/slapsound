import SwiftUI

struct KeyBindsView: View {
    @EnvironmentObject var appState: AppState
    @State private var isRecording = false
    @State private var recordedKey: String = ""
    @State private var localMonitor: Any? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Key Binds")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                }

                // Current
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 56, height: 56)
                        Text(appState.keyBinding.label)
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(appState.keyBinding.label == "None" ? "no key press" : "presses \"\(appState.keyBinding.label)\" on slap")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        Text("keycode \(appState.keyBinding.keyCode)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    Spacer()
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))

                // Quick keys grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("quick select")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.2))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                        ForEach(allKeys, id: \.keyCode) { key in
                            Button {
                                appState.keyBinding = key
                            } label: {
                                Text(key.label)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(appState.keyBinding == key ? .white : .white.opacity(0.3))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(appState.keyBinding == key ? Color.white.opacity(0.12) : Color.white.opacity(0.03))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(appState.keyBinding == key ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Record custom
                VStack(alignment: .leading, spacing: 12) {
                    Text("custom key")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.2))

                    HStack {
                        Text(isRecording ? "press any key..." : "record a custom key")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(isRecording ? .white : .white.opacity(0.4))
                        Spacer()
                        Button {
                            if isRecording { stopListening() } else { startListening() }
                        } label: {
                            HStack(spacing: 4) {
                                Circle().fill(isRecording ? Color.red : Color.white.opacity(0.3)).frame(width: 6, height: 6)
                                Text(isRecording ? "listening" : "record")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(isRecording ? .red : .white.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(isRecording ? Color.red.opacity(0.1) : Color.white.opacity(0.06)))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))

                    if !recordedKey.isEmpty && !isRecording {
                        HStack(spacing: 4) {
                            Text("bound to:")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.2))
                            Text(recordedKey)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.green.opacity(0.6))
                        }
                    }
                }

                // Info
                Text("key simulation requires accessibility permissions: system settings > privacy & security > accessibility")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.15))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.02)))
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
        isRecording = true
        recordedKey = ""
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [self] event in
            let label = event.charactersIgnoringModifiers?.uppercased() ?? "Key \(event.keyCode)"
            appState.keyBinding = KeyBinding(keyCode: event.keyCode, label: label)
            recordedKey = label
            stopListening()
            return nil
        }
    }

    private func stopListening() {
        isRecording = false
        if let m = localMonitor { NSEvent.removeMonitor(m); localMonitor = nil }
    }
}
