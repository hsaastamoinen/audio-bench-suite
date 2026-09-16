#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$ROOT/packaging/macos/release.conf"

bash -n "$ROOT/packaging/macos/build-suite-pkg.sh"
bash -n "$ROOT/packaging/macos/uninstall-suite.sh"

for p in \
 "$ROOT/packages/macOS/Matrix-Bench-${MATRIX_VERSION}.pkg" \
 "$ROOT/packages/macOS/MIDI-Bench-${MIDI_VERSION}-macOS.pkg" \
 "$ROOT/packages/macOS/Signal-Bench-${SIGNAL_VERSION}-macOS.pkg" \
 "$ROOT/packages/macOS/Spectral-Bench-${SPECTRAL_VERSION}-macOS.pkg" \
 "$ROOT/packages/macOS/Latency-Bench-${LATENCY_VERSION}.pkg" \
 "$ROOT/Handbook/publication/Audio-Bench-Suite-Handbook.pdf" \
 "$ROOT/Handbook/publication/Audio-Bench-Suite-Handbook.docx"
do
 [[ -f "$p" ]] || { echo "ERROR: missing pinned input $p"; exit 1; }
done

PKG="$ROOT/Dist/Audio-Bench-Suite-${SUITE_VERSION}-macOS.pkg"
if [[ -f "$PKG" ]]; then
  TMP="$(mktemp -d "${TMPDIR:-/tmp}/abs-suite-verify.XXXXXX")"
  trap 'rm -rf "$TMP"' EXIT
  pkgutil --expand-full "$PKG" "$TMP/product"
  expected=(
   "Matrix-Bench-${MATRIX_VERSION}.pkg"
   "MIDI-Bench-${MIDI_VERSION}-suite.pkg"
   "SignalBench-Standalone-suite.pkg" "SignalBench-AU-suite.pkg" "SignalBench-VST3-suite.pkg"
   "SpectralBench-App-suite.pkg" "SpectralBench-AU-suite.pkg" "SpectralBench-VST3-suite.pkg"
   "Latency-Bench-${LATENCY_VERSION}-suite.pkg"
   "Audio-Bench-Suite-Handbook.pkg"
  )
  for n in "${expected[@]}"; do
    [[ -d "$TMP/product/$n" ]] || { echo "ERROR: missing $n"; exit 1; }
  done
  echo "Suite package component check: OK (${#expected[@]})"
  shasum -a 256 "$PKG"
else
  echo "NOTE: suite package not built yet."
fi

echo
git -C "$ROOT" status --short
echo "VERIFY OK"
