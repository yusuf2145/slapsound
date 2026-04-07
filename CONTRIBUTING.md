# Contributing to SlapSound

Thanks for wanting to make SlapSound even better. Here's how to get involved.

## Getting Started

1. Fork the repo
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/slapsound.git
   cd slapsound
   ```
3. Build:
   ```bash
   swift build -c release
   ```
4. Run (requires Apple Silicon MacBook with accelerometer):
   ```bash
   sudo .build/release/SlapSound
   ```

## Requirements

- macOS 14.0+ (Sonoma)
- Apple Silicon MacBook (M1 Pro or newer)
- Swift 5.9+
- Must run with `sudo` for IOKit HID accelerometer access

## How to Contribute

### Adding a New Sound Pack

1. Add your sound file (`.mp3`, `.wav`, or `.m4a`) to `Sources/SlapSound/Resources/Sounds/`
2. Add a new case to the `SoundMode` enum in `Sources/SlapSound/Models/AppSettings.swift`
3. Add the sound key mapping in `AudioPlayer.swift` (`setSoundMode`, `playPreview`, `loadAllSounds`)
4. Add colors for the sound card in `SoundsView.swift` (`cardColors`)
5. Test it, submit a PR

### Adding a New Feature

1. Create a branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Test on a real MacBook (accelerometer features can't be tested in simulator)
4. Submit a PR with a clear description

### Bug Reports

Open an issue with:
- What you expected
- What actually happened
- Your Mac model and macOS version
- Terminal output (the app logs sensor data and events)

### Code Style

- Swift, SwiftUI
- No external dependencies (pure Apple frameworks)
- Keep it simple — this is a fun project

## Project Structure

```
Sources/SlapSound/
  App/              — App entry point, AppState, AppDelegate
  Models/           — Data models, settings, enums
  Services/         — AccelerometerReader, SlapDetector, AudioPlayer
  Views/            — SwiftUI views (Dashboard, Sounds, KeyBinds, TonyStark, Settings)
  Resources/Sounds/ — Bundled sound effect files
```

## Ideas We'd Love

- New sound packs (memes, movie clips, instruments)
- Clap pattern recognition (e.g., triple clap, rhythm patterns)
- Lid open/close detection (M2 Pro+)
- USB plug/unplug sounds
- Custom AppleScript actions on slap
- Menubar waveform visualizer

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
