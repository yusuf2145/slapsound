# SlapSound

Slap your MacBook and it plays a whip crack sound. Volume scales with how hard you hit it. Also simulates pressing the "1" key on each slap.

Inspired by [SlapMac](https://slapmac.com/).

## How It Works

SlapSound reads your MacBook's built-in accelerometer/IMU via IOKit HID to detect physical impacts. When a slap is detected:

1. A whip crack sound plays (volume proportional to force)
2. The "1" key is simulated

The app runs as a menu bar icon with controls for sensitivity, cooldown, and volume.

## Requirements

- **Apple Silicon MacBook** (M1 Pro or newer — has built-in accelerometer)
- **macOS 14.0+** (Sonoma)
- **Swift 5.9+**
- Must run with `sudo` (IOKit HID accelerometer requires root access)

## Quick Start

```bash
# Clone the repo
git clone https://github.com/YusufGarba/slapsound.git
cd slapsound

# Build
swift build -c release

# Run (requires sudo for accelerometer access)
sudo .build/release/SlapSound
```

Or use the run script:

```bash
chmod +x run.sh
./run.sh
```

## Usage

Once running, look for the hand icon in your menu bar. Controls:

- **Enable/Disable** — toggle slap detection
- **Sensitivity** — how hard you need to hit (lower = more sensitive)
- **Cooldown** — minimum time between slap events
- **Volume** — master volume with optional force-based scaling
- **Slap Counter** — tracks your total slaps

## Custom Sound

Replace `Sources/SlapSound/Resources/Sounds/whipcrack.mp3` with any `.mp3`, `.wav`, or `.m4a` file named `whipcrack`, then rebuild:

```bash
swift build -c release
```

## Accessibility Permissions

For the simulated key press ("1" key) to work, you may need to grant Accessibility permissions:

**System Settings > Privacy & Security > Accessibility** — allow Terminal (or whichever app you run it from).

## Architecture

```
IOKit HID Accelerometer (~800 Hz)
    |
AccelerometerReader — parses 22-byte HID reports into g-force
    |
SlapDetector — magnitude threshold + STA/LTA algorithm + cooldown
    |
AudioPlayer — AVAudioEngine with volume/pitch scaling
    + KeyPress — CGEvent simulated "1" key
```

## License

MIT
