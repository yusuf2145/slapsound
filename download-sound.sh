#!/bin/bash
# Download a whip crack sound effect from freesound.org
# Or generate one using macOS built-in tools

SOUND_DIR="Sources/SlapSound/Resources/Sounds"

echo "Generating a whip crack sound using macOS say + afconvert..."

# Use Python to generate a proper whip crack WAV
python3 -c "
import struct
import math
import random
import wave

sample_rate = 44100
duration = 0.35
num_samples = int(sample_rate * duration)

samples = []
for i in range(num_samples):
    t = i / sample_rate
    normalized = t / duration

    # Sharp attack envelope
    if normalized < 0.008:
        envelope = normalized / 0.008
    else:
        envelope = math.exp(-18.0 * (normalized - 0.008))

    # White noise (core whip sound)
    noise = random.uniform(-1.0, 1.0)

    # Initial transient crack
    if normalized < 0.004:
        crack = math.sin(2 * math.pi * 3000 * t) * (1.0 - normalized / 0.004)
    else:
        crack = 0

    # Mid frequency body
    body = math.sin(2 * math.pi * 800 * t) * math.exp(-25.0 * normalized) * 0.3

    # High frequency sizzle
    sizzle = math.sin(2 * math.pi * 6000 * t) * math.exp(-35.0 * normalized) * 0.2

    sample = (noise * 0.6 + crack * 0.9 + body + sizzle) * envelope * 0.85
    sample = max(-1.0, min(1.0, sample))
    samples.append(int(sample * 32767))

with wave.open('$SOUND_DIR/whipcrack.wav', 'w') as wav:
    wav.setnchannels(1)
    wav.setsampwidth(2)
    wav.setframerate(sample_rate)
    wav.writeframes(struct.pack('<' + 'h' * len(samples), *samples))

print('Generated whipcrack.wav')
"

echo "Sound file created at $SOUND_DIR/whipcrack.wav"
echo "Rebuild with: swift build"
