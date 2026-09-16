# macOS suite packaging

`build-suite-pkg.sh` builds the graphical 60°N Signal Works Audio Bench Suite
Installer distribution. Component versions are pinned in `release.conf`.

## Installer choices

The Installer exposes seven selectable choices, all selected by default:

- Matrix Bench
- MIDI Bench
- Signal Bench
- Spectral Bench
- Latency Bench
- Audio Bench Suite Handbook
- Audio Bench Suite Uninstaller

## Packaging architecture

Matrix Bench is embedded as its qualified flat component package and remains
intact so its package-owned post-install work, including the persistent engine
and Core Audio HAL driver installation, is preserved.

The pinned MIDI Bench, Signal Bench, Spectral Bench and Latency Bench release
products are expanded during the suite build to obtain their qualified payload
trees. The suite builder creates fresh suite-owned flat packages from those
payloads.

The MIDI Bench, Signal Bench standalone, Spectral Bench standalone and Latency
Bench packages are explicitly built as non-relocatable. This is required so
macOS Installer leaves the applications in the intended suite application
directory rather than relocating them to another existing copy of the same
bundle.

Signal Bench and Spectral Bench each contribute three suite components:
standalone application, Audio Unit and VST3.

The approved handbook PDF is taken from:

`Handbook/publication/Audio-Bench-Suite-Handbook.pdf`

and packaged as a suite-owned component installed at:

`/Applications/60°N Signal Works Audio Bench Suite/Audio Bench Suite Handbook.pdf`

The suite-owned double-clickable uninstaller is installed at:

`/Applications/60°N Signal Works Audio Bench Suite/Uninstall Audio Bench Suite.command`

## Build

From the repository root:

    ./packaging/macos/build-suite-pkg.sh

Output:

`Dist/Audio-Bench-Suite-<suite-version>-macOS.pkg`

The build performs structural checks on the generated distribution, including
the expected embedded component count and the non-relocatable policy for the
four suite-owned standalone application packages.

## Verification

Run:

    ./packaging/macos/verify.sh

Verification checks the pinned input packages, handbook publication files,
packaging scripts and, when present, the built suite package and its expected
11 embedded component packages. It also reports the suite package SHA-256.

The distribution is intentionally unsigned at this stage, matching the current
release-package policy.

## Installed locations

Standalone applications and the handbook:

`/Applications/60°N Signal Works Audio Bench Suite`

Signal/Spectral Audio Units:

`/Library/Audio/Plug-Ins/Components`

Signal/Spectral VST3 plug-ins:

`/Library/Audio/Plug-Ins/VST3`

Matrix Bench additionally owns its persistent engine/LaunchAgent, IPC runtime
and Core Audio HAL driver through the Matrix Bench package.

## Removal

`uninstall-suite.sh` is the suite-level removal source. The installer packages
it as the double-clickable `Uninstall Audio Bench Suite.command` alongside the
applications and handbook. It removes the suite applications, handbook and
itself, known Signal/Spectral plug-ins, Matrix Bench's persistent engine/HAL
components, and relevant package receipts.

The uninstall and clean-reinstall paths have been qualified against the final
suite package, including removal of suite-owned files, Matrix Bench engine/HAL
components and relevant package receipts.
