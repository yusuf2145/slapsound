import Foundation

struct SlapEvent {
    let force: Double      // excess g-force above gravity
    let timestamp: Date

    /// Normalized force in 0.0-1.0 range for audio scaling
    var normalizedForce: Double {
        let clamped = min(max(force, 0.0), 5.0)
        return clamped / 5.0
    }
}
