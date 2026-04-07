import SwiftUI

@main
struct SlapSoundApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Image(systemName: appState.isConnected ? "hand.raised.fill" : "hand.raised.slash")
        }
        .menuBarExtraStyle(.window)
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var isConnected = false
    @Published var isEnabled = true {
        didSet {
            detector.isEnabled = isEnabled
            settings.isEnabled = isEnabled
        }
    }
    @Published var sensitivity: Double = 0.15 {
        didSet {
            detector.sensitivity = sensitivity
            settings.sensitivity = sensitivity
        }
    }
    @Published var cooldownMs: Int = 150 {
        didSet {
            detector.cooldownMs = cooldownMs
            settings.cooldownMs = cooldownMs
        }
    }
    @Published var masterVolume: Double = 1.0 {
        didSet {
            audioPlayer.masterVolume = Float(masterVolume)
            settings.masterVolume = masterVolume
        }
    }
    @Published var volumeScaling: Bool = true {
        didSet {
            audioPlayer.volumeScaling = volumeScaling
            settings.volumeScaling = volumeScaling
        }
    }
    @Published var slapCount: Int = 0
    @Published var lastSlapForce: Double = 0
    @Published var statusMessage: String = "Starting..."

    let settings = AppSettings()
    let reader = AccelerometerReader()
    let detector = SlapDetector()
    let audioPlayer = AudioPlayer()
    private var bridge: SlapBridge?

    init() {
        // Reset stale stored defaults to new values
        UserDefaults.standard.set(0.05, forKey: "sensitivity")
        UserDefaults.standard.set(150, forKey: "cooldownMs")
        UserDefaults.standard.set(1.0, forKey: "masterVolume")

        // Load persisted settings
        isEnabled = settings.isEnabled
        sensitivity = 0.05
        cooldownMs = 150
        masterVolume = 1.0
        volumeScaling = settings.volumeScaling
        slapCount = settings.slapCount

        // Apply settings — force ultra-sensitive
        detector.sensitivity = 0.05
        detector.cooldownMs = 150
        detector.isEnabled = true
        audioPlayer.masterVolume = 1.0
        audioPlayer.volumeScaling = volumeScaling

        // Set up delegation chain
        let bridge = SlapBridge(appState: self)
        self.bridge = bridge
        reader.delegate = detector
        detector.delegate = bridge

        // Start audio engine
        audioPlayer.setup()

        // Start accelerometer
        let connected = reader.start()
        isConnected = connected
        statusMessage = connected ? "Listening for slaps..." : "No accelerometer found"

        if !connected {
            // Check if we might need root
            if ProcessInfo.processInfo.environment["USER"] != "root" {
                statusMessage = "Run with sudo for accelerometer access"
            }
        }
    }

    func handleSlap(_ event: SlapEvent) {
        slapCount += 1
        settings.slapCount = slapCount
        lastSlapForce = event.force
        audioPlayer.playSlap(force: event.force)
        simulateKeyPress()
    }

    /// Simulate pressing the "1" key
    private func simulateKeyPress() {
        let keyCode: CGKeyCode = 18  // "1" key on macOS
        let source = CGEventSource(stateID: .hidSystemState)
        if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
           let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) {
            keyDown.post(tap: .cghidEventTap)
            keyUp.post(tap: .cghidEventTap)
            print("[SlapSound] Pressed '1' key")
        }
    }

    deinit {
        reader.stop()
        audioPlayer.stop()
    }
}

/// Bridge between SlapDetector (non-MainActor) and AppState (MainActor)
final class SlapBridge: SlapDetectorDelegate {
    private weak var appState: AppState?

    init(appState: AppState) {
        self.appState = appState
    }

    func slapDetector(_ detector: SlapDetector, didDetectSlap event: SlapEvent) {
        DispatchQueue.main.async { [weak self] in
            self?.appState?.handleSlap(event)
        }
    }
}
