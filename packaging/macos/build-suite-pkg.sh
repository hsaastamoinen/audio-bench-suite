#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$ROOT/packaging/macos/release.conf"

INPUT="$ROOT/packages/macOS"
HANDBOOK="$ROOT/Handbook/publication/Audio-Bench-Suite-Handbook.pdf"
OUT_DIR="$ROOT/Dist"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/audio-bench-suite.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

MATRIX="$INPUT/Matrix-Bench-${MATRIX_VERSION}.pkg"
MIDI="$INPUT/MIDI-Bench-${MIDI_VERSION}-macOS.pkg"
SIGNAL="$INPUT/Signal-Bench-${SIGNAL_VERSION}-macOS.pkg"
SPECTRAL="$INPUT/Spectral-Bench-${SPECTRAL_VERSION}-macOS.pkg"
LATENCY="$INPUT/Latency-Bench-${LATENCY_VERSION}.pkg"

for p in "$MATRIX" "$MIDI" "$SIGNAL" "$SPECTRAL" "$LATENCY" "$HANDBOOK"; do
  [[ -f "$p" ]] || { echo "ERROR: missing pinned input: $p" >&2; exit 1; }
done

PKGS="$WORK/pkgs"
EXP="$WORK/expanded"
mkdir -p "$PKGS" "$EXP" "$OUT_DIR"

# Matrix remains a byte-for-byte qualified component because its package-owned
# postinstall installs/starts the persistent engine and HAL driver.
ditto "$MATRIX" "$PKGS/Matrix-Bench-${MATRIX_VERSION}.pkg"

# Standalone application inputs are expanded for their qualified payload trees.
pkgutil --expand-full "$MIDI" "$EXP/midi"
pkgutil --expand-full "$SIGNAL" "$EXP/signal"
pkgutil --expand-full "$SPECTRAL" "$EXP/spectral"
pkgutil --expand-full "$LATENCY" "$EXP/latency"

MIDI_COMPONENT_PLIST="$WORK/midi-suite-components.plist"
pkgbuild --analyze --root "$EXP/midi/MIDI-Bench-${MIDI_VERSION}-component.pkg/Payload" "$MIDI_COMPONENT_PLIST"
plutil -replace '0.BundleIsRelocatable' -bool NO "$MIDI_COMPONENT_PLIST"
pkgbuild --root "$EXP/midi/MIDI-Bench-${MIDI_VERSION}-component.pkg/Payload" --component-plist "$MIDI_COMPONENT_PLIST" --identifier "works.60n.audiobenchsuite.midi" --version "$MIDI_VERSION" --install-location "/" "$PKGS/MIDI-Bench-${MIDI_VERSION}-suite.pkg"
SIGNAL_APP_COMPONENT_PLIST="$WORK/signal-app-suite-components.plist"
pkgbuild --analyze --root "$EXP/signal/SignalBench-Standalone.pkg/Payload" "$SIGNAL_APP_COMPONENT_PLIST"
plutil -replace '0.BundleIsRelocatable' -bool NO "$SIGNAL_APP_COMPONENT_PLIST"
pkgbuild --root "$EXP/signal/SignalBench-Standalone.pkg/Payload" --component-plist "$SIGNAL_APP_COMPONENT_PLIST" --identifier "works.60n.audiobenchsuite.signal.app" --version "$SIGNAL_VERSION" --install-location "/" "$PKGS/SignalBench-Standalone-suite.pkg"
pkgbuild --root "$EXP/signal/SignalBench-AU.pkg/Payload" --identifier "works.60n.audiobenchsuite.signal.au" --version "$SIGNAL_VERSION" --install-location "/" "$PKGS/SignalBench-AU-suite.pkg"
pkgbuild --root "$EXP/signal/SignalBench-VST3.pkg/Payload" --identifier "works.60n.audiobenchsuite.signal.vst3" --version "$SIGNAL_VERSION" --install-location "/" "$PKGS/SignalBench-VST3-suite.pkg"
SPECTRAL_APP_COMPONENT_PLIST="$WORK/spectral-app-suite-components.plist"
pkgbuild --analyze --root "$EXP/spectral/app.pkg/Payload" "$SPECTRAL_APP_COMPONENT_PLIST"
plutil -replace '0.BundleIsRelocatable' -bool NO "$SPECTRAL_APP_COMPONENT_PLIST"
pkgbuild --root "$EXP/spectral/app.pkg/Payload" --component-plist "$SPECTRAL_APP_COMPONENT_PLIST" --identifier "works.60n.audiobenchsuite.spectral.app" --version "$SPECTRAL_VERSION" --install-location "/Applications/60°N Signal Works Audio Bench Suite" "$PKGS/SpectralBench-App-suite.pkg"
pkgbuild --root "$EXP/spectral/au.pkg/Payload" --identifier "works.60n.audiobenchsuite.spectral.au" --version "$SPECTRAL_VERSION" --install-location "/Library/Audio/Plug-Ins/Components" "$PKGS/SpectralBench-AU-suite.pkg"
pkgbuild --root "$EXP/spectral/vst3.pkg/Payload" --identifier "works.60n.audiobenchsuite.spectral.vst3" --version "$SPECTRAL_VERSION" --install-location "/Library/Audio/Plug-Ins/VST3" "$PKGS/SpectralBench-VST3-suite.pkg"

LATENCY_COMPONENT_PLIST="$WORK/latency-suite-components.plist"
pkgbuild --analyze --root "$EXP/latency/Payload" "$LATENCY_COMPONENT_PLIST"
plutil -replace '0.BundleIsRelocatable' -bool NO "$LATENCY_COMPONENT_PLIST"
pkgbuild --root "$EXP/latency/Payload" --component-plist "$LATENCY_COMPONENT_PLIST" --identifier "works.60n.audiobenchsuite.latency" --version "$LATENCY_VERSION" --install-location "/" "$PKGS/Latency-Bench-${LATENCY_VERSION}-suite.pkg"
# Suite-owned double-clickable uninstaller component.
UNROOT="$WORK/uninstaller-root"
mkdir -p "$UNROOT/Applications/60°N Signal Works Audio Bench Suite"
ditto "$ROOT/packaging/macos/uninstall-suite.sh" "$UNROOT/Applications/60°N Signal Works Audio Bench Suite/Uninstall Audio Bench Suite.command"
chmod 755 "$UNROOT/Applications/60°N Signal Works Audio Bench Suite/Uninstall Audio Bench Suite.command"
pkgbuild --root "$UNROOT" --identifier "works.60n.audiobenchsuite.uninstaller.pkg" --version "$SUITE_VERSION" --install-location "/" "$PKGS/Audio-Bench-Suite-Uninstaller.pkg"

# Suite-owned handbook component.
HBROOT="$WORK/handbook-root"
mkdir -p "$HBROOT/Applications/60°N Signal Works Audio Bench Suite"
ditto "$HANDBOOK" \
  "$HBROOT/Applications/60°N Signal Works Audio Bench Suite/Audio Bench Suite Handbook.pdf"

pkgbuild \
  --root "$HBROOT" \
  --identifier "works.60n.audiobenchsuite.handbook.pkg" \
  --version "$SUITE_VERSION" \
  --install-location "/" \
  "$PKGS/Audio-Bench-Suite-Handbook.pkg"

# Read authoritative identifier/version metadata from each flat component.
pkg_meta() {
  local pkg="$1" tmp="$WORK/meta.$RANDOM"
  pkgutil --expand "$pkg" "$tmp" >/dev/null
  local id ver
  id="$(sed -n 's/.*identifier="\([^"]*\)".*/\1/p' "$tmp/PackageInfo" | head -1)"
  ver="$(sed -n 's/.*version="\([^"]*\)".*/\1/p' "$tmp/PackageInfo" | head -1)"
  rm -rf "$tmp"
  [[ -n "$id" && -n "$ver" ]] || { echo "ERROR: cannot read metadata: $pkg" >&2; exit 1; }
  printf '%s|%s' "$id" "$ver"
}

IFS='|' read -r MATRIX_ID MATRIX_PKG_VER <<< "$(pkg_meta "$PKGS/Matrix-Bench-${MATRIX_VERSION}.pkg")"
IFS='|' read -r MIDI_ID MIDI_PKG_VER <<< "$(pkg_meta "$PKGS/MIDI-Bench-${MIDI_VERSION}-suite.pkg")"
IFS='|' read -r SIGNAL_APP_ID SIGNAL_APP_VER <<< "$(pkg_meta "$PKGS/SignalBench-Standalone-suite.pkg")"
IFS='|' read -r SIGNAL_AU_ID SIGNAL_AU_VER <<< "$(pkg_meta "$PKGS/SignalBench-AU-suite.pkg")"
IFS='|' read -r SIGNAL_VST_ID SIGNAL_VST_VER <<< "$(pkg_meta "$PKGS/SignalBench-VST3-suite.pkg")"
IFS='|' read -r SPECTRAL_APP_ID SPECTRAL_APP_VER <<< "$(pkg_meta "$PKGS/SpectralBench-App-suite.pkg")"
IFS='|' read -r SPECTRAL_AU_ID SPECTRAL_AU_VER <<< "$(pkg_meta "$PKGS/SpectralBench-AU-suite.pkg")"
IFS='|' read -r SPECTRAL_VST_ID SPECTRAL_VST_VER <<< "$(pkg_meta "$PKGS/SpectralBench-VST3-suite.pkg")"
IFS='|' read -r LATENCY_ID LATENCY_PKG_VER <<< "$(pkg_meta "$PKGS/Latency-Bench-${LATENCY_VERSION}-suite.pkg")"
IFS='|' read -r HANDBOOK_ID HANDBOOK_VER <<< "$(pkg_meta "$PKGS/Audio-Bench-Suite-Handbook.pkg")"
IFS='|' read -r UNINSTALLER_ID UNINSTALLER_VER <<< "$(pkg_meta "$PKGS/Audio-Bench-Suite-Uninstaller.pkg")"

DIST="$WORK/Distribution.xml"
cat > "$DIST" <<EOF_DIST
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
  <title>60°N Signal Works Audio Bench Suite</title>
  <organization>works.60n</organization>
  <domains enable_localSystem="true"/>
  <options customize="always" require-scripts="false" hostArchitectures="arm64,x86_64"/>
  <choices-outline>
    <line choice="matrix"/>
    <line choice="midi"/>
    <line choice="signal"/>
    <line choice="spectral"/>
    <line choice="latency"/>
    <line choice="handbook"/>
    <line choice="uninstaller"/>
  </choices-outline>

  <choice id="matrix" title="Matrix Bench ${MATRIX_VERSION}" description="Audio routing matrix, virtual Core Audio device and persistent routing engine." start_selected="true">
    <pkg-ref id="${MATRIX_ID}"/>
  </choice>
  <choice id="midi" title="MIDI Bench ${MIDI_VERSION}" description="MIDI monitor, sender and command-file runner." start_selected="true">
    <pkg-ref id="${MIDI_ID}"/>
  </choice>
  <choice id="signal" title="Signal Bench ${SIGNAL_VERSION}" description="Standalone signal generator plus Audio Unit and VST3 plug-ins." start_selected="true">
    <pkg-ref id="${SIGNAL_APP_ID}"/><pkg-ref id="${SIGNAL_AU_ID}"/><pkg-ref id="${SIGNAL_VST_ID}"/>
  </choice>
  <choice id="spectral" title="Spectral Bench ${SPECTRAL_VERSION}" description="Standalone spectral measurement application plus Audio Unit and VST3 plug-ins." start_selected="true">
    <pkg-ref id="${SPECTRAL_APP_ID}"/><pkg-ref id="${SPECTRAL_AU_ID}"/><pkg-ref id="${SPECTRAL_VST_ID}"/>
  </choice>
  <choice id="latency" title="Latency Bench ${LATENCY_VERSION}" description="Physical two-path latency measurement and stimulus generation." start_selected="true">
    <pkg-ref id="${LATENCY_ID}"/>
  </choice>
  <choice id="handbook" title="Audio Bench Suite Handbook" description="Install the PDF user handbook with the suite." start_selected="true">
    <pkg-ref id="${HANDBOOK_ID}"/>
  </choice>
  <choice id="uninstaller" title="Audio Bench Suite Uninstaller" description="Install the double-clickable suite removal utility." start_selected="true">
    <pkg-ref id="${UNINSTALLER_ID}"/>
  </choice>

  <pkg-ref id="${MATRIX_ID}" version="${MATRIX_PKG_VER}">Matrix-Bench-${MATRIX_VERSION}.pkg</pkg-ref>
  <pkg-ref id="${MIDI_ID}" version="${MIDI_PKG_VER}">MIDI-Bench-${MIDI_VERSION}-suite.pkg</pkg-ref>
  <pkg-ref id="${SIGNAL_APP_ID}" version="${SIGNAL_APP_VER}">SignalBench-Standalone-suite.pkg</pkg-ref>
  <pkg-ref id="${SIGNAL_AU_ID}" version="${SIGNAL_AU_VER}">SignalBench-AU-suite.pkg</pkg-ref>
  <pkg-ref id="${SIGNAL_VST_ID}" version="${SIGNAL_VST_VER}">SignalBench-VST3-suite.pkg</pkg-ref>
  <pkg-ref id="${SPECTRAL_APP_ID}" version="${SPECTRAL_APP_VER}">SpectralBench-App-suite.pkg</pkg-ref>
  <pkg-ref id="${SPECTRAL_AU_ID}" version="${SPECTRAL_AU_VER}">SpectralBench-AU-suite.pkg</pkg-ref>
  <pkg-ref id="${SPECTRAL_VST_ID}" version="${SPECTRAL_VST_VER}">SpectralBench-VST3-suite.pkg</pkg-ref>
  <pkg-ref id="${LATENCY_ID}" version="${LATENCY_PKG_VER}">Latency-Bench-${LATENCY_VERSION}-suite.pkg</pkg-ref>
  <pkg-ref id="${HANDBOOK_ID}" version="${HANDBOOK_VER}">Audio-Bench-Suite-Handbook.pkg</pkg-ref>
  <pkg-ref id="${UNINSTALLER_ID}" version="${UNINSTALLER_VER}">Audio-Bench-Suite-Uninstaller.pkg</pkg-ref>
</installer-gui-script>
EOF_DIST

OUT="$OUT_DIR/Audio-Bench-Suite-${SUITE_VERSION}-macOS.pkg"
rm -f "$OUT"
LOG="$WORK/productbuild.log"

set +e
productbuild --distribution "$DIST" --package-path "$PKGS" "$OUT" 2>&1 | tee "$LOG"
rc=${pipestatus[1]}
set -e
(( rc == 0 )) || { echo "ERROR: productbuild failed ($rc)" >&2; exit "$rc"; }

if grep -qiE 'warning:.*could not be loaded|error:' "$LOG"; then
  echo "ERROR: rejecting productbuild diagnostics." >&2
  rm -f "$OUT"
  exit 1
fi

VERIFY="$WORK/product"
pkgutil --expand-full "$OUT" "$VERIFY"

echo "=== VERIFY STANDALONE RELOCATION POLICY ==="
for n in "MIDI-Bench-${MIDI_VERSION}-suite.pkg" "SignalBench-Standalone-suite.pkg" "SpectralBench-App-suite.pkg" "Latency-Bench-${LATENCY_VERSION}-suite.pkg"; do
  info="$VERIFY/$n/PackageInfo"
  [[ -f "$info" ]] || { echo "ERROR: missing PackageInfo for $n" >&2; exit 1; }
  python3 - "$info" "$n" <<'PY_RELOC'
import sys, xml.etree.ElementTree as ET
info,name=sys.argv[1],sys.argv[2]
root=ET.parse(info).getroot()
value=(root.get("relocatable") or "").lower()
if value not in ("false","no","0"):
    raise SystemExit(f"ERROR: {name}: pkg-info relocatable={root.get('relocatable')!r}")
print(f"NON-RELOCATABLE OK: {name} (pkg-info relocatable={root.get('relocatable')})")
PY_RELOC
done

expected=(
  "Matrix-Bench-${MATRIX_VERSION}.pkg"
  "MIDI-Bench-${MIDI_VERSION}-suite.pkg"
  "SignalBench-Standalone-suite.pkg"
  "SignalBench-AU-suite.pkg"
  "SignalBench-VST3-suite.pkg"
  "SpectralBench-App-suite.pkg"
  "SpectralBench-AU-suite.pkg"
  "SpectralBench-VST3-suite.pkg"
  "Latency-Bench-${LATENCY_VERSION}-suite.pkg"
  "Audio-Bench-Suite-Handbook.pkg"
  "Audio-Bench-Suite-Uninstaller.pkg"
)
for n in "${expected[@]}"; do
  [[ -d "$VERIFY/$n" ]] || { echo "ERROR: missing embedded component: $n" >&2; exit 1; }
done


echo
echo "=== SUITE PACKAGE ==="
ls -lh "$OUT"
pkgutil --check-signature "$OUT" || true
shasum -a 256 "$OUT"
echo
echo "BUILD VERIFY OK: all ${#expected[@]} expected components embedded."
