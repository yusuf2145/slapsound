import SwiftUI

struct ThemesView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        let t = appState.theme
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Themes")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(t.primary)
                    Spacer()
                }

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(ThemeName.allCases) { name in
                        let theme = AppTheme.forName(name)
                        let isSelected = appState.themeName == name

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                appState.themeName = name
                            }
                        } label: {
                            VStack(spacing: 12) {
                                // Mini preview
                                HStack(spacing: 0) {
                                    // Sidebar preview
                                    Rectangle()
                                        .fill(theme.sidebarBg)
                                        .frame(width: 30)
                                        .overlay(
                                            VStack(spacing: 4) {
                                                Circle().fill(theme.accent).frame(width: 6, height: 6)
                                                RoundedRectangle(cornerRadius: 1).fill(theme.secondary).frame(width: 16, height: 2)
                                                RoundedRectangle(cornerRadius: 1).fill(theme.tertiary).frame(width: 16, height: 2)
                                                RoundedRectangle(cornerRadius: 1).fill(theme.tertiary).frame(width: 16, height: 2)
                                            }
                                        )

                                    // Content preview
                                    Rectangle()
                                        .fill(theme.contentBg)
                                        .overlay(
                                            VStack(spacing: 6) {
                                                RoundedRectangle(cornerRadius: 2).fill(theme.primary).frame(width: 50, height: 4)
                                                HStack(spacing: 4) {
                                                    RoundedRectangle(cornerRadius: 3).fill(theme.cardBg).frame(height: 18)
                                                    RoundedRectangle(cornerRadius: 3).fill(theme.cardBg).frame(height: 18)
                                                }
                                                .padding(.horizontal, 8)
                                                RoundedRectangle(cornerRadius: 3).fill(theme.cardBg).frame(height: 30)
                                                    .padding(.horizontal, 8)
                                            }
                                        )
                                }
                                .frame(height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(theme.isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                                )

                                Text(name.rawValue.lowercased())
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(t.primary)

                                if isSelected {
                                    Text("active")
                                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? t.cardBgActive : t.cardBg))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? t.accent.opacity(0.3) : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(24)
        }
    }
}
