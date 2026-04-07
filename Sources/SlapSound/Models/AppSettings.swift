import SwiftUI
import Combine

final class AppSettings: ObservableObject {
    @AppStorage("isEnabled") var isEnabled: Bool = true
    @AppStorage("sensitivity") var sensitivity: Double = 0.15
    @AppStorage("cooldownMs") var cooldownMs: Int = 150
    @AppStorage("masterVolume") var masterVolume: Double = 1.0
    @AppStorage("volumeScaling") var volumeScaling: Bool = true
    @AppStorage("slapCount") var slapCount: Int = 0
}
