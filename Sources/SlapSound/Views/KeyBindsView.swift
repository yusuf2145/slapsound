import SwiftUI

struct KeyBindsView: View {
    @EnvironmentObject var appState: AppState
    @State private var isRecording = false
    @State private var recordedKey: String = ""
    @State private var editingPresetIndex: Int? = nil
    @State private var localMonitor: Any? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Key Binds")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text("Configure which key is pressed when a slap is detected")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                // Current binding display
                VStack(spacing: 16) {
                    Text("CURRENT BINDING")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .tracking(1.5)

                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.08))
                            .frame(height: 100)
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                            .frame(height: 100)

                        HStack(spacing: 20) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.primary.opacity(0.06))
                                    .frame(width: 64, height: 64)
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                                    .frame(width: 64, height: 64)
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.primary.opacity(0.03))
                                    .frame(width: 64, height: 64)
                                    .offset(y: 2)

                                Text(appState.keyBinding.label)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Active Key")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text(appState.keyBinding.label == "None" ? "No key press" : "Presses \"\(appState.keyBinding.label)\" on each slap")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Key code: \(appState.keyBinding.keyCode)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Divider()

                // Quick select
                Text("QUICK SELECT")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ], spacing: 12) {
                    ForEach(Array(KeyBinding.presets.enumerated()), id: \.offset) { index, binding in
                        KeyPresetCard(
                            binding: binding,
                            isSelected: appState.keyBinding == binding,
                            isEditing: editingPresetIndex == index,
                            onSelect: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    appState.keyBinding = binding
                                }
                            },
                            onEdit: {
                                startEditingPreset(index)
                            }
                        )
                    }
                }

                Divider()

                // Record any key
                Text("PRESS ANY KEY")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Record Custom Key")
                                .font(.system(size: 14, weight: .medium))
                            Text("Click record, then press any key on your keyboard")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            if isRecording {
                                stopListening()
                            } else {
                                startListeningForKey()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(isRecording ? Color.red : Color.orange)
                                    .frame(width: 8, height: 8)
                                Text(isRecording ? "Listening..." : "Record")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(isRecording ? .red : .orange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isRecording ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(isRecording ? Color.red.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    if !recordedKey.isEmpty {
                        HStack {
                            Image(systemName: isRecording ? "keyboard" : "checkmark.circle.fill")
                                .foregroundColor(isRecording ? .orange : .green)
                            Text(recordedKey)
                                .font(.system(size: 12))
                                .foregroundColor(isRecording ? .orange : .green)
                        }
                    }

                    // Common keys quick-pick
                    Text("Or pick a common key:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                        ForEach(commonKeys, id: \.keyCode) { key in
                            Button {
                                appState.keyBinding = key
                                recordedKey = key.label
                            } label: {
                                Text(key.label)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(appState.keyBinding == key ? Color.orange.opacity(0.15) : Color.primary.opacity(0.05))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(appState.keyBinding == key ? Color.orange.opacity(0.3) : Color.primary.opacity(0.08), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.primary.opacity(0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Info
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Key simulation requires Accessibility permissions. Go to System Settings > Privacy & Security > Accessibility.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.05))
                )
            }
            .padding(32)
        }
    }

    // Common keys people might want
    private var commonKeys: [KeyBinding] {
        [
            KeyBinding(keyCode: 0, label: "A"),
            KeyBinding(keyCode: 11, label: "B"),
            KeyBinding(keyCode: 8, label: "C"),
            KeyBinding(keyCode: 2, label: "D"),
            KeyBinding(keyCode: 14, label: "E"),
            KeyBinding(keyCode: 3, label: "F"),
            KeyBinding(keyCode: 18, label: "1"),
            KeyBinding(keyCode: 19, label: "2"),
            KeyBinding(keyCode: 20, label: "3"),
            KeyBinding(keyCode: 21, label: "4"),
            KeyBinding(keyCode: 23, label: "5"),
            KeyBinding(keyCode: 49, label: "Space"),
            KeyBinding(keyCode: 36, label: "Return"),
            KeyBinding(keyCode: 48, label: "Tab"),
            KeyBinding(keyCode: 53, label: "Esc"),
            KeyBinding(keyCode: 51, label: "Delete"),
            KeyBinding(keyCode: 126, label: "Up"),
            KeyBinding(keyCode: 125, label: "Down"),
        ]
    }

    private func startListeningForKey() {
        isRecording = true
        recordedKey = "Press a key..."
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let label = event.charactersIgnoringModifiers?.uppercased() ?? "Key \(event.keyCode)"
            appState.keyBinding = KeyBinding(keyCode: event.keyCode, label: label)
            recordedKey = "Bound to: \(label)"
            stopListening()
            return nil
        }
    }

    private func stopListening() {
        isRecording = false
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    private func startEditingPreset(_ index: Int) {
        editingPresetIndex = index
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let label = event.charactersIgnoringModifiers?.uppercased() ?? "Key \(event.keyCode)"
            let newBinding = KeyBinding(keyCode: event.keyCode, label: label)
            // Update the preset in-place
            KeyBinding.presets[index] = newBinding
            appState.keyBinding = newBinding
            editingPresetIndex = nil
            if let monitor = localMonitor {
                NSEvent.removeMonitor(monitor)
                localMonitor = nil
            }
            return nil
        }
    }
}

struct KeyPresetCard: View {
    let binding: KeyBinding
    let isSelected: Bool
    let isEditing: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Button(action: onSelect) {
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primary.opacity(isSelected ? 0.1 : 0.05))
                            .frame(width: 48, height: 48)
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isEditing ? Color.red.opacity(0.5) : Color.primary.opacity(isSelected ? 0.2 : 0.08), lineWidth: isEditing ? 2 : 1)
                            .frame(width: 48, height: 48)

                        if isEditing {
                            Text("...")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red)
                        } else {
                            Text(binding.label == "None" ? "--" : binding.label)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(isSelected ? .orange : .primary)
                        }
                    }

                    Text(isEditing ? "Press key..." : binding.label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isEditing ? .red : (isSelected ? .primary : .secondary))

                    if isSelected && !isEditing {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                }
            }
            .buttonStyle(.plain)

            // Edit button
            if !isEditing && binding.label != "None" {
                Button(action: onEdit) {
                    Text("Edit")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.primary.opacity(0.04)))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.orange.opacity(0.06) : Color.primary.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.orange.opacity(0.3) : Color.primary.opacity(0.06), lineWidth: isSelected ? 2 : 1)
        )
    }
}
