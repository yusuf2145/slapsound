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
        NSApp.setActivationPolicy(.regular)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NSApp.activate(ignoringOtherApps: true)
            for window in NSApp.windows {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

// MARK: - App State (singleton)

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    // These use didSet to sync with detector/audio/settings at runtime
    @Published var isConnected = false
    @Published var isEnabled = true {
        didSet {
            detector.isEnabled = isEnabled
            settings.isEnabled = isEnabled
            print("[SlapSound] Detection: \(isEnabled ? "ON" : "OFF")")
        }
    }
    @Published var sensitivity: Double = 0.05 {
        didSet {
            detector.sensitivity = sensitivity
            settings.sensitivity = sensitivity
            print("[SlapSound] Sensitivity changed to \(String(format: "%.3f", sensitivity))g")
        }
    }
    @Published var cooldownMs: Int = 150 {
        didSet {
            detector.cooldownMs = cooldownMs
            settings.cooldownMs = cooldownMs
            print("[SlapSound] Cooldown changed to \(cooldownMs)ms")
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
            print("[SlapSound] Sound mode: \(soundMode.rawValue)")
        }
    }
    @Published var tonyStarkMode: Bool = false {
        didSet {
            settings.tonyStarkMode = tonyStarkMode
            if tonyStarkMode {
                print("[SlapSound] TONY STARK MODE ACTIVATED")
                audioPlayer.playJarvisStartup()
            } else {
                print("[SlapSound] Tony Stark Mode deactivated")
            }
        }
    }
    @Published var keyBinding: KeyBinding = .key1 {
        didSet {
            settings.keyBinding = keyBinding
            print("[SlapSound] Key binding: \(keyBinding.label)")
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
        // Load saved values from UserDefaults via settings
        let savedSensitivity = settings.sensitivity
        let savedCooldown = settings.cooldownMs
        let savedVolume = settings.masterVolume

        // Apply to detector and audio player DIRECTLY (didSet doesn't fire in init)
        detector.sensitivity = savedSensitivity
        detector.cooldownMs = savedCooldown
        detector.isEnabled = settings.isEnabled
        audioPlayer.masterVolume = Float(savedVolume)
        audioPlayer.volumeScaling = settings.volumeScaling
        audioPlayer.setSoundMode(settings.soundMode)

        // Set published properties (no didSet fires here, that's fine — we synced above)
        isEnabled = settings.isEnabled
        sensitivity = savedSensitivity
        cooldownMs = savedCooldown
        masterVolume = savedVolume
        volumeScaling = settings.volumeScaling
        slapCount = settings.slapCount
        tonyStarkMode = settings.tonyStarkMode
        soundMode = settings.soundMode
        keyBinding = settings.keyBinding

        // Wire up delegation
        let bridge = SlapBridge(appState: self)
        self.bridge = bridge
        reader.delegate = detector
        detector.delegate = bridge

        // Start audio
        audioPlayer.setup()

        // Start accelerometer
        let connected = reader.start()
        isConnected = connected
        if connected {
            statusMessage = "Listening for slaps..."
        } else if ProcessInfo.processInfo.environment["USER"] != "root" {
            statusMessage = "Run with sudo for accelerometer access"
        } else {
            statusMessage = "No accelerometer found (need M1 Pro+ MacBook)"
        }

        print("[SlapSound] === STARTUP ===")
        print("[SlapSound] Sensor: \(connected ? "CONNECTED" : "NOT FOUND")")
        print("[SlapSound] Sensitivity: \(String(format: "%.3f", savedSensitivity))g")
        print("[SlapSound] Cooldown: \(savedCooldown)ms")
        print("[SlapSound] Volume: \(Int(savedVolume * 100))%")
        print("[SlapSound] Sound: \(settings.soundMode.rawValue)")
        print("[SlapSound] Tony Stark: \(settings.tonyStarkMode ? "ON" : "OFF")")
        print("[SlapSound] Key bind: \(settings.keyBindingLabel)")
        print("[SlapSound] ===============")
    }

    func previewSound(_ mode: SoundMode) {
        audioPlayer.playPreview(mode: mode)
    }

    func previewJarvis() {
        audioPlayer.playJarvisBeep()
    }

    func previewJarvisStartup() {
        audioPlayer.playJarvisStartup()
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
        guard keyBinding.keyCode != 0 else { return }
        let source = CGEventSource(stateID: .hidSystemState)
        if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyBinding.keyCode, keyDown: true),
           let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyBinding.keyCode, keyDown: false) {
            keyDown.post(tap: .cghidEventTap)
            keyUp.post(tap: .cghidEventTap)
        }
    }

    func handleDoubleClap() {
        guard tonyStarkMode else { return }
        print("[SlapSound] DOUBLE CLAP in Tony Stark Mode — opening Terminal + Claude Code + Iron Man music!")

        // 1. Open Terminal and launch Claude Code
        let terminalScript = """
        tell application "Terminal"
            activate
            do script "claude"
        end tell
        """
        if let script = NSAppleScript(source: terminalScript) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if let error = error {
                print("[SlapSound] AppleScript error: \(error)")
            }
        }

        // 2. Open Iron Man soundtrack in browser
        let ironManURL = "https://www.youtube.com/watch?v=IyR25B-IGyg&list=RDIyR25B-IGyg&start_radio=1"
        if let url = URL(string: ironManURL) {
            NSWorkspace.shared.open(url)
        }

        // 3. Play the J.A.R.V.I.S. startup sound
        audioPlayer.playJarvisStartup()
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

    func slapDetectorDidDetectDoubleClap(_ detector: SlapDetector) {
        DispatchQueue.main.async { [weak self] in
            self?.appState?.handleDoubleClap()
        }
    }
}
