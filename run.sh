#!/bin/bash
# SlapSound - Run with sudo for accelerometer access
# Requires Apple Silicon MacBook (M1 Pro+)

set -e

echo "Building SlapSound..."
swift build -c release 2>&1

BINARY=".build/release/SlapSound"

if [ ! -f "$BINARY" ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "==================================="
echo "  SlapSound - Whip Crack Edition"
echo "==================================="
echo ""
echo "Starting with sudo (required for accelerometer access)..."
echo "Look for the hand icon in your menu bar."
echo "Slap the side of your MacBook to hear the crack!"
echo ""
echo "Press Ctrl+C to quit."
echo ""

sudo "$BINARY"
