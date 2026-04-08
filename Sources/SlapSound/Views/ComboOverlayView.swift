import SwiftUI

struct ComboOverlayView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            // Combo counter
            if appState.currentCombo >= 2 {
                VStack(spacing: 4) {
                    Text("\(appState.currentCombo)x")
                        .font(.system(size: comboFontSize, weight: .black, design: .monospaced))
                        .foregroundColor(comboColor.opacity(0.7))
                    Text("COMBO")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(comboColor.opacity(0.4))
                        .tracking(4)
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.interpolatingSpring(stiffness: 300, damping: 12), value: appState.currentCombo)
            }

            // Achievement banner
            if let achievement = appState.comboAchievement {
                VStack {
                    Spacer()
                    Text(achievement)
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(comboColor)
                                .shadow(color: comboColor.opacity(0.3), radius: 12)
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 40)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var comboFontSize: CGFloat {
        let base: CGFloat = 36
        let bonus = min(CGFloat(appState.currentCombo) * 4, 40)
        return base + bonus
    }

    private var comboColor: Color {
        let combo = appState.currentCombo
        if combo < 5 { return .white }
        if combo < 10 { return .orange }
        if combo < 25 { return .red }
        return .purple
    }
}
