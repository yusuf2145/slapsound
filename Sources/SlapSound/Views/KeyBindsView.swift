import SwiftUI

struct KeyBindsView: View {
    @EnvironmentObject var appState: AppState
    @State private var isRecording = false
    @State private var recordedKey: String = ""

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
                            // Key visual
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.primary.opacity(0.06))
                                    .frame(width: 64, height: 64)
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                                    .frame(width: 64, height: 64)
                                // Shadow to look like key
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

                // Preset keys
                Text("PRESET KEYS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ], spacing: 12) {
                    ForEach(KeyBinding.presets, id: \.keyCode) { binding in
                        KeyPresetCard(
                            binding: binding,
                            isSelected: appState.keyBinding == binding
                        ) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                appState.keyBinding = binding
                            }
                        }
                    }
                }

                Divider()

                // Custom key input
                Text("CUSTOM KEY")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Record Custom Key")
                                .font(.system(size: 14, weight: .medium))
                            Text("Click record, then press any key to bind it")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            isRecording.toggle()
                            if isRecording {
                                recordedKey = "Press a key..."
                                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                                    appState.keyBinding = KeyBinding(
                                        keyCode: event.keyCode,
                                        label: event.charactersIgnoringModifiers?.uppercased() ?? "Key \(event.keyCode)"
                                    )
                                    isRecording = false
                                    recordedKey = appState.keyBinding.label
                                    return nil
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(isRecording ? Color.red : Color.orange)
                                    .frame(width: 8, height: 8)
                                Text(isRecording ? "Listening..." : "Record")
                                    .font(.system(size: 12, weight: .semibold))
                            }
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
}

struct KeyPresetCard: View {
    let binding: KeyBinding
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primary.opacity(isSelected ? 0.1 : 0.05))
                        .frame(width: 48, height: 48)
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary.opacity(isSelected ? 0.2 : 0.08), lineWidth: 1)
                        .frame(width: 48, height: 48)

                    Text(binding.label == "None" ? "--" : binding.label)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .orange : .primary)
                }

                Text(binding.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
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
        .buttonStyle(.plain)
    }
}
