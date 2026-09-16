# 60°N Signal Works Audio Bench Suite

Suite-level distribution and documentation project for:

- Matrix Bench
- MIDI Bench
- Signal Bench
- Spectral Bench
- Latency Bench

The macOS suite installer provides a single graphical Installer package with
six selectable items: the five Bench applications and the Audio Bench Suite
Handbook. All choices are selected by default.

## Current suite release

Versions are pinned in `packaging/macos/release.conf`.

The suite installs the standalone applications under:

`/Applications/60°N Signal Works Audio Bench Suite`

Signal Bench and Spectral Bench also install their Audio Unit and VST3 plug-ins.
Matrix Bench additionally installs its Core Audio HAL driver and persistent
headless routing engine through Matrix Bench's own qualified package.

## Handbook

The handbook publication master and authoritative rendered edition are:

- `Handbook/publication/Audio-Bench-Suite-Handbook.docx` — editable publication master
- `Handbook/publication/Audio-Bench-Suite-Handbook.pdf` — authoritative rendered publication

The handbook is maintained directly in the publication DOCX. There is no
separate Markdown handbook source.

The PDF is included as a selectable component of the macOS suite installer and
is installed alongside the applications.

## macOS distribution

Pinned qualified Bench installers are stored in `packages/macOS/`.

The final suite installer is built with:

    ./packaging/macos/build-suite-pkg.sh

and verified with:

    ./packaging/macos/verify.sh

The resulting release artifact is:

`Dist/Audio-Bench-Suite-<suite-version>-macOS.pkg`

See `packaging/macos/README.md` for the packaging architecture and release
procedure.
