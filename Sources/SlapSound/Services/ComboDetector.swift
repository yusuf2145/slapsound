import Foundation

protocol ComboDetectorDelegate: AnyObject {
    func comboUpdated(count: Int)
    func comboReset()
    func comboAchievement(name: String)
}

final class ComboDetector {
    weak var delegate: ComboDetectorDelegate?

    var isEnabled: Bool = true
    var timeout: TimeInterval = 2.0

    private(set) var comboCount: Int = 0
    private var timer: Timer?

    func registerSlap() {
        guard isEnabled else { return }

        comboCount += 1

        // Reset timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.resetCombo()
        }

        delegate?.comboUpdated(count: comboCount)

        // Check achievements
        switch comboCount {
        case 3: delegate?.comboAchievement(name: "TRIPLE!")
        case 5: delegate?.comboAchievement(name: "PENTA!")
        case 10: delegate?.comboAchievement(name: "LEGENDARY!")
        case 25: delegate?.comboAchievement(name: "UNSTOPPABLE!")
        case 50: delegate?.comboAchievement(name: "GOD MODE!")
        default: break
        }
    }

    func resetCombo() {
        comboCount = 0
        timer?.invalidate()
        timer = nil
        delegate?.comboReset()
    }
}
