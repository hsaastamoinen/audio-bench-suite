#!/usr/bin/env bash
set -euo pipefail

SUITE="/Applications/60°N Signal Works Audio Bench Suite"
LABEL="works.60n.matrixbench.engine"
CONSOLE_USER="$(stat -f '%Su' /dev/console 2>/dev/null || true)"

echo "This removes the installed 60°N Signal Works Audio Bench Suite."
echo "Administrator privileges are required."

# Stop Matrix Bench per-user engine first.
if [[ -n "$CONSOLE_USER" && "$CONSOLE_USER" != "root" && "$CONSOLE_USER" != "loginwindow" ]]; then
    UID_NUM="$(id -u "$CONSOLE_USER")"
    USER_HOME="$(dscl . -read "/Users/$CONSOLE_USER" NFSHomeDirectory 2>/dev/null | awk '{print $2}')"
    launchctl asuser "$UID_NUM" launchctl bootout "gui/$UID_NUM/$LABEL" >/dev/null 2>&1 || true
    if [[ -n "$USER_HOME" ]]; then
        sudo rm -f "$USER_HOME/Library/LaunchAgents/$LABEL.plist"
        sudo rm -rf "$USER_HOME/Library/Application Support/60N Signal Works/Matrix Bench"
    fi
fi

# Apps and installed handbook.
sudo rm -rf \
  "$SUITE/Matrix Bench.app" \
  "$SUITE/MIDI Bench.app" \
  "$SUITE/Signal Bench.app" \
  "$SUITE/Spectral Bench.app" \
  "$SUITE/Latency Bench.app" \
  "$SUITE/Audio Bench Suite Handbook.pdf" \
  "$SUITE/Uninstall Audio Bench Suite.command"

# Signal/Spectral plug-ins, where installed by their component packages.
sudo rm -rf \
  "/Library/Audio/Plug-Ins/Components/Signal Bench.component" \
  "/Library/Audio/Plug-Ins/VST3/Signal Bench.vst3" \
  "/Library/Audio/Plug-Ins/Components/Spectral Bench.component" \
  "/Library/Audio/Plug-Ins/VST3/Spectral Bench.vst3"

# Matrix system components.
sudo rm -rf \
  "/Library/Audio/Plug-Ins/HAL/60N Audio Matrix.driver" \
  "/Library/Application Support/60N Signal Works/Matrix Bench"

# Remove suite directory only if empty.
if [[ -d "$SUITE" ]] && [[ -z "$(find "$SUITE" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    sudo rmdir "$SUITE"
fi

# Forget receipts so a later clean reinstall is not influenced by stale receipts.
for id in \
  works.60n.audiobenchsuite.uninstaller.pkg \
  works.60n.audiobenchsuite.handbook.pkg \
  works.60n.audiobenchsuite.midi \
  works.60n.audiobenchsuite.signal.app \
  works.60n.audiobenchsuite.signal.au \
  works.60n.audiobenchsuite.signal.vst3 \
  works.60n.audiobenchsuite.spectral.app \
  works.60n.audiobenchsuite.spectral.au \
  works.60n.audiobenchsuite.spectral.vst3 \
  works.60n.latencybench.pkg \
  works.60n.matrixbench.pkg \
  works.60n.audiomatrix.pkg \
  works.60n.signalbench.standalone \
  works.60n.signalbench.au \
  works.60n.signalbench.vst3 \
  works.60n.spectralbench.app.pkg \
  works.60n.spectralbench.au.pkg \
  works.60n.spectralbench.vst3.pkg \
  com.harrisaastamoinen.signalbench.standalone \
  com.harrisaastamoinen.signalbench.au \
  com.harrisaastamoinen.signalbench.vst3
do
    sudo pkgutil --forget "$id" >/dev/null 2>&1 || true
done

killall -9 AudioComponentRegistrar >/dev/null 2>&1 || true

echo "Audio Bench Suite removed."
echo "A logout/login or restart is recommended after removing the Matrix virtual Core Audio driver."
