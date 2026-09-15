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
