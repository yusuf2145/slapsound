import SwiftUI
import UniformTypeIdentifiers

struct SoundsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showFilePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Sounds")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                }

                // Sound grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(SoundMode.allCases) { mode in
                        SoundTile(
                            mode: mode,
                            isSelected: appState.soundMode == mode && !appState.tonyStarkMode,
                            hasCustom: mode == .custom ? appState.recorder.hasRecording : true,
                            onSelect: { appState.soundMode = mode },
                            onPreview: { appState.previewSound(mode) }
                        )
                    }
                }

                // Custom sound
                VStack(alignment: .leading, spacing: 12) {
                    Text("custom sound")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.2))

                    VStack(spacing: 12) {
                        // Record
                        HStack {
                            Text("record 4s")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            if appState.recorder.isRecording {
                                HStack(spacing: 6) {
                                    Circle().fill(Color.red).frame(width: 6, height: 6)
                                    Text(String(format: "%.1fs", appState.recorder.timeRemaining))
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(.red)
                                }
                                Button {
                                    appState.recorder.stopRecording()
                                    appState.loadCustomSoundFromRecording()
                                    appState.soundMode = .custom
                                } label: {
                                    Text("stop")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color.red))
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button {
                                    appState.recorder.startRecording()
                                } label: {
                                    HStack(spacing: 4) {
                                        Circle().fill(Color.red).frame(width: 6, height: 6)
                                        Text("rec")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    }
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.white.opacity(0.08)))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if appState.recorder.isRecording {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.05))
                                    RoundedRectangle(cornerRadius: 2).fill(Color.red.opacity(0.6))
                                        .frame(width: geo.size.width * CGFloat(1.0 - appState.recorder.timeRemaining / 4.0))
                                }
                            }
                            .frame(height: 3)
                        }

                        Divider().background(Color.white.opacity(0.05))

                        // Upload
                        HStack {
                            Text("upload file")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Button {
                                showFilePicker = true
                            } label: {
                                Text("choose")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.white.opacity(0.08)))
                            }
                            .buttonStyle(.plain)
                        }

                        if appState.recorder.hasRecording {
                            Divider().background(Color.white.opacity(0.05))
                            HStack {
                                Text("custom sound loaded")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.green.opacity(0.6))
                                Spacer()
                                Button { appState.previewSound(.custom) } label: {
                                    Text("play").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.white.opacity(0.5))
                                }.buttonStyle(.plain)
                                Text("|").foregroundColor(.white.opacity(0.1))
                                Button { appState.recorder.deleteRecording() } label: {
                                    Text("delete").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.red.opacity(0.5))
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))
                }

                // Volume
                VStack(alignment: .leading, spacing: 12) {
                    Text("audio")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.2))

                    VStack(spacing: 12) {
                        HStack {
                            Text("volume")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text("\(Int(appState.masterVolume * 100))%")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        Slider(value: $appState.masterVolume, in: 0...1, step: 0.05).tint(.white)

                        Divider().background(Color.white.opacity(0.05))

                        HStack {
                            Text("force scaling")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Toggle("", isOn: $appState.volumeScaling).toggleStyle(.switch).controlSize(.small)
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))
                }
            }
            .padding(24)
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.audio, .mp3, .mpeg4Audio, .wav], allowsMultipleSelection: false) { result in
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

struct SoundTile: View {
    let mode: SoundMode
    let isSelected: Bool
    let hasCustom: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Button(action: onSelect) {
                VStack(spacing: 8) {
                    Image(systemName: mode.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.25))

                    Text(mode.rawValue.lowercased())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.35))

                    if mode == .custom && !hasCustom {
                        Text("empty")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.white.opacity(0.15))
                    } else if isSelected {
                        Text("active")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.green.opacity(0.7))
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(mode == .custom && !hasCustom)

            Button(action: onPreview) {
                Text("play")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(mode == .custom && !hasCustom)
            .opacity(mode == .custom && !hasCustom ? 0.2 : 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(isSelected ? 0.08 : 0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}
