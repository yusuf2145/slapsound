import SwiftUI
import UniformTypeIdentifiers

struct SoundsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showFilePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sounds")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text("Choose what plays when you slap your MacBook")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                // Sound mode grid
                Text("SOUND PACKS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                ], spacing: 16) {
                    ForEach(SoundMode.allCases) { mode in
                        SoundCard(
                            mode: mode,
                            isSelected: appState.soundMode == mode && !appState.tonyStarkMode,
                            isDisabled: appState.tonyStarkMode,
                            hasCustom: mode == .custom ? appState.recorder.hasRecording : true,
                            onSelect: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    appState.soundMode = mode
                                }
                            },
                            onPreview: {
                                appState.previewSound(mode)
                            }
                        )
                    }
                }

                Divider()

                // Custom sound section
                Text("CUSTOM SOUND")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                CustomSoundSection(showFilePicker: $showFilePicker)

                Divider()

                // Volume controls
                Text("AUDIO SETTINGS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            Text("Master Volume")
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Text("\(Int(appState.masterVolume * 100))%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                        Slider(value: $appState.masterVolume, in: 0...1, step: 0.05)
                            .tint(.green)
                    }

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Force-Scaled Volume")
                                .font(.system(size: 14, weight: .medium))
                            Text("Harder slaps play louder sounds")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $appState.volumeScaling)
                            .toggleStyle(.switch)
                    }

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dynamic Pitch")
                                .font(.system(size: 14, weight: .medium))
                            Text("Harder slaps produce higher pitch. Always on.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
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
            }
            .padding(32)
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.audio, .mp3, .mpeg4Audio, .wav],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                if url.startAccessingSecurityScopedResource() {
                    appState.loadCustomSoundFromFile(url)
                    url.stopAccessingSecurityScopedResource()
                    appState.soundMode = .custom
                }
            }
        }
    }
}

// MARK: - Custom Sound Section

struct CustomSoundSection: View {
    @EnvironmentObject var appState: AppState
    @Binding var showFilePicker: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Record option
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Record a Sound")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Record up to 4 seconds from your mic")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()

                    if appState.recorder.isRecording {
                        // Recording indicator
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text(String(format: "%.1fs", appState.recorder.timeRemaining))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.red.opacity(0.1)))

                        Button {
                            appState.recorder.stopRecording()
                            appState.loadCustomSoundFromRecording()
                            appState.soundMode = .custom
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 10))
                                Text("Stop")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.red))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            appState.recorder.startRecording()
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                Text("Record")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.red.opacity(0.1)))
                            .overlay(Capsule().stroke(Color.red.opacity(0.2), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Progress bar while recording
                if appState.recorder.isRecording {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.primary.opacity(0.06))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.red)
                                .frame(width: geo.size.width * CGFloat(1.0 - appState.recorder.timeRemaining / appState.recorder.maxDuration))
                                .animation(.linear(duration: 0.1), value: appState.recorder.timeRemaining)
                        }
                    }
                    .frame(height: 4)
                }
            }

            Divider()

            // Upload option
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Upload a Sound File")
                        .font(.system(size: 14, weight: .semibold))
                    Text("MP3, WAV, or M4A")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    showFilePicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 11))
                        Text("Choose File")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.blue.opacity(0.1)))
                    .overlay(Capsule().stroke(Color.blue.opacity(0.2), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            // Current custom sound status
            if appState.recorder.hasRecording {
                Divider()
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Custom sound loaded")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                    Spacer()

                    Button {
                        appState.previewSound(.custom)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 9))
                            Text("Play")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.blue.opacity(0.1)))
                    }
                    .buttonStyle(.plain)

                    Button {
                        appState.recorder.deleteRecording()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 9))
                            Text("Delete")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.red.opacity(0.1)))
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
    }
}

// MARK: - Sound Card

struct SoundCard: View {
    let mode: SoundMode
    let isSelected: Bool
    let isDisabled: Bool
    let hasCustom: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void

    private var cardColors: [Color] {
        switch mode {
        case .whipCrack: return [.orange, .red]
        case .slap: return [.pink, .purple]
        case .punch: return [.red, .orange]
        case .airHorn: return [.yellow, .orange]
        case .moan: return [.pink, .red]
        case .custom: return [.blue, .purple]
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            Button(action: onSelect) {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isDisabled ? [.gray.opacity(0.2)] : cardColors.map { $0.opacity(0.15) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)

                        Image(systemName: mode.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(
                                isDisabled
                                    ? LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: cardColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    }

                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isDisabled ? .secondary : .primary)

                    if mode == .custom && !hasCustom {
                        Text("No sound")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.orange)
                    } else if isSelected {
                        Text("Active")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.green.opacity(0.12)))
                    } else {
                        Text("Select")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(isDisabled || (mode == .custom && !hasCustom))

            Button(action: onPreview) {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 9))
                    Text("Preview")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(cardColors[0])
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Capsule().fill(cardColors[0].opacity(0.1)))
            }
            .buttonStyle(.plain)
            .disabled(mode == .custom && !hasCustom)
            .opacity(mode == .custom && !hasCustom ? 0.3 : 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(isSelected ? 0.05 : 0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected
                        ? LinearGradient(colors: cardColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.primary.opacity(0.06)], startPoint: .top, endPoint: .bottom),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .opacity(isDisabled ? 0.5 : 1)
    }
}
