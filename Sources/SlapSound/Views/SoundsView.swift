import SwiftUI

struct SoundsView: View {
    @EnvironmentObject var appState: AppState

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

                // Volume controls
                Text("AUDIO SETTINGS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 20) {
                    // Master volume
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

                    // Volume scaling
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

                    // Pitch info
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
    }
}

struct SoundCard: View {
    let mode: SoundMode
    let isSelected: Bool
    let isDisabled: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void

    private var cardColors: [Color] {
        switch mode {
        case .whipCrack: return [.orange, .red]
        case .slap: return [.pink, .purple]
        case .punch: return [.red, .orange]
        case .airHorn: return [.yellow, .orange]
        case .custom: return [.blue, .purple]
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            // Tap to select
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

                    if isSelected {
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
            .disabled(isDisabled)

            // Preview button
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
                .background(
                    Capsule().fill(cardColors[0].opacity(0.1))
                )
            }
            .buttonStyle(.plain)
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
