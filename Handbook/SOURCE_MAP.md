# Audio Bench Suite Handbook — source map

## Matrix Bench
- audio-matrix/README.md
- audio-matrix/docs/LATENCY_TESTING.md
- audio-matrix/docs/ROADMAP.md reviewed for context

## MIDI Bench
- midi-bench/README.md
- midi-bench/docs/ROADMAP.md reviewed for context

## Signal Bench
- signal-bench/README.md
- signal-bench/PROJECT_STATUS.md

## Spectral Bench
- spectral-bench/README.md
- spectral-bench/docs/MEASUREMENT_GUIDE.md
- spectral-bench/docs/MEASUREMENTS.md
- spectral-bench/docs/VALIDATION.md
- spectral-bench/docs/ARCHITECTURE.md
- spectral-bench/docs/FUTURE.md reviewed for context

## Latency Bench
- latency-bench/README.md
- latency-bench/docs/MEASUREMENT_GUIDE.md
- latency-bench/docs/MEASUREMENT_METHOD.md
- latency-bench/docs/REFERENCE_MEASUREMENTS.md
- latency-bench/docs/ROADMAP.md reviewed for context

## Editorial rule
The handbook reorganizes source documentation for publication and cross-suite use. Roadmaps remain project-history material unless a validated technical fact needs to appear in the handbook.

## Consistency-pass policy
Before publication, version-specific behavior and numerical qualification claims are checked against the listed project documents rather than against earlier handbook wording. The handbook is macOS-first. Roadmap items are included only when the corresponding behavior is implemented and validated.

The MIDI Bench 2.0.0 command-file reference is taken from `midi-bench/README.md`: `.mbmidi` with required `MIDI-BENCH-FILE 1.0` header, `WAIT` delays, optional final `LOOP`, and Browse/Edit/Run/Stop/Syntax controls.

### Matrix Bench 2.1.1 consistency check
Checked against `audio-matrix/README.md` and `audio-matrix/docs/LATENCY_TESTING.md`. Publication-sensitive points include per-output-device routing identity, the persistent launchd engine, unavailable-device name retention, 8x8 virtual-device channel use, virtual feedback rejection/recovery, independent-output clock handling, and persistent-client physical latency qualification across 16/32/64/128/256/512-frame buffers.

### Signal Bench 2.0.0 consistency check
Checked against `signal-bench/README.md` and `signal-bench/PROJECT_STATUS.md`. The handbook already reflects the source-backed macOS 2.0.0 release state, including the macOS 2.0.0 / Windows-Linux 1.1.0 version split, final installer-only clean-install qualification, Standalone/AU/VST3 validation, GUI-only meter ballistics, deterministic preset behavior, Pink-noise regression, and the 0.48 x sample-rate harmonic Nyquist guard. The published macOS version follows the qualified release documentation rather than the stale 1.1.0 CMake project-version field present in the source snapshot.

### Spectral Bench 2.1.0 consistency check
Checked against `spectral-bench/README.md`, `spectral-bench/docs/MEASUREMENT_GUIDE.md`, `spectral-bench/docs/MEASUREMENTS.md`, `spectral-bench/docs/VALIDATION.md`, and `spectral-bench/docs/ARCHITECTURE.md`. Publication-sensitive points include the fixed two-channel referenced sweep topology, DUT-channel role swapping, Transfer versus Actual semantics, Raw/Auto/Manual/Baseline phase interpretation, PNG/CSV/TXT Save Result behavior, export identity terminology, the 20/20 automated suite, and physical sweep/phase qualification.

### Latency Bench 1.1.1 consistency check
Checked against `latency-bench/README.md`, `latency-bench/docs/MEASUREMENT_GUIDE.md`, `latency-bench/docs/MEASUREMENT_METHOD.md`, and `latency-bench/docs/REFERENCE_MEASUREMENTS.md`. The handbook already reflects the qualified 1.1.1 estimator and measurement semantics: deterministic bipolar broadband probe, baseline subtraction, normalized correlation with fractional-sample refinement, overlap-weighted evidence, 0.10 primary-evidence threshold, 90% competing-candidate ambiguity rejection, automatic extended analysis with magnitude-matched reference spectrum, ten-run median reporting, and the distinction between complete filtered-response timing and bare transport latency.

### Global publication consistency check
Completed after the five application-specific source reconciliations. The canonical Markdown is macOS-first, uses plain Markdown rather than LaTeX inline delimiters, avoids em-dash typography in publication prose, retains application-specific validation terminology, and preserves the chapter-numbered figure-placeholder scheme for the separate screenshot/figure production list. Version-sensitive technical claims remain governed by the application consistency checks above.
