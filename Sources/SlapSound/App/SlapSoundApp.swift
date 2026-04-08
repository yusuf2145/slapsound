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

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        if let iconURL = Bundle.module.url(forResource: "AppIcon", withExtension: "icns") {
            if let icon = NSImage(contentsOf: iconURL) {
                NSApp.applicationIconImage = icon
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NSApp.activate(ignoringOtherApps: true)
            for window in NSApp.windows { window.makeKeyAndOrderFront(nil) }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    // Detection
    @Published var isConnected = false
    @Published var isEnabled = true {
        didSet { detector.isEnabled = isEnabled; settings.isEnabled = isEnabled }
    }
    @Published var sensitivity: Double = 0.05 {
        didSet { detector.sensitivity = sensitivity; settings.sensitivity = sensitivity }
    }
    @Published var cooldownMs: Int = 150 {
        didSet { detector.cooldownMs = cooldownMs; settings.cooldownMs = cooldownMs }
    }

    // Audio
    @Published var masterVolume: Double = 1.0 {
        didSet { audioPlayer.masterVolume = Float(masterVolume); settings.masterVolume = masterVolume }
    }
    @Published var volumeScaling: Bool = true {
        didSet { audioPlayer.volumeScaling = volumeScaling; settings.volumeScaling = volumeScaling }
    }
    @Published var soundMode: SoundMode = .whipCrack {
        didSet { audioPlayer.setSoundMode(soundMode); settings.soundMode = soundMode }
    }

    // Tony Stark
    @Published var tonyStarkMode: Bool = false {
        didSet {
            settings.tonyStarkMode = tonyStarkMode
            if tonyStarkMode {
                voiceListener.startListening(); voiceListening = true
            } else {
                audioPlayer.stopPlayback(); voiceListener.stopListening(); voiceListening = false
            }
        }
    }

    // Key binding
    @Published var keyBinding: KeyBinding = .key1 {
        didSet { settings.keyBinding = keyBinding }
    }

    // Speech
    @Published var speechMode: Bool = false {
        didSet { settings.speechMode = speechMode }
    }
    @Published var speechText: String = "Ouch!" {
        didSet { settings.speechText = speechText }
    }
    @Published var speechVoice: String = "" {
        didSet { settings.speechVoice = speechVoice }
    }

    // Theme
    @Published var themeName: ThemeName = .midnight {
        didSet { settings.themeNameRaw = themeName.rawValue }
    }
    var theme: AppTheme { AppTheme.forName(themeName) }

    // Combos
    @Published var currentCombo: Int = 0
    @Published var comboAchievement: String? = nil
    @Published var combosEnabled: Bool = true {
        didSet { comboDetector.isEnabled = combosEnabled; settings.combosEnabled = combosEnabled }
    }

    // Stats
    @Published var slapCount: Int = 0
    @Published var lastSlapForce: Double = 0
    @Published var statusMessage: String = "Starting..."
    @Published var recentSlaps: [SlapEvent] = []
    @Published var voiceListening = false
    @Published var lastHeardText = ""

    // Services
    let settings = AppSettings()
    let reader = AccelerometerReader()
    let detector = SlapDetector()
    let audioPlayer = AudioPlayer()
    let recorder = AudioRecorder()
    let voiceListener = VoiceCommandListener()
    let speechService = SpeechService()
    let comboDetector = ComboDetector()
    let slapHistory = SlapHistory()
    private var bridge: SlapBridge?
    private var voiceBridge: VoiceBridge?
    private var comboBridge: ComboBridge?

    private init() {
        var savedSensitivity = settings.sensitivity
        if savedSensitivity <= 0 || savedSensitivity > 5 { savedSensitivity = 0.05 }
        let savedCooldown = settings.cooldownMs > 0 ? settings.cooldownMs : 150

        detector.sensitivity = savedSensitivity
        detector.cooldownMs = savedCooldown
        detector.isEnabled = settings.isEnabled
        audioPlayer.masterVolume = Float(settings.masterVolume)
        audioPlayer.volumeScaling = settings.volumeScaling
        audioPlayer.setSoundMode(settings.soundMode)
        comboDetector.isEnabled = settings.combosEnabled
        comboDetector.timeout = settings.comboTimeout

        isEnabled = settings.isEnabled
        sensitivity = savedSensitivity
        cooldownMs = savedCooldown
        masterVolume = settings.masterVolume
        volumeScaling = settings.volumeScaling
        slapCount = settings.slapCount
        tonyStarkMode = settings.tonyStarkMode
        soundMode = settings.soundMode
        keyBinding = settings.keyBinding
        speechMode = settings.speechMode
        speechText = settings.speechText
        speechVoice = settings.speechVoice
        combosEnabled = settings.combosEnabled
        themeName = ThemeName(rawValue: settings.themeNameRaw) ?? .midnight

        // Wire delegates
        let bridge = SlapBridge(appState: self)
        self.bridge = bridge
        reader.delegate = detector
        detector.delegate = bridge

        let voiceBridge = VoiceBridge(appState: self)
        self.voiceBridge = voiceBridge
        voiceListener.delegate = voiceBridge

        let comboBridge = ComboBridge(appState: self)
        self.comboBridge = comboBridge
        comboDetector.delegate = comboBridge

        audioPlayer.setup()
        if recorder.hasRecording { audioPlayer.loadCustomSound(from: recorder.recordingURL) }

        let connected = reader.start()
        isConnected = connected
        statusMessage = connected ? "Listening for slaps..." :
            (ProcessInfo.processInfo.environment["USER"] != "root" ? "Run with sudo" : "No accelerometer")

        print("[SlapSound] Started — sensor: \(connected), theme: \(themeName.rawValue)")
    }

    func previewSound(_ mode: SoundMode) { audioPlayer.playPreview(mode: mode) }
    func previewJarvis() { audioPlayer.playJarvisBeep() }
    func previewJarvisStartup() { audioPlayer.playJarvisStartup() }

    func loadCustomSoundFromRecording() { audioPlayer.loadCustomSound(from: recorder.recordingURL) }
    func loadCustomSoundFromFile(_ url: URL) {
        let dest = recorder.recordingURL
        try? FileManager.default.removeItem(at: dest)
        try? FileManager.default.copyItem(at: url, to: dest)
        audioPlayer.loadCustomSound(from: dest)
        recorder.hasRecording = true
    }

    func handleSlap(_ event: SlapEvent) {
        slapCount += 1
        settings.slapCount = slapCount
        lastSlapForce = event.force
        recentSlaps.append(event)
        if recentSlaps.count > 50 { recentSlaps.removeFirst() }

        // Record in history
        slapHistory.addSlap(force: event.force, timestamp: event.timestamp)

        // Combo
        comboDetector.registerSlap()

        // Sound
        if tonyStarkMode {
            audioPlayer.playJarvisBeep()
        } else {
            audioPlayer.playSlap(force: event.force)
        }

        // Action: speech or key press
        if speechMode {
            speechService.speak(text: speechText, voiceID: speechVoice.isEmpty ? nil : speechVoice)
        } else {
            simulateKeyPress()
        }
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
        triggerTonyStarkAction()
    }

    func handleVoiceCommand(_ command: String) {
        guard tonyStarkMode else { return }
        lastHeardText = command
        triggerTonyStarkAction()
    }

    private func triggerTonyStarkAction() {
        let terminalScript = """
        tell application "Terminal"
            activate
            do script "claude"
        end tell
        """
        if let script = NSAppleScript(source: terminalScript) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
        }
        audioPlayer.playIronMan()
    }

    func handleComboUpdate(_ count: Int) {
        withAnimation { currentCombo = count }
    }

    func handleComboReset() {
        withAnimation { currentCombo = 0 }
    }

    func handleComboAchievement(_ name: String) {
        withAnimation { comboAchievement = name }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            withAnimation { self?.comboAchievement = nil }
        }
    }

    deinit {
        reader.stop(); audioPlayer.stop(); voiceListener.stopListening()
    }
}

// MARK: - Bridges

final class SlapBridge: SlapDetectorDelegate {
    private weak var appState: AppState?
    init(appState: AppState) { self.appState = appState }

    func slapDetector(_ detector: SlapDetector, didDetectSlap event: SlapEvent) {
        DispatchQueue.main.async { [weak self] in self?.appState?.handleSlap(event) }
    }
    func slapDetectorDidDetectDoubleClap(_ detector: SlapDetector) {
        DispatchQueue.main.async { [weak self] in self?.appState?.handleDoubleClap() }
    }
}

final class VoiceBridge: VoiceCommandDelegate {
    private weak var appState: AppState?
    init(appState: AppState) { self.appState = appState }

    func voiceCommandDetected(_ command: String) {
        DispatchQueue.main.async { [weak self] in self?.appState?.handleVoiceCommand(command) }
    }
}

final class ComboBridge: ComboDetectorDelegate {
    private weak var appState: AppState?
    init(appState: AppState) { self.appState = appState }

    func comboUpdated(count: Int) {
        DispatchQueue.main.async { [weak self] in self?.appState?.handleComboUpdate(count) }
    }
    func comboReset() {
        DispatchQueue.main.async { [weak self] in self?.appState?.handleComboReset() }
    }
    func comboAchievement(name: String) {
        DispatchQueue.main.async { [weak self] in self?.appState?.handleComboAchievement(name) }
    }
}
