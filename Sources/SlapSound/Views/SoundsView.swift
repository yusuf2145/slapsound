import SwiftUI
import UniformTypeIdentifiers

struct SoundsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showFilePicker = false

    var body: some View {
        let t = appState.theme
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Sounds")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(t.primary)
                    Spacer()
                }

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(SoundMode.allCases) { mode in
                        SoundTile(
                            mode: mode,
                            isSelected: appState.soundMode == mode && !appState.tonyStarkMode,
                            hasCustom: mode == .custom ? appState.recorder.hasRecording : true,
                            theme: t,
                            onSelect: { appState.soundMode = mode },
                            onPreview: { appState.previewSound(mode) }
                        )
                    }
                }

                // Custom sound
                VStack(alignment: .leading, spacing: 12) {
                    Text("custom sound")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(t.tertiary)

                    VStack(spacing: 12) {
                        HStack {
                            Text("record 4s")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(t.secondary)
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
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Capsule().fill(Color.red))
                                }.buttonStyle(.plain)
                            } else {
                                Button {
                                    appState.recorder.startRecording()
                                } label: {
                                    HStack(spacing: 4) {
                                        Circle().fill(Color.red).frame(width: 6, height: 6)
                                        Text("rec")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    }
                                    .foregroundColor(t.secondary)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Capsule().fill(t.cardBgActive))
                                }.buttonStyle(.plain)
                            }
                        }

                        if appState.recorder.isRecording {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2).fill(t.cardBgActive)
                                    RoundedRectangle(cornerRadius: 2).fill(Color.red.opacity(0.6))
                                        .frame(width: geo.size.width * CGFloat(1.0 - appState.recorder.timeRemaining / 4.0))
                                }
                            }.frame(height: 3)
                        }

                        Divider().background(t.border)

                        HStack {
                            Text("upload file")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(t.secondary)
                            Spacer()
                            Button { showFilePicker = true } label: {
                                Text("choose")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(t.secondary)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Capsule().fill(t.cardBgActive))
                            }.buttonStyle(.plain)
                        }

                        if appState.recorder.hasRecording {
                            Divider().background(t.border)
                            HStack {
                                Text("custom sound loaded")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.green.opacity(0.7))
                                Spacer()
                                Button { appState.previewSound(.custom) } label: {
                                    Text("play").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(t.accent)
                                }.buttonStyle(.plain)
                                Text("|").foregroundColor(t.muted)
                                Button { appState.recorder.deleteRecording() } label: {
                                    Text("delete").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.red.opacity(0.6))
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))
                }

                // Volume
                VStack(alignment: .leading, spacing: 12) {
                    Text("audio")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(t.tertiary)

                    VStack(spacing: 12) {
                        HStack {
                            Text("volume").font(.system(size: 12, design: .monospaced)).foregroundColor(t.secondary)
                            Spacer()
                            Text("\(Int(appState.masterVolume * 100))%")
                                .font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(t.accent)
                        }
                        Slider(value: $appState.masterVolume, in: 0...1, step: 0.05).tint(t.accent)

                        Divider().background(t.border)

                        HStack {
                            Text("force scaling").font(.system(size: 12, design: .monospaced)).foregroundColor(t.secondary)
                            Spacer()
                            Toggle("", isOn: $appState.volumeScaling).toggleStyle(.switch).controlSize(.small)
                        }
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 10).fill(t.cardBg))
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
    let theme: AppTheme
    let onSelect: () -> Void
    let onPreview: () -> Void

    private var tileColor: Color {
        switch mode {
        case .whipCrack: return .orange
        case .slap: return .pink
        case .punch: return .red
        case .airHorn: return .yellow
        case .moan: return .purple
        case .custom: return .blue
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            Button(action: onSelect) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(isSelected ? tileColor.opacity(0.2) : theme.cardBgActive)
                            .frame(width: 44, height: 44)
                        Image(systemName: mode.icon)
                            .font(.system(size: 18))
                            .foregroundColor(isSelected ? tileColor : theme.tertiary)
                    }

                    Text(mode.rawValue.lowercased())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(isSelected ? theme.primary : theme.tertiary)

                    if mode == .custom && !hasCustom {
                        Text("empty")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(theme.muted)
                    } else if isSelected {
                        Text("active")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(mode == .custom && !hasCustom)

            Button(action: onPreview) {
                Text("play")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(tileColor.opacity(0.7))
            }
            .buttonStyle(.plain)
            .disabled(mode == .custom && !hasCustom)
            .opacity(mode == .custom && !hasCustom ? 0.2 : 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? tileColor.opacity(0.06) : theme.cardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? tileColor.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
    }
}
