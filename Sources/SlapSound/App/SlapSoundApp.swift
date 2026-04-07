import SwiftUI
import AppKit

// MARK: - App Entry Point

@main
struct SlapSoundApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("SlapSound") {
            ContentView()
                .environmentObject(AppState.shared)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 900, height: 640)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(AppState.shared)
        } label: {
            Image(systemName: AppState.shared.isConnected ? "hand.raised.fill" : "hand.raised.slash")
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - AppDelegate to force window visible

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Make app a regular app (not background-only)
        NSApp.setActivationPolicy(.regular)
        // Bring window to front
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep running in menu bar
    }
}

// MARK: - App State (singleton)

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isConnected = false
    @Published var isEnabled = true {
        didSet {
            detector.isEnabled = isEnabled
            settings.isEnabled = isEnabled
        }
    }
    @Published var sensitivity: Double = 0.05 {
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
    @Published var soundMode: SoundMode = .whipCrack {
        didSet {
            audioPlayer.setSoundMode(soundMode)
            settings.soundMode = soundMode
        }
    }
    @Published var tonyStarkMode: Bool = false {
        didSet {
            settings.tonyStarkMode = tonyStarkMode
            if tonyStarkMode {
                audioPlayer.playJarvisStartup()
            }
        }
    }
    @Published var keyBinding: KeyBinding = .key1 {
        didSet {
            settings.keyBinding = keyBinding
        }
    }
    @Published var slapCount: Int = 0
    @Published var lastSlapForce: Double = 0
    @Published var statusMessage: String = "Starting..."
    @Published var recentSlaps: [SlapEvent] = []

    let settings = AppSettings()
    let reader = AccelerometerReader()
    let detector = SlapDetector()
    let audioPlayer = AudioPlayer()
    private var bridge: SlapBridge?

    private init() {
        // Force fresh defaults
        UserDefaults.standard.set(0.05, forKey: "sensitivity")
        UserDefaults.standard.set(150, forKey: "cooldownMs")
        UserDefaults.standard.set(1.0, forKey: "masterVolume")

        isEnabled = settings.isEnabled
        sensitivity = 0.05
        cooldownMs = 150
        masterVolume = 1.0
        volumeScaling = settings.volumeScaling
        slapCount = settings.slapCount
        tonyStarkMode = settings.tonyStarkMode
        soundMode = settings.soundMode
        keyBinding = settings.keyBinding

        detector.sensitivity = 0.05
        detector.cooldownMs = 150
        detector.isEnabled = true
        audioPlayer.masterVolume = 1.0
        audioPlayer.volumeScaling = volumeScaling
        audioPlayer.setSoundMode(soundMode)

        let bridge = SlapBridge(appState: self)
        self.bridge = bridge
        reader.delegate = detector
        detector.delegate = bridge

        audioPlayer.setup()

        let connected = reader.start()
        isConnected = connected
        statusMessage = connected ? "Listening for slaps..." : "No accelerometer found"

        if !connected {
            if ProcessInfo.processInfo.environment["USER"] != "root" {
                statusMessage = "Run with sudo for accelerometer access"
            }
        }
    }

    func handleSlap(_ event: SlapEvent) {
        slapCount += 1
        settings.slapCount = slapCount
        lastSlapForce = event.force
        recentSlaps.append(event)
        if recentSlaps.count > 50 { recentSlaps.removeFirst() }

        if tonyStarkMode {
            audioPlayer.playJarvisBeep()
        } else {
            audioPlayer.playSlap(force: event.force)
        }

        simulateKeyPress()
    }

    private func simulateKeyPress() {
        guard keyBinding.keyCode != 0 else { return } // "None" selected
        let source = CGEventSource(stateID: .hidSystemState)
        if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyBinding.keyCode, keyDown: true),
           let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyBinding.keyCode, keyDown: false) {
            keyDown.post(tap: .cghidEventTap)
            keyUp.post(tap: .cghidEventTap)
            print("[SlapSound] Pressed '\(keyBinding.label)' key")
        }
    }

    deinit {
        reader.stop()
        audioPlayer.stop()
    }
}

// MARK: - Bridge

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
