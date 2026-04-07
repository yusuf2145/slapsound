import Foundation

struct AccelerometerSample {
    let x: Double  // g-force
    let y: Double
    let z: Double
    let timestamp: TimeInterval

    var magnitude: Double {
        sqrt(x * x + y * y + z * z)
    }
}
