# 60°N Signal Works Audio Bench Suite Handbook

**macOS edition — canonical Markdown source**

**Status:** Working publication source  
**Applications:** Matrix Bench, MIDI Bench, Signal Bench, Spectral Bench, Latency Bench  
**Purpose:** Comprehensive user manual, measurement guide, validation reference, and technical handbook.

> This Markdown file is the maintainable source edition of the handbook. It documents the current macOS releases of the Audio Bench Suite. Windows and Linux are mentioned only where platform context is technically useful. A publication copy can later be generated as DOCX for manual screenshot placement and page layout, followed by final PDF production. Figure placeholders are intentional and are to be replaced with real screenshots, photographs, or manually prepared diagrams.

## How to use this handbook

The handbook is deliberately layered. If the immediate goal is to make a measurement or use an application, go directly to the relevant Bench chapter. For interpretation, uncertainty, validation and implementation detail, continue into the measurement fundamentals, workflow, validation and technical-reference chapters.

The individual project documentation remains the engineering source material for each application. This handbook reorganizes and edits that material into a coherent suite-level publication. It is not intended to reproduce project READMEs verbatim or expose development history where that history does not help the user operate or understand the tools.

## Which Bench should I use?

| Goal | Primary Bench | Often useful with |
| --- | --- | --- |
| Generate tones, noise, two-tone/IM and other test stimuli | **Signal Bench** | Spectral Bench |
| Inspect spectrum, level, harmonics, THD/THD+N, IMD, sweeps and phase | **Spectral Bench** | Signal Bench |
| Measure physical-path or DUT latency | **Latency Bench** | Matrix Bench / external routing |
| Route, split, mix, process and monitor physical and virtual audio | **Matrix Bench** | All audio Benches |
| Monitor, transmit and sequence MIDI | **MIDI Bench** | MIDI-controlled DUTs |

## Measurement mindset

The Bench applications are tools, not substitutes for defining the measurement. A numerically precise result can still answer the wrong question if the signal path, level, sample rate, routing or measurement definition is wrong.

1. **Define what is being measured.** Transport latency, complete filtered-response timing, THD, THD+N, IMD and a spectrum trace answer different questions.
2. **Control the signal path.** Avoid clipping, unintended feedback, wrong channels, accidental sample-rate conversion and processing that is not part of the intended DUT path.
3. **Establish a reference.** A cable loopback, baseline, known signal or other reference separates the DUT from the measurement setup where the method allows it.
4. **Check repeatability.** Repeated measurements expose unstable routing, clocking, signal conditions and ambiguous estimators.
5. **Record enough context to reproduce the result.** Application version, device, sample rate, channel routing, relevant buffer settings, DUT state and measurement settings all matter.

# 1. Audio Bench Suite

## 1.1 Purpose and scope

The 60°N Signal Works Audio Bench Suite is a collection of focused macOS engineering tools rather than one monolithic measurement application. Each Bench has a narrow primary responsibility, and the applications can be combined when a measurement needs generation, routing, analysis, timing or MIDI control at the same time.

The suite currently consists of:

- **Signal Bench**, deterministic audio test-signal generation.
- **Spectral Bench**, spectral, level, distortion, sweep and phase analysis.
- **Latency Bench**, physical-path and DUT latency measurement.
- **Matrix Bench**, low-latency physical and virtual audio routing, mixing, monitoring and utility processing.
- **MIDI Bench**, MIDI monitoring, transmission and deterministic command-file sequencing.

The handbook's primary target is the latest qualified macOS release of each application. Historical versions and other operating systems are discussed only when they explain compatibility, measurement behavior or a relevant implementation detail.

## 1.2 Installation model

The intended macOS installation location for the applications is:

`/Applications/60°N Signal Works Audio Bench Suite`

Suite-level installer standardization is a separate distribution task. Until a consolidated installer is qualified, the individual application packages remain the installation units. When reproducing an older measurement, verify the application version actually used rather than assuming that a current installation behaves identically in every implementation detail.

<!-- FIGURE PLACEHOLDER: Figure 1.1
Application: Audio Bench Suite
Subject: Installed Bench applications
Show: The five current macOS Bench applications together in Finder in the suite installation folder.
Crop: Finder window or suite folder contents only; exclude unrelated desktop items.
Suggested size: full text width
Caption: The five Audio Bench Suite applications installed on macOS.
-->

**Figure 1.1.** The five Audio Bench Suite applications installed on macOS.

## 1.3 A practical way to choose the tool

Start from the physical question rather than from the application. If the DUT needs a known stimulus, start with Signal Bench. If the unknown is spectral behavior, distortion or phase, use Spectral Bench. If the unknown is elapsed time through a physical path, use Latency Bench. Use Matrix Bench when the difficulty is routing, monitoring, splitting or combining physical and virtual paths. Use MIDI Bench when repeatable MIDI control or observation is part of the test.

A single experiment may use several Benches. For example, Signal Bench can excite a DUT while Spectral Bench observes its output. Matrix Bench can provide repeatable routing around that setup. MIDI Bench can change DUT states between measurements. Latency Bench is deliberately more self-contained because its timing estimator generates and captures its own probe.

## 1.4 Common setup principles

Use a known audio interface and explicit input/output channels. Set the intended sample rate before beginning a measurement. Where buffer size is relevant, choose it intentionally and record it. Disable unrelated processing unless it is deliberately part of the path under test.

For physical loopback work, label cables and channels. Verify routing at a conservative level before increasing signal level. A surprising number of apparent algorithmic or DUT failures are actually wrong-channel, wrong-loop or gain-staging errors.

Bluetooth and aggregate or virtual routing deserve extra attention because they can introduce fixed sample-rate constraints, additional buffering, sample-rate conversion or independent clock domains. Those effects are not automatically measurement errors; they become errors when they are present but not part of the quantity the test is meant to measure.

## 1.5 Reproducibility record

For measurements worth keeping, record at least:

- Bench name and version;
- macOS audio device and relevant input/output channels;
- sample rate;
- buffer size where it can affect the result;
- DUT identity and state;
- physical and virtual routing;
- generator and analyzer settings;
- baseline/reference state where applicable;
- repeated-run statistics or other evidence of stability when the tool provides them.

Saved result files should be kept with enough human-readable context that they still make sense after the physical setup has been dismantled.

# 2. Audio and measurement fundamentals

This chapter establishes the conventions used throughout the handbook. The individual Bench chapters provide application-specific detail, but the same distinctions between digital level, analog level, samples, time, phase and physical signal paths apply everywhere.

## 2.1 Digital level and dBFS

The audio Benches use digital full scale as the primary digital amplitude reference. `0 dBFS` is the maximum representable reference level of the digital system; it is not an analog voltage. A setting of, for example, `-20 dBFS` says nothing by itself about volts at an interface output or volts arriving at a DUT input. The analog value also depends on interface calibration, output gain, input sensitivity and any intervening analog gain or attenuation.

Peak, RMS and spectral level are also different quantities. A sine wave's peak level, its RMS level and the amplitude reported for its FFT component are related only when the measurement convention is known. Likewise, broadband-noise RMS cannot be compared directly with the level of one FFT bin without accounting for bandwidth and analyzer normalization.

The practical rule is simple: compare like with like, and state the level convention when the distinction matters.

## 2.2 Headroom, clipping and gain staging

Digital clipping occurs when a signal exceeds the representable range at a point in the digital path. Analog clipping can occur earlier or later in the chain even while the digital meter appears safe. Conversely, a signal can be so low that analog noise, converter noise or numerical uncertainty dominates the measurement.

For test work, begin conservatively, verify the path, then raise the stimulus only as far as needed for useful signal-to-noise ratio and DUT operating level. If distortion is being measured, distinguish distortion intentionally produced by the DUT from clipping accidentally produced by the generator, interface or analyzer input.

## 2.3 Sample rate, samples and time

A sampled system represents time in discrete intervals. At sample rate `Fs`, one sample corresponds to:

`sample time = 1 / Fs`

At 48 kHz, one sample is approximately `20.833 µs`; 48 samples equal 1 ms. At 44.1 kHz, one sample is approximately `22.676 µs`.

Latency Bench can report fractional-sample timing because its correlation peak is interpolated rather than restricted to an integer sample index. Fractional-sample reporting does not imply that the audio interface physically delays data by a fractional hardware sample; it is an estimate of relative timing from the captured waveform.

## 2.4 Buffer size is not the same as latency

Audio buffer size affects scheduling and can be a major component of end-to-end latency, but it is not itself a complete latency specification. Hardware safety buffers, converter filters, USB or other transport buffering, driver behavior, application callbacks, independent clock domains and sample-rate conversion can all contribute.

The same distinction matters in the opposite direction: a client callback size does not necessarily reveal every internal hardware or driver buffer in the path. When latency matters, measure the path that matters rather than calculating a result from one buffer-size field alone.

## 2.5 Frequency, bandwidth and spectral resolution

Frequency describes periodic rate; bandwidth describes a range of frequencies. In FFT analysis, the nominal bin spacing is determined by sample rate and FFT length. A larger FFT provides finer bin spacing but represents a longer time record. Windowing changes spectral leakage and the effective noise bandwidth, so bin spacing alone does not describe the analyzer's ability to separate or quantify arbitrary components.

For broadband measurements, bandwidth is part of the result. Noise integrated over a wider bandwidth normally contains more total power than the same noise process integrated over a narrower bandwidth. This is one reason THD and THD+N must not be treated as interchangeable measurements.

## 2.6 FFT windows, coherent gain and noise bandwidth

An FFT operates on a finite block. Unless the captured waveform joins perfectly at the block boundaries, treating that block as periodic produces leakage. A window weights the block to control that leakage, but the weighting changes amplitude and noise behavior.

Two corrections therefore matter in a calibrated analyzer:

- **coherent gain**, which relates the windowed FFT amplitude of a coherent tone to its true amplitude;
- **equivalent noise bandwidth (ENBW)**, which describes the noise bandwidth represented by a windowed FFT bin.

Spectral Bench defines its own spectrum and measurement semantics in detail. Do not infer calibrated tone or noise values from an arbitrary FFT display without knowing these conventions.

## 2.7 Frequency response, phase and polarity

Frequency response is complex: it has both magnitude and phase. A filter can leave a frequency's magnitude nearly unchanged while rotating its phase, or strongly change both.

Polarity is a separate concept. Reversing polarity multiplies the waveform by `-1`, equivalent to a 180-degree phase inversion at every frequency in the ideal linear case. A constant polarity reversal is therefore not the same thing as frequency-dependent phase shift.

This distinction matters in both spectral and timing work. A correlation method that uses correlation magnitude can still identify a time offset through an inverted path, while preserving the sign of the raw correlation as useful evidence about polarity. The application-specific estimator rules are documented in the Latency Bench chapter.

## 2.8 Phase delay and group delay

A causal filter necessarily has phase behavior associated with its transfer function. Group delay describes how phase slope varies with frequency and is especially important for bandwidth-limited signals, crossovers and steep filters.

This leads to a critical interpretation rule for latency measurements: the timing of a **complete filtered response** is not necessarily the same quantity as the DUT's bare digital transport latency. A steep HPF, LPF, crossover or band-pass can shift the dominant correlation timing by several milliseconds even if the underlying transport delay is unchanged.

Neither result is inherently wrong. They answer different questions. The measurement setup and report must make clear which quantity is being interpreted.

## 2.9 Correlation and time-of-arrival estimation

Cross-correlation compares two signals while shifting one relative to the other. A peak indicates the displacement at which the signals are most alike according to the estimator. With a broadband deterministic probe, this can provide precise relative timing even when the DUT changes level or introduces moderate linear filtering.

The highest numerical peak is not automatically trustworthy. Strong filtering can broaden a correlation lobe, reduce overlap, or create several plausible peaks. A robust estimator therefore needs evidence and ambiguity rules in addition to peak finding. Latency Bench deliberately rejects measurements when competing timing interpretations are too close rather than forcing every capture into a result.

## 2.10 Repeatability, accuracy and uncertainty

These terms answer different questions. **Repeatability** describes how closely repeated measurements agree under the same conditions. **Accuracy** describes closeness to the quantity intended to be measured. A result can be extremely repeatable yet systematically wrong because the baseline, routing or interpretation is wrong.

Measurement uncertainty includes more than statistical run-to-run variation. Device clocks, analog noise, estimator behavior, filter phase, sample-rate conversion, channel mismatch and setup changes can all matter. Where a Bench reports standard deviation or competing candidates, treat those as evidence about a specific part of the measurement, not as a complete uncertainty budget for the entire physical experiment.

## 2.11 Baselines and reference paths

A baseline removes a known contribution only if the baseline represents the contribution that should be removed. In a physical latency measurement, a direct reference loop can characterize interface and routing delay so that the DUT measurement can be expressed relative to it. If cables, devices, sample rate or channel assignments change, the old baseline may no longer describe the current setup.

The same principle applies beyond latency. A known generator level, loopback spectrum or reference device can expose measurement-system behavior before an unknown DUT is introduced.

## 2.12 Physical paths, virtual paths and clock domains

A path entirely inside one synchronous digital clock domain behaves differently from a path crossing independent devices. When two hardware devices run from independent clocks, their nominal sample rates are not exactly identical. Long-running routing may therefore require asynchronous sample-rate conversion or another clock-domain strategy.

Virtual audio devices add routing flexibility but do not make clocking, buffering or feedback concerns disappear. Matrix Bench's virtual-device and independent-output-clock behavior is covered in its own chapter.

## 2.13 A minimum pre-measurement check

Before trusting an important result, confirm:

1. the intended input and output devices and channels;
2. the intended sample rate;
3. safe, useful signal levels without unintended clipping;
4. the intended DUT state and processing;
5. the reference or baseline, if the method depends on one;
6. repeatability over more than one run when practical;
7. that the reported quantity is actually the one the experiment was designed to measure.

That short check prevents more bad measurements than additional decimal places ever will.

# 3. Signal Bench

Signal Bench is the suite's deterministic signal and stimulus generator.


<!-- FIGURE PLACEHOLDER: Figure 3.1
Application: Signal Bench
Subject: Main application window
Show: Signal mode, primary controls, output level, mute and meters.
Suggested size: full text width
Caption: Signal Bench main window and primary signal-generation controls.
-->

**Figure 3.1.** Signal Bench main window and primary signal-generation controls.


## 3.1 Practical starting workflow

Choose the required signal mode, set a conservative output level, confirm the physical/virtual output path and then unmute. When driving an analog DUT, remember that a digital dBFS setting does not by itself specify analog voltage; interface calibration and gain staging determine the actual voltage.

For distortion and intermodulation work, use defined presets when repeatability matters.


## 3.2 Complete Signal Bench reference

**Current versions:** macOS **2.0.0**; Windows x64 / Linux x86_64 **1.1.0**

Signal Bench is a compact audio test-signal generator built with C++17, JUCE and CMake. It combines broadband Pink and White noise with a deterministic Dual Sine mode for ordinary two-tone measurements, intermodulation testing and guitar-oriented nonlinear-signal experiments.

The project began as a pink-noise generator, but its scope grew enough that Signal Bench is now treated as the product name. macOS has advanced to Signal Bench 2.0.0 for the current UI/packaging release, while the validated Windows x64 and Linux x86_64 distributions remain at 1.1.0. Earlier Pink Noise Generator version numbering is intentionally not carried forward in current documentation or distribution package names.

Current target formats are:

- macOS: Standalone, Audio Unit and VST3
- Windows x64: Standalone and VST3
- Linux x86_64: Standalone and VST3

#### Feature set

- Pink and White broadband noise
- selectable low-cut and high-cut filters with 6/12/24 dB/oct slopes
- Dual Sine generation with independently adjustable F1/F2 and tone levels
- phase-continuous oscillators with 20 ms frequency smoothing
- guitar-oriented Root + Interval presets from E2 through E5
- 12-TET and Just interval calculations
- optional H2-H5 harmonic enrichment
- optional Slicer with Gate and Guitar envelope shapes
- deterministic Guitar envelope and Pick Attack excitation
- adjustable Pick Attack level and first-order low-pass filter
- master Output Level and Mute
- stereo peak metering with dBFS scale
- persistent host-visible parameters

#### Design goals

The generator is intended to be useful for repeatable engineering work rather than to imitate an instrument in every detail.

The Dual Sine path therefore favors:

- deterministic output
- known frequencies
- known amplitude relationships
- repeatable envelopes
- repeatable Pick Attack events
- simple mathematical behavior
- no hidden randomization between retriggers
- no oversampling-dependent or model-dependent "humanization"

The Guitar envelope and Pick Attack options are measurement stimuli inspired by guitar behavior, not physical string or pickup models.

#### Signal modes

##### Pink

Pink noise uses Stefan Stenzel's **A New Shade of Pink** multirate algorithm, specifically the extended low-frequency form with 20 octave-spaced one-bit noise sources. Stefan suggested this algorithm for Signal Bench, replacing the earlier Paul Kellet pinking filter.

The method is unusually attractive for a real-time test generator because spectral accuracy and computational cost are both good. Instead of filtering full-rate white noise through a conventional approximation to a -3 dB/octave response, it combines independent one-bit noise sequences running at octave-spaced rates. First-order-hold (linear) interpolation gives the individual sources a steeper high-frequency roll-off than the zero-order-hold approach used by Voss/McCartney-style generators. A small 12-tap FIR correction term then trims the residual high-frequency error near Nyquist.

Stenzel's implementation reduces the multirate interpolation to bit-state updates plus an accumulator. The FIR sees one-bit data, so its possible results can be precomputed as two 64-entry lookup tables. There is no per-sample general FIR convolution and no need for transcendental functions in the pink-noise path.

Signal Bench uses Stenzel's extended 20-source low-frequency variant rather than only the 12-source form described in the main article. The extra very-low-rate sources cost almost nothing because they update only occasionally, while extending the low-frequency behavior for high host sample rates. The implementation keeps the algorithm's bit-oriented state machine and FIR coefficients, but expresses the original IEEE-754 accumulator trick as ordinary C++ floating-point arithmetic. This avoids type-punning/aliasing tricks and makes the code safer and clearer across Clang, GCC and MSVC.

A fixed output scale of `1.6` is applied after the generator to keep its RMS level and practical headroom in the same general range as the previous Signal Bench pink source. This scaling changes level only; it does not change the spectral shape. A deterministic 16,777,216-sample reference run measured approximately `0.1941 RMS` for the previous Paul Kellet implementation and `0.1954 RMS` for the Stenzel implementation with this scale factor, a difference of about 0.7%. The scale factor is therefore a compatibility normalization, not part of Stenzel's algorithm.

The Stenzel implementation was also measured directly from a deterministic 16,777,216-sample float capture using Welch-style overlapping Hann-window periodograms and 1/6-octave power averaging. The ideal comparison is a fitted `1/f` power spectral density, so the test measures spectral *shape* independently of absolute output level. The same discrete-time capture was interpreted at the supported host rates to check where the fixed generator spectrum falls in the 20 Hz to 20 kHz audio band:

| Interpreted sample rate | RMS spectral error vs fitted 1/f PSD | Maximum absolute 1/6-octave-bin error |
|---:|---:|---:|
| 44.1 kHz | 0.066 dB | 0.212 dB |
| 48 kHz | 0.070 dB | 0.284 dB |
| 96 kHz | 0.085 dB | 0.295 dB |
| 192 kHz | 0.118 dB | 0.350 dB |

The same run measured `0.195411 RMS` (`-14.18 dBFS`) and a peak magnitude of `0.916451`, leaving useful headroom. Signal Bench keeps regression limits deliberately looser than the observed values: RMS must remain between `0.185` and `0.205`, peak magnitude below `1.0`, RMS spectral error no greater than `0.15 dB`, and maximum 1/6-octave-bin error no greater than `0.40 dB`. The limits are intended to catch implementation regressions without pretending that one finite stochastic capture is an exact analytical proof.

The reference capture has a finite-record mean of about `+0.0499`. With the 20-source low-frequency form this is not treated as a fixed DC-offset failure: some of the additional octave-spaced components evolve on timescales much longer than a several-minute capture, so a finite segment need not average close to zero. A true DC term would require a different test than simply asserting a near-zero mean on one finite record.

The reproducible tools are `tools/pink_noise_dump.cpp` and `tools/analyze_pink_noise.py`. Running the analyser with `--check` applies the regression limits above. NumPy is used only by the offline analysis tool, not by Signal Bench itself.
For the complete four-rate check, create/reuse the project `.venv` with NumPy and run `tools/validate_pink_noise.sh`. It generates one deterministic 16,777,216-sample capture and evaluates it at 44.1, 48, 96 and 192 kHz with the regression limits enabled. `PINK_VALIDATION_SAMPLES` can be overridden for development smoke tests, but the published reference values above use the full 16,777,216-sample run.

The repository also contains `tools/pink_noise_dump.cpp` and `tools/analyze_pink_noise.py` for repeatable offline checks. The analysis tool reports RMS, finite-record mean, peak level and a 1/6-octave-smoothed PSD error against a fitted ideal `1/f` spectrum over 20 Hz to 20 kHz, or to 45% of the host sample rate when that is lower. The finite-record mean is reported rather than used as a strict DC test because the 20-source form intentionally contains extremely slow noise components; a finite capture can therefore have a visibly non-zero mean without containing a deterministic DC offset.

Left and right channels use independent deterministic generator states, so stereo Pink output is decorrelated rather than duplicated mono noise. Resetting the processor restores deterministic starting states, which is useful for repeatable tests.

##### Pink-noise algorithm credit

The pink-noise algorithm is based on work by **Stefan Stenzel**, who also directly suggested using it in Signal Bench. His article *A New Shade of Pink* / *Not so new shade of pink* describes the multirate first-order-hold method, the LFSR-based one-bit noise sources and the FIR lookup-table correction. His reference repository states that the work is public domain.

References:

- Stefan Stenzel, *Not so new shade of pink*, DSP Bricks, May 2026: https://www.dspbricks.com/articles/pink-noise/
- Stefan Stenzel, *A New Shade of Pink* reference implementation: https://github.com/Stenzel/newshadeofpink

Signal Bench's implementation is an adaptation for its C++17/JUCE architecture; it is not a verbatim drop-in of Stenzel's original source.

##### White

White noise is generated directly from the internal xorshift64* pseudorandom-number generators.

The two output channels use different deterministic seeds and independent states.

##### Dual Sine

Dual Sine generates two independently adjustable sinusoidal components:

- **F1:** 10 Hz to 24 kHz
- **F2:** 10 Hz to 24 kHz
- **Tone 1 Level:** -60 to 0 dB
- **Tone 2 Level:** -60 to 0 dB

Defaults:

- F1: `110.00 Hz`
- F2: `164.81378 Hz`
- Tone 1 Level: `-6.0 dB`
- Tone 2 Level: `-6.0 dB`

The default frequencies correspond to A2 and E3 in 12-tone equal temperament.

Both oscillators are phase-continuous. A frequency control change does not reset oscillator phase. Manual frequency changes are smoothed over approximately 20 ms to reduce discontinuities.

The generated Dual Sine sample is copied coherently to every active output channel.

#### Dual Sine oscillator generation

Each oscillator maintains a phase accumulator.

For frequency `f`, sample rate `Fs` and current phase `phi`, one sample is generated from:

```text
x = sin(phi)
```

and the phase is advanced by:

```text
phi_next = phi + 2*pi*f/Fs
```

with phase wrapping at `2*pi`.

Frequency values are read through JUCE `SmoothedValue` objects. When F1 or F2 changes, the target frequency is approached over approximately 20 ms. Phase itself is not reset.

This distinction is important for measurement use: changing the frequency may create the expected time-varying waveform during the transition, but it does not create an artificial hard phase restart.

#### Two-tone and intermodulation testing

A two-tone signal is useful for testing nonlinear systems because nonlinearities generate frequency components that are absent from the original input.

For input frequencies `f1` and `f2`, products can include:

```text
f2 - f1
f1 + f2
2f1 - f2
2f2 - f1
2f1 + f2
2f2 + f1
```

plus higher-order combinations.

The generator does not calculate the resulting distortion products. It supplies known input components so the output of the device under test can be examined using, for example:

- a DAW spectrum analyzer
- an FFT analyzer
- an oscilloscope
- an audio analyzer
- custom measurement software

#### Measurement stimulus presets

Dual Sine also includes one-action presets matched to Spectral Bench measurement modes:

- **100 Hz single tone**
- **1 kHz single tone**
- **10 kHz single tone**
- **SMPTE-style:** 60 Hz + 7 kHz, with the 7 kHz tone 12.0412 dB below the 60 Hz tone (4:1 amplitude ratio)
- **CCIF:** 19 kHz + 20 kHz, equal amplitudes

Loading a measurement preset selects Dual Sine, disables the low-cut and high-cut filters, slicer, added harmonics, and pick-attack shaping, and writes the required tone frequencies and relative levels. Single-tone presets disable Tone 2.

The preset deliberately preserves the master **OUTPUT LEVEL** and **MUTE** state. This keeps the defined stimulus relationship deterministic without unexpectedly changing the user's overall test level or unmuting the generator.

The SMPTE-style and CCIF presets correspond directly to the matching selective-product analysis modes in Spectral Bench.

#### Guitar-oriented interval presets

Dual Sine includes a convenience preset loader for common guitar-related two-note tests.

##### Root range

Preset roots are selectable chromatically from:

```text
E2 through E5
```

E2 is approximately 82.41 Hz and E5 approximately 659.26 Hz in 12-TET.

The E2-E5 range covers a practical guitar-oriented fundamental range while keeping the preset control concise. F1 and F2 remain freely adjustable over their complete 10 Hz-24 kHz ranges after loading a preset.

##### Intervals

Available intervals are:

- minor 3rd
- major 3rd
- 5th
- octave

For example, with A2 as the root in 12-TET:

| Preset | Interval |
| --- | --- |
| `A2 + C3` | minor 3rd |
| `A2 + C#3` | major 3rd |
| `A2 + E3` | 5th / power-chord interval |
| `A2 + A3` | octave |

Loading a preset writes the calculated frequencies into the normal F1/F2 parameters and turns **Tone 2 ON**, because the preset defines a two-tone interval stimulus. It does not lock the frequency controls.

#### 12-TET and Just tuning

The preset loader supports 12-tone equal temperament and simple Just ratios.

##### 12-TET

For an interval of `n` semitones:

```text
f2 = f1 * 2^(n/12)
```

The intervals used by the UI are:

| Interval | Semitones |
| --- | ---: |
| minor 3rd | 3 |
| major 3rd | 4 |
| 5th | 7 |
| octave | 12 |

##### Just

The Just option uses:

| Interval | Ratio |
| --- | ---: |
| minor 3rd | `6/5` |
| major 3rd | `5/4` |
| 5th | `3/2` |
| octave | `2/1` |

This can be useful when comparing how a nonlinear system behaves with equal-tempered versus pure-ratio input tones.

#### Harmonic enrichment

Dual Sine includes a shared **HARMONICS** switch. It is **Off by default**.

When Off, each oscillator contributes only its sine fundamental.

When On, each tone contains its fundamental plus H2 through H5. Harmonic amplitude is:

```text
amplitude(n) = 1 / n^2
```

relative to the fundamental of that tone.

Approximate levels are:

| Harmonic | Relative level |
| --- | ---: |
| H2 | -12.04 dB |
| H3 | -19.08 dB |
| H4 | -24.08 dB |
| H5 | -27.96 dB |

For each harmonic:

```text
harmonic_frequency = fundamental_frequency * harmonic_number
```

A harmonic is omitted when:

```text
harmonic_frequency >= 0.48 * sample_rate
```

The 0.48 × Fs limit leaves a small guard below Nyquist rather than attempting to generate components arbitrarily close to Fs/2.

The harmonic mode is deliberately simple and deterministic. It is useful for producing a richer known stimulus, but it is not intended to model a real guitar string.

#### Slicer

The Slicer is available in Dual Sine mode and is **Off by default**.

Parameters:

- **Slicer Rate:** 0.2 to 5.0 Hz
- Default Slicer Rate: 2.0 Hz
- **Shape:** Gate or Guitar
- **SLICER ON:** explicit enable switch

The slicer phase is advanced sample by sample from the selected rate.

Pink and White modes do not use the Slicer.

##### Gate shape

Gate is a deterministic 50% duty-cycle amplitude gate.

The nominal cycle is:

```text
raised-cosine rise
-> full level
-> raised-cosine fall
-> zero
```

Rise and fall time:

```text
12 ms
```

The finite raised-cosine edges reduce discontinuities compared with an instantaneous rectangular gate.

##### Guitar shape

Guitar shape replaces the 50% gate with a deterministic picked-chord-style amplitude envelope.

The envelope consists of:

- fixed 5 ms raised-cosine onset
- 35% fast-decay component
- 65% slow-decay component
- fixed fast time constant: 120 ms
- adjustable slow decay: 0.2 to 5.0 s
- default slow decay: 2.0 s

For time `t` after the attack, the body is conceptually:

```text
body(t) =
    0.35 * exp(-t / 0.120)
  + 0.65 * exp(-t / slow_decay)
```

The beginning of each cycle is made continuous with the mathematically calculated end level of the previous cycle. The envelope therefore does not forcibly jump to zero at retrigger.

The selected Slicer Rate determines the retrigger period.

#### Pick Attack

Pick Attack is an optional additional excitation available when:

```text
Signal Type = Dual Sine
SLICER ON = enabled
Shape = Guitar
PICK ATTACK = enabled
```

It is **Off by default**.

The purpose is to add a short, repeatable pick/string-contact texture to the beginning of the Guitar envelope without turning the generator into a stochastic instrument simulation.

##### Pick Attack source

The excitation starts from a deterministic xorshift32 pseudorandom sequence.

The PRNG and Pick Attack filter states are reset to the same values at every Slicer retrigger. Every Pick Attack event is therefore repeatable.

The raw pseudorandom sequence is processed through two simple first-order operations:

1. an adjustable first-order low-pass
2. a fixed high-pass-style emphasis produced by subtracting a slower one-pole memory

The fixed high-pass memory uses a nominal 1 kHz coefficient.

##### Pick Attack low-pass

**PICK LPF** controls the first-order low-pass cutoff:

```text
500 Hz to 12 kHz
```

Default:

```text
1800 Hz
```

The one-pole coefficient is calculated from the current sample rate:

```text
a = exp(-2*pi*fc/Fs)
```

The filter is therefore sample-rate aware.

##### Pick Attack timing

The Pick Attack event has:

- total duration: 5 ms
- raised-cosine attack ramp: 3 ms
- exponential decay time constant: approximately 1.7 ms
- final cosine tail: 1.5 ms

The final tail forces the short event smoothly to zero at the end of its 5 ms window.

The Pick Attack is then multiplied by the **same Guitar amplitude envelope** used for the tonal signal. This glues its timing to the chord envelope rather than treating it as a completely independent click.

##### Pick Attack level

**PICK LEVEL** range:

```text
-20.0 to 0.0 dB
```

Default:

```text
-4.0 dB
```

The current Pick Attack implementation includes an internal normalization factor so that 0 dB represents a genuinely useful diagnostic maximum for this deliberately short filtered excitation. The user-facing PICK LEVEL control is the intended operating gain.

The Pick Attack level is not additionally multiplied by the Tone 1 or Tone 2 level controls.

#### Detailed Dual Sine signal flow

Without Pick Attack:

```text
F1 parameter
  -> 20 ms frequency smoothing
  -> phase-continuous oscillator
  -> optional H2...H5
  -> Tone 1 Level
                                     \
                                      + -> Guitar/Gate envelope
                                     /      -> master Output Level
F2 parameter                               -> Mute
  -> 20 ms frequency smoothing             -> output buffer
  -> phase-continuous oscillator            -> meter peak capture
  -> optional H2...H5
  -> Tone 2 Level
```

With Guitar Pick Attack:

```text
deterministic xorshift32
  -> first-order adjustable Pick LPF
  -> fixed ~1 kHz high-pass emphasis
  -> 5 ms Pick Attack time envelope
  -> internal normalization
  -> PICK LEVEL
  -> Guitar amplitude envelope
                                      \
F1 tone path --------------------------+
                                       + -> master Output Level
F2 tone path --------------------------+    -> Mute
                                            -> output buffer
                                            -> meter peak capture
```

The Pick Attack PRNG and filter states are reset identically on each Guitar retrigger.

#### Broadband-noise bandwidth controls

Pink and White modes include independent Low Cut and High Cut controls.

- **Low Cut:** 10 Hz to 2 kHz
- **High Cut:** 500 Hz to 24 kHz
- **Slope:** 6, 12 or 24 dB/octave
- **Default:** both filters Off
- **Default selected slope:** 12 dB/octave

Implementation:

- 6 dB/oct: first-order section
- 12 dB/oct: second-order Butterworth section
- 24 dB/oct: two cascaded second-order sections forming a fourth-order Butterworth alignment

The High Cut is clamped internally below Nyquist if the user-selected value is too high for the current sample rate.

These bandwidth filters are disabled in Dual Sine mode. Dual Sine spectral content is generated directly.

#### Pink / White signal flow

```text
independent channel PRNG
  -> Pink filter, if Pink mode
  -> optional Low Cut
  -> optional High Cut
  -> master Output Level
  -> Mute
  -> output buffer
  -> channel meter peak capture
```

White mode bypasses the pinking filter.

#### Output Level and headroom

Master **Output Level** range:

```text
-60.0 to 0.0 dB
```

Default:

```text
-18.0 dB
```

In Pink and White modes it is applied after bandwidth filtering.

In Dual Sine mode it is applied after the tonal components, optional harmonics, Slicer/Guitar envelope and optional Pick Attack have been combined.

The Tone 1 and Tone 2 levels are independent of master Output Level.

Multiple components can sum above full scale. For example, two fundamentals, their harmonics and Pick Attack can all contribute to the instantaneous output. The generator intentionally does not insert an automatic limiter because limiting would alter the measurement stimulus.

The default tone levels and master level provide conservative starting headroom, but users remain responsible for suitable levels.

The dB controls are gain controls; they are not claims of calibrated broadband RMS dBFS output.

#### Mute

**MUTE** zeros the final output sample after generation and gain processing.

Metering follows the muted final value, so the meters fall toward their floor while muted.

#### Metering

The UI provides independent left and right peak indicators with a central dBFS scale.

Scale markings:

```text
0
-6
-12
-18
-24
-36
-48
-60 dBFS
```

##### What the meter measures

The DSP peak is calculated from the same final sample value that is written to the audio output buffer.

For Dual Sine, the flow is effectively:

```text
generate final sample
-> write sample to output buffer
-> compare abs(sample) with current block peak
-> publish block peak to UI
```

For Pink and White, each output channel performs the same process independently.

There is no separate Slicer or Guitar-envelope timing path for the meter.

##### Visible meter lead versus audible output

The UI can visibly react before a listener hears the corresponding sample at the physical audio output. This is not an internal generator/meter synchronization offset: the meter reads the buffer before downstream host and audio-device buffers have necessarily reached the DAC.

The amount of apparent lead can therefore depend on:

- audio-device buffer size
- host buffering
- driver behavior
- output-device latency

No fixed artificial meter delay is applied because the correct compensation would be system dependent.

UI smoothing affects only the displayed bars and does not alter audio.

The meters are useful indicators, not precision calibrated analyzer channels.

#### Parameters and state persistence

The plug-in uses JUCE `AudioProcessorValueTreeState`.

Host-visible, persistent parameters are:

- Signal Type
- Output Level
- Low Cut Enabled
- Low Cut
- High Cut Enabled
- High Cut
- Filter Slope
- Mute
- Tone 1 Frequency
- Tone 2 Frequency
- Tone 1 Level
- Tone 2 Level
- Slicer Enabled
- Slicer Rate
- Slicer Shape
- Guitar Decay
- Pick Attack Enabled
- Pick Attack Level
- Pick Attack Low Pass
- Harmonics Enabled

The guitar Root / Interval / Tuning selectors and LOAD button are convenience UI controls. Loading a preset calculates and writes F1 and F2 into the normal persistent frequency parameters.

#### Plug-in formats

##### macOS

- Standalone
- Audio Unit
- VST3

The AU is configured as a Music Device (`aumu`), allowing Logic Pro to expose it as a Software Instrument.

AU identity:

```text
aumu / SgB1 / Sn60
```

Vendor / manufacturer:

```text
60°N Signal Works
```

Bundle identifier:

```text
works.60n.signalbench
```

##### Windows x64

- Standalone
- VST3

##### Linux x86_64

- Standalone
- VST3

Audio Unit is macOS-only.

#### Platform validation status

Signal Bench 2.0.0 for macOS retains the validated 1.1.0 signal-generation/DSP baseline and adds the current macOS UI and packaging work. The final 2.0.0 clean-install validation is performed from the generated installer before release.

The macOS 2.0.0 changes include:

- Matrix Bench-style stereo output meters with engineering dB scales
- GUI-only fast-attack / approximately 0.5 s release meter ballistics; audio/DSP measurements are not smoothed
- compacted upper rotary controls and vertical layout
- `OUTPUT LEVEL` meter heading and revised meter placement
- refreshed line-free spectrum icon artwork, used by the macOS app bundle
- Standalone installation inside `/Applications/60°N Signal Works Audio Bench Suite`

The established macOS validation baseline includes:

- clean native Release build
- Standalone installed and tested
- Audio Unit installed, validated with `auval`, and tested in Logic Pro
- VST3 built and installed
- VST3 vendor metadata verified as UTF-8 `60°N Signal Works`
- macOS installer package built, installed, and smoke-tested
- measurement stimulus presets functionally tested
- Pink-noise regression validation passed at 44.1, 48, 96, and 192 kHz

Signal Bench 1.1.0 remains the validated native release on Windows x64 and Linux x86_64. The Windows Release build, installer, installed Standalone and VST3 were smoke-tested successfully. The Linux Release build, four-rate pink-noise regression, portable package, installed Standalone and VST3, and desktop integration were validated successfully.

The macOS distribution package is currently unsigned. Platform security mechanisms may therefore warn about or block it; see the installation notes below.

#### Future development

##### Output Level headroom investigation

An increase above the current **0 dB maximum Output Level** was investigated, particularly because broadband Pink noise can appear relatively low in RMS level compared with a sine-wave stimulus.

The investigation showed that this is not unused digital headroom. White noise already approaches full-scale peaks by construction, while the deterministic Pink-noise generator produces approximately **-14.18 dBFS RMS** but has observed instantaneous peaks close to **0 dBFS**. The lower Pink-noise RMS level is therefore a consequence of its broadband statistical waveform and crest factor, not an unnecessarily conservative master-level limit.

The existing **0 dB maximum is intentionally retained**.

Signal Bench will not increase broadband-noise level by introducing hidden limiting, compression, clipping, peak normalization, or other nonlinear processing. Doing so would alter the measurement stimulus and would be contrary to the purpose of the application.

The existing Pink and White noise generators therefore remain unchanged.

#### Requirements

Common requirements:

- Git
- CMake 3.22 or newer
- C++17 compiler
- Internet access for the first configure unless JUCE is already available locally

CMake fetches JUCE from its official repository and pins JUCE `8.0.10`.

##### macOS prerequisites

Build:

- Xcode Command Line Tools or Xcode
- Apple Clang
- macOS SDK
- CMake
- Git

Installer:

- `pkgbuild`
- `productbuild`

Public distribution without Gatekeeper warnings requires appropriate Apple signing and notarization.

##### Windows x64 prerequisites

Build:

- Git
- CMake
- Visual Studio 2022 Build Tools with C++ workload

Installer:

- Inno Setup 6

Optional icon regeneration:

- ImageMagick

##### Linux x86_64 prerequisites

The tested Ubuntu toolchain uses:

- Git
- CMake
- Ninja
- GCC/G++
- ImageMagick for installation-time icon resizing

JUCE development packages used on Ubuntu include:

```text
libasound2-dev
libjack-jackd2-dev
libx11-dev
libxext-dev
libxrandr-dev
libxinerama-dev
libxcursor-dev
libfreetype6-dev
libfontconfig1-dev
libgl1-mesa-dev
libglu1-mesa-dev
libwebkit2gtk-4.1-dev
libgtk-3-dev
```

Package names can differ on other distributions.

#### Build

##### macOS

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release -j
```

After installing the AU:

```sh
auval -v aumu SgB1 Sn60
```

##### Windows x64

From PowerShell:

```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
```

##### Linux x86_64

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build -j "$(nproc)"
```

#### macOS installer

Build:

```sh
./packaging/macos/build-installer.sh
```

Expected output:

```text
dist/Signal-Bench-2.0.0-macOS.pkg
```

The package installs:

```text
/Applications/60°N Signal Works Audio Bench Suite/Signal Bench.app
/Library/Audio/Plug-Ins/Components/Signal Bench.component
/Library/Audio/Plug-Ins/VST3/Signal Bench.vst3
```

The package is unsigned unless signing identities are supplied to the packaging script. The macOS 2.0.0 release is validated by removing the previous local installation and performing a clean installer-only installation before the release checkpoint.

##### Installing an unsigned macOS package

Only bypass Gatekeeper when the package source is trusted.

If macOS blocks the package:

1. Attempt to open the `.pkg`.
2. Dismiss the warning.
3. Open **System Settings -> Privacy & Security**.
4. Find the blocked-package message.
5. Choose **Open Anyway**.
6. Authenticate if requested.
7. Confirm the action.
8. Run the installer normally.

Restart the plug-in host if it was open during installation.

#### Windows installer

Build Release targets first:

```powershell
powershell -ExecutionPolicy Bypass -File .\packaging\windows\build-installer.ps1
```

Expected output:

```text
dist\Signal-Bench-1.1.0-Windows-x64.exe
```

The installer places the Standalone application under:

```text
C:\Program Files\Signal Bench\
```

and VST3 under:

```text
C:\Program Files\Common Files\VST3\Signal Bench.vst3
```

The Windows installer is unsigned unless a separate signing workflow is used.

#### Linux package

Build Release targets first:

```sh
./packaging/linux/build-package.sh
```

Expected output:

```text
dist/Signal-Bench-1.1.0-Linux-x86_64.tar.gz
```

After extracting:

```sh
./install.sh
```

Per-user installation paths:

```text
~/.local/bin/signal-bench
~/.vst3/Signal Bench.vst3
~/.local/share/applications/signal-bench.desktop
~/.local/share/icons/hicolor/256x256/apps/signal-bench.png
```

Uninstall:

```sh
./uninstall.sh
```

The portable archive is not claimed to be binary-compatible with every Linux distribution.

#### Source layout

```text
Source/
  PinkNoise.h
  BandwidthFilter.h
  PluginProcessor.h
  PluginProcessor.cpp
  PluginEditor.h
  PluginEditor.cpp
  Assets/

tests/
  source regression checks
  dual-sine preset math
  slicer envelope math
  harmonics math
  guitar envelope math
  Pick Attack math
  bandwidth-filter regression tests

packaging/macos/
  macOS package resources and build script

packaging/windows/
  Inno Setup definition, icon and build script

packaging/linux/
  portable-package, install/uninstall and desktop-integration resources

```

#### Regression tests

The project contains small source and mathematical regression checks for the deterministic DSP behavior.

Current checks include:

- expected parameter and UI wiring
- E2-E5 preset range
- 12-TET and Just interval math
- Gate envelope behavior
- Guitar envelope behavior
- H2-H5 harmonic generation
- Nyquist guard behavior
- Pick Attack timing and deterministic reset behavior
- Pick Attack LPF parameter wiring
- current UI layout invariants

The tests are not a substitute for native plug-in-host and installer validation.

#### Limitations

- Pink noise is generated with Stefan Stenzel's multirate **A New Shade of Pink** method. As with any finite-band digital generator, behavior is bounded by the host sample rate and the finite set of octave-spaced sources rather than being an analytical 1/f process extending to DC and infinity.
- Output levels are not broadband RMS-calibrated.
- The built-in meters are indicators rather than calibrated measurement instruments.
- UI meter timing can visibly lead the physical audio output because of downstream buffering.
- Harmonic enrichment is deliberately simple and deterministic; it is not a guitar-string model.
- The Guitar envelope is a deterministic measurement envelope, not a physical string model.
- Pick Attack is a deterministic filtered-noise excitation, not a physical pick/string/contact simulation.
- Gate duty cycle is fixed at 50%.
- Gate edge time is fixed at 12 ms.
- Dual Sine can exceed full scale when multiple components are summed at high levels.
- No automatic limiter is inserted.
- Harmonics near Nyquist are omitted rather than oversampled.
- The portable Linux archive depends on compatible runtime libraries and is not guaranteed to run on every distribution.
- Public macOS and Windows distribution without warnings requires platform-appropriate signing; macOS public distribution additionally benefits from notarization.

#### License

MIT License. See [LICENSE](LICENSE).

Copyright (c) 2026 Harri Saastamoinen

## 3.3 Validation and release state

Product: **Signal Bench**

Versions: **macOS 2.0.0; Windows x64 / Linux x86_64 1.1.0**

Signal Bench 2.0.0 is the current macOS release line. Windows x64 and Linux x86_64 remain at the validated 1.1.0 release. The 2.0.0 macOS work retains the established signal-generation/DSP behavior while updating the UI, meter presentation/ballistics, artwork and macOS packaging.

#### Current feature set

- Pink noise
- White noise
- Dual Sine
- independent F1/F2 and Tone 1/Tone 2 levels
- phase-continuous oscillators with 20 ms frequency smoothing
- guitar Root + Interval presets from E2 through E5
- 12-TET / Just tuning
- optional H2-H5 harmonics with 1/n^2 amplitude
- Nyquist guard at 0.48 × sample rate for harmonic enrichment
- optional 0.2-5 Hz Slicer
- Gate shape with 12 ms raised-cosine edges
- deterministic Guitar envelope
- adjustable Guitar slow decay
- deterministic Pick Attack excitation
- Pick Attack Level: -20 to 0 dB, default -4 dB
- Pick Attack LPF: 500 Hz to 12 kHz, default 1800 Hz
- Pink/White bandwidth filters
- master Output Level and Mute
- stereo peak metering
- macOS 2.0.0: Matrix Bench-style horizontal meter presentation with dB scales
- macOS 2.0.0: GUI-only fast attack / approximately 0.5 s meter release smoothing; no audio/DSP smoothing
- macOS 2.0.0: compact UI layout and refreshed line-free spectrum icon
- Standalone / AU / VST3 on macOS
- Standalone / VST3 on Windows x64 and Linux x86_64

#### Identity

- Product name: `Signal Bench`
- CMake/JUCE target: `SignalBench`
- bundle ID: `works.60n.signalbench`
- manufacturer code: `Sn60`
- plug-in code: `SgB1`
- product version: macOS `2.0.0`; Windows/Linux `1.1.0`

Changing the product identity and plug-in code means hosts should treat Signal Bench as the new product rather than as an in-place update of Pink Noise Generator.

#### Pink-noise validation

Stefan Stenzel's 20-source **A New Shade of Pink** implementation has passed the deterministic long-record analysis on macOS. Across 44.1, 48, 96 and 192 kHz interpretations, measured 20 Hz to 20 kHz RMS spectral-shape error remained between 0.066 dB and 0.118 dB, with maximum 1/6-octave-bin error between 0.212 dB and 0.350 dB. The normalized output measured 0.195411 RMS (-14.18 dBFS) with 0.916451 peak magnitude. These measurements are now backed by explicit regression limits in `tools/analyze_pink_noise.py --check`.

#### Measurement stimulus presets

Signal Bench includes one-action presets for fast analyzer testing:

- 100 Hz single tone
- 1 kHz single tone
- 10 kHz single tone
- SMPTE-style 60 Hz + 7 kHz, 4:1 amplitude ratio
- CCIF 19 kHz + 20 kHz, equal amplitude

Loading a measurement preset establishes a clean deterministic stimulus by selecting Dual Sine, setting the required frequencies and relative tone levels, and disabling filters, slicer, added harmonics, and pick-attack shaping. Single-tone presets disable Tone 2; SMPTE and CCIF presets enable it. Master Output Level and Mute are preserved. Guitar interval presets enable Tone 2 automatically when loaded.

#### Validation state

The established 1.1.0 signal-generation baseline was validated natively on all three target platforms. macOS 2.0.0 retains that DSP baseline and has passed its final native build, installer and clean-install validation gate.

##### macOS

- clean native Release build passed
- Standalone installed and tested
- Audio Unit installed, validated with `auval`, and tested in Logic Pro
- VST3 built and installed; vendor metadata verified
- macOS 2.0.0 native Release build, installer payload, clean uninstall, installer-only fresh install, installed Standalone smoke test and final UI/function validation passed
- measurement stimulus presets functionally tested
- Pink-noise regression validation passed at 44.1, 48, 96, and 192 kHz

##### Linux x86_64

- Release build passed
- four-rate Pink-noise regression passed
- portable package built and tested
- installed Standalone and VST3 tested
- desktop integration validated

##### Windows x64

- Release build passed
- installer built and tested
- installed Standalone and VST3 smoke-tested

#### Release policy

macOS releases may advance independently when changes are macOS-specific; Windows and Linux remain at 1.1.0 until separately rebuilt and validated. Preserve native platform validation for release candidates that change DSP, product identity, packaging, or host-facing behavior. The macOS 2.0.0 release checkpoint passed clean installer-only installation and final functional validation.

#### Future development

##### Extended Output Level range / headroom study

Investigate extending the master Output Level above the current 0 dB maximum, particularly to make broadband Pink and White noise more practical in setups that need additional test level. Before changing the limit, measure worst-case peak and RMS headroom across all generator modes and meaningful combinations, including two-tone summing, harmonics, Slicer/Guitar envelope, and Pick Attack.

Any increase must preserve deterministic stimulus behavior and must not rely on a hidden limiter. If positive master gain is added, clipping prevention or indication must be explicit and technically defined.

# 4. Spectral Bench

Spectral Bench is the suite's spectrum and measurement analyzer.


<!-- FIGURE PLACEHOLDER: Figure 4.1
Application: Spectral Bench
Subject: Main analyzer window
Show: Spectrum display, input selection, FFT/averaging controls, level controls and measurement readouts.
Suggested size: full text width
Caption: Spectral Bench configured for live spectrum inspection.
-->

**Figure 4.1.** Spectral Bench configured for live spectrum inspection.


## 4.1 Practical measurement guide

#### Purpose

This guide describes the current macOS 2.1.0 measurement workflow. Windows and Linux remain on the validated 1.1.0 baseline and are outside the current roadmap.

This is the practical operating guide for Spectral Bench 2.1.0 on macOS. It describes the main measurements, sensible starting settings, wiring, procedure, and interpretation. The more formal definitions are in `MEASUREMENTS.md`; architecture and qualification evidence are in `ARCHITECTURE.md` and `VALIDATION.md`.

The settings below are starting points, not mandatory constants. Change them when the DUT, sample rate, required resolution, noise floor, or measurement objective calls for it.

#### General setup

- Select the input channel that actually carries the signal being inspected.
- Start with **Input Gain = 0 dB**. Input Gain changes the samples sent to the analyzer and therefore changes measured dBFS values; it is not merely a display zoom.
- Keep enough headroom that neither the DUT nor the interface clips. For generated sweeps, **-12 dBFS** is a good general starting level.
- Use **20 Hz - 20 kHz** as the normal overview unless a narrower view makes the result easier to inspect.
- dB Top/Floor/Span and frequency view are display controls. Adjust them freely to inspect detail.
- **Hold** freezes the displayed graph. Peak Hold/Decay is a separate analyzer function.
- `Save Result...` writes PNG, CSV, and TXT companions. The PNG is the visual record; CSV/TXT are the authoritative numeric summaries.

#### 1. Live spectrum inspection

**Use for:** seeing spectral content in real time, checking tones, harmonics, interference, hum, bandwidth, and general signal behavior.

**Recommended start:** FFT **16384**, **Blackman-Harris**, **Avg Off** for immediate response or **Avg Medium** for a steadier trace, **Peak Off**, **Trace Raw**, Input Gain **0 dB**, 20 Hz - 20 kHz.

**Procedure:** feed the signal to the selected input, choose a frequency/dB view that exposes the area of interest, then enable averaging or peak behavior only when it helps answer the measurement question. Use the crosshair for a local frequency/level readout.

**Interpretation:** the spectrum is calibrated amplitude in dBFS. It is not a dBFS/Hz power-spectral-density display. FFT size changes frequency resolution and update cadence; it does not redefine the basic RMS or sample-peak readings.

#### 2. Noise and noise-floor inspection

**Use for:** broadband noise shape, hum/spurs above the noise floor, and comparative noise inspection.

**Recommended start:** FFT **32768** or **65536** when fine spectral resolution matters, **Blackman-Harris**, **Avg Slow**, **Peak Off**, **Trace Noise Smooth** for an easier broadband view, Input Gain **0 dB**. Use **Trace Raw** whenever individual-bin detail matters.

**Procedure:** remove or mute intentional program/test signals, allow averaging to settle, then adjust the dB viewport so the noise region is readable. Compare like with like: same sample rate, FFT/window, averaging, input gain, and physical gain structure.

**Interpretation/caveat:** Trace Noise Smooth is display-only. The normal spectrum is amplitude-calibrated dBFS, not dBFS/Hz. Do not interpret a single displayed FFT-bin level as a standardized noise-density measurement. The time-domain RMS readout is independent of FFT size/window.

#### 3. Single-tone level, harmonics, THD and THD+N

**Use for:** tone level, frequency, H2-H10, THD and THD+N.

**Recommended start:** choose **100 Hz**, **1 kHz**, or **10 kHz** when using one of the defined test tones; otherwise use **Manual Tone**. FFT **16384** is a good general start. **Blackman-Harris** is a robust general-purpose window; **Flat Top** is useful when amplitude accuracy for a non-bin-centred tone is the priority. Averaging can remain Off because the numeric measurement path has its own analysis/stabilization.

**Procedure:** apply a clean sine, select the matching defined mode when applicable, verify that the stimulus is accepted and the fundamental is sensible, then read H2-H10, THD and THD+N. For a more stable result, use **Measure 15 s** in the single-tone modes.

**Interpretation:** harmonic products are reported relative to the fundamental in dBc. THD uses the valid H2-H10 terms. THD+N follows the implemented measurement bandwidth and residual-power definition documented in `MEASUREMENTS.md`. The 15-second helper averages accepted frames in the linear power domain and reports its accepted/total frame count.

#### 4. Referenced frequency-response sweep, Transfer

**Use for:** the normal DUT frequency response, with common interface/path response cancelled by a simultaneous reference channel.

**Wiring:** Spectral Bench uses two channels. The selected **DUT ch** output goes through the DUT and returns to the same-numbered input. The other output/input channel is the direct reference loop. Both outputs receive the same sample-synchronous sweep.

**Recommended start:** **20 Hz to 20 kHz**, **5.0 s**, **-12 dBFS**, result **Transfer**.

**Procedure:** select DUT ch 1 or 2, verify the other channel is the direct reference, run the sweep, then select **Transfer**. No separate reference selector is required; the other channel is automatically the reference.

**Interpretation:** Transfer is DUT/Reference in dB. Around **0 dB** means equal DUT and reference magnitude. This is the preferred view for DUT frequency response because common physical path and sweep-boundary behavior largely cancel.

**Qualified range note:** physical validation showed excellent interior-band behavior. Treat the exact sweep endpoints, especially absolute behavior at 20 kHz, more cautiously than the interior band.

#### 5. Sweep Actual response

**Use for:** inspecting the locally captured DUT sinusoidal amplitude in dBFS rather than a normalized transfer ratio.

**Recommended start:** use the same sweep settings as Transfer, then switch the completed result to **Actual**. No rerun is required.

**Interpretation:** Actual includes the DUT path plus common physical interface/path response and sweep endpoint effects. It is therefore not a replacement for Transfer when the goal is normalized DUT frequency response. Use it when the absolute captured level itself is the quantity of interest.

#### 6. Phase, choosing the correct mode

After a completed sweep, select result **Phase**. `Phase mode` determines how constant delay is treated. Phase is wrapped to +/-180 degrees and low-confidence points may be omitted.

##### Raw

**Use for:** the complete referenced phase with nothing deliberately removed.

Raw preserves fixed DUT transport delay, so a device with latency normally produces a linear phase slope and repeated +/-180-degree wraps. This is the most literal phase view.

##### Auto

**Use for:** a quick, easier-to-read phase view when an automatic alignment estimate is acceptable.

Auto estimates and removes one constant delay. **Comp ms is an estimated phase compensation, not a DUT latency measurement.** DUT response can influence the estimate, so do not use this value as an authoritative latency result.

##### Manual

**Use for:** phase with a known constant transport delay removed.

Enter the known delay in **Comp ms**. If DUT latency is not already known, measure it independently with **60°N Latency Bench** and enter the measured milliseconds here. This is the preferred approach when you want the phase response with an independently measured transport latency removed.

Physical qualification example: the tested Quad Cortex path measured **1.857 ms** in Latency Bench while Spectral Bench Auto estimated about **1.42 ms** for that response. Manual compensation with the independently measured 1.857 ms produced the expected nearly delay-free LPF-off phase. This demonstrates why Auto compensation and measured DUT latency are different quantities.

##### Baseline A/B

**Use for:** measuring the phase change caused by a processing/state change, such as bypass versus filter enabled.

Click **Baseline A/B...**. Spectral Bench guides the two-stage procedure: set the DUT to state A and continue; the app captures/stores the baseline automatically; change the DUT to state B when prompted and continue; the app runs the second sweep and displays B relative to A. Intermediate graphs do not need to be handled manually.

Fixed path delay and unchanged phase response cancel. Physical qualification with LPF off -> 1 kHz LPF on showed the expected filter phase without transport-delay wraps; LPF off -> LPF off produced an essentially 0-degree null.

#### 7. SMPTE-style selective IM products

**Use for:** the implemented 60 Hz + 7 kHz selective intermodulation-product measurement.

**Stimulus:** 60 Hz and 7 kHz with a **4:1 linear amplitude ratio** (about 12.041 dB). Select **SMPTE-style products** and verify the stimulus-status indication before trusting the result.

Spectral Bench reports the defined second- and third-order sideband groups in dBc. It deliberately does **not** claim a normative aggregate SMPTE IMD percentage because that normalization remains outside the currently verified definition.

#### 8. CCIF / DFD-style selective IM products

**Use for:** the implemented 19 kHz + 20 kHz two-tone selective-product measurement.

**Stimulus:** equal-amplitude 19 kHz and 20 kHz tones. Select **CCIF / ITU-R IMD** and verify stimulus validity.

Spectral Bench reports the available 1 kHz, 18 kHz, and 21 kHz products in dBc. The 21 kHz product is available only when it is below Nyquist and within the usable analysis range. The app does not claim normative aggregate CCIF/ITU-R conformance or percentage normalization.

#### 9. Saving and documenting a result

Use **Save Result...** when the graph and measurement state represent what you want to preserve. The three files share a basename:

- PNG: graph as displayed, including applicable cursor/readout state.
- CSV: machine-readable numeric summary plus sweep/phase sections when a sweep exists.
- TXT: human-readable measurement report.

The export deliberately distinguishes **Analyzer mode** from **Sweep type**. For example, the live analyzer may currently be in `Manual Tone` while the same saved result also contains a completed `Referenced transfer` sweep. These describe different parts of the application state and are not contradictory.

For phase exports, the selected Raw/Auto/Baseline/Manual mode is recorded. Auto and Manual also record the applied compensation in milliseconds.

#### Quick defaults

For a general first attempt:

- Live spectrum: 16384, Blackman-Harris, Avg Off/Medium, Peak Off, Trace Raw.
- Noise inspection: 32768-65536, Blackman-Harris, Avg Slow, Trace Noise Smooth.
- Single tone: 16384, Blackman-Harris; use Flat Top when amplitude accuracy for a non-bin-centred tone is the priority; Measure 15 s for stable statistics.
- Referenced sweep: 20 Hz-20 kHz, 5 s, -12 dBFS, Transfer.
- Phase comparison after a DUT setting change: Baseline A/B.
- Phase with known DUT latency removed: Manual, using an independently measured latency (for example from 60°N Latency Bench).
- Phase quick-look: Auto, remembering that its Comp ms value is an alignment estimate, not a latency measurement.

## 4.2 Measurement definitions and semantics

#### Status

This document defines the implemented Spectral Bench measurement semantics and calibration rules. The 1.1.0 analyzer/distortion foundation remains applicable, with macOS 2.1.0 adding the released viewport, referenced sweep, Actual-response, and explicit phase-reference semantics documented below.

Where a definition is still deliberately open, it is marked explicitly. Implementation must not silently invent a meaning for an open item.

#### dBFS Conventions

Spectral Bench uses the digital sample full scale, `1.0`, as the amplitude reference.

##### Sample Peak

```text
Peak_dBFS = 20 * log10(max(abs(x[n])))
```

A sample whose absolute value reaches 1.0 is 0 dBFS sample peak.

##### RMS

```text
RMS = sqrt(mean(x[n]^2))
RMS_dBFS = 20 * log10(RMS)
```

Under this convention, a sine wave with peak amplitude 1.0 has:

```text
sample peak =  0.0000 dBFS
RMS         = -3.0103 dBFS
```

This relationship is intentional and must be documented in the UI/help material rather than hidden by a sine-specific RMS reference convention.

##### Spectral Tone Amplitude

A sinusoid's displayed spectral amplitude is its fitted/estimated peak amplitude relative to sample full scale.

Therefore a sine with peak amplitude 0.5 is:

```text
20 * log10(0.5) = -6.0206 dBFS
```

##### Harmonic / IMD Products

Individual distortion products are normally reported in dBc relative to the applicable fundamental/reference tone:

```text
Product_dBc = 20 * log10(Vproduct / Vreference)
```

#### Analysis Frame and Overlap

Supported FFT sizes:

- 4096
- 8192
- 16384
- 32768
- 65536

Default FFT size:

- 16384

The FFT analysis hop is fixed at one quarter of the FFT size:

```text
hop = N / 4
```

This gives 75% overlap.

Overlap is not a user control in Spectral Bench 1.1.0.

The analysis engine runs independently of UI repaint timing.

#### Windows

Spectral Bench 1.1.0 supports:

- Hann
- 4-term Blackman-Harris
- Flat Top

No other windows are included in 1.1.0 without a concrete measurement requirement.

Each window definition must expose at least:

- coefficients
- coherent gain
- sum of squared coefficients
- equivalent noise bandwidth (ENBW)

##### Coherent Gain

```text
CG = (1/N) * sum(w[n])
```

##### ENBW

In FFT bins:

```text
ENBW_bins = N * sum(w[n]^2) / (sum(w[n]))^2
```

#### Spectrum Calibration

The displayed one-sided amplitude spectrum must account for:

- FFT normalization
- one-sided positive-frequency scaling
- coherent gain
- special treatment of DC
- special treatment of Nyquist

The exact-bin reference requirement is:

A bin-centred sine with peak amplitude 0.5 shall read approximately -6.0206 dBFS for every supported FFT size and window, within the validation tolerance.

The spectrum display calibration and noise-power integration calibration are separate concepts.

Tone amplitude uses coherent-gain calibration.

Integrated broadband/noise power uses window-energy / Parseval-consistent normalization.

#### Spectrum Frequency Axis

Default visible range:

- 20 Hz to 20 kHz

Optional upper display range:

- toward Nyquist

The actual upper frequency cannot exceed Nyquist.

The x-axis is logarithmic.

#### 1.2.0 selectable spectrum views and trace presentation

Spectral Bench 1.2.0 provides user-selectable **20 Hz to 20 kHz** and **100 Hz to 10 kHz** spectrum views.

It also provides user-selectable **Raw** and **Noise Smooth** trace presentation. Noise Smooth is intended for broadband-noise inspection, particularly to reduce the visually thick and highly variable White-noise trace at higher frequencies.

These controls operate on presentation, not on the calibrated measurement semantics. They do not silently change numeric RMS/peak results, tone fitting, harmonic amplitudes, THD, THD+N, CCIF/SMPTE selective products, confidence decisions, cursor source data, or exported numeric measurements.

The 1.2.0 display layer was validated on macOS and is part of the later macOS 2.x line. Windows and Linux intentionally remain at the validated 1.1.0 baseline; no update cycle is currently scheduled.

#### Spectrum Magnitude Axis

The spectrum is displayed in dBFS.

The useful display floor is adjustable. The intended practical range includes approximately -120 dBFS and, where measurement conditions support it, approximately -140 dBFS.

Display floor does not change measurement bandwidth or measurement math.

#### Averaging

Spectrum averaging operates on linear power, never directly on dB values.

For each bin:

```text
Pavg_new = alpha * Pavg_old + (1 - alpha) * Pnew
```

with:

```text
alpha = exp(-hopSeconds / tau)
```

Spectral Bench 1.1.0 averaging modes are:

```text
Off       tau = 0
Fast      tau = 0.25 s
Medium    tau = 1.00 s
Slow      tau = 4.00 s
```

Off uses the current spectrum directly.

The time constants are independent of FFT size because `alpha` is derived from the actual hop duration.

#### Spectrum Peak Hold

Spectral Bench 1.1.0 modes:

- Off
- Hold
- Decay

##### Hold

Each displayed bin retains the maximum value seen since the last reset.

##### Decay

A held spectral peak falls at:

```text
20 dB/s
```

unless replaced by a newer higher value.

##### Reset

The UI provides an explicit reset action.

#### Basic Input RMS

Input RMS is calculated in the time domain and is independent of FFT size, window, overlap, and spectral averaging.

The displayed RMS uses exponential averaging of linear mean-square power with:

```text
tau = 400 ms
```

Conversion to dBFS occurs after averaging.

#### Basic Input Sample Peak

Input sample peak is calculated in the time domain and is independent of the FFT.

The displayed sample peak is the maximum absolute input sample observed during the most recent rolling 1.0 s interval.

This is sample peak, not true peak.

#### Fundamental Frequency Strategy

There are two measurement cases.

##### Defined-Tone Modes

For 100 Hz, 1 kHz, 10 kHz and defined IMD stimuli, the nominal frequency is known from the test definition.

The FFT spectrum is used to locate the local spectral peak around the expected tone.

The initial search region is:

```text
max(±1%, ±4 FFT bins)
```

around the expected frequency, clipped to the valid analysis range.

The detected peak is then refined by a sinusoidal least-squares fit as described below.

##### Manual Single-Tone Mode

Manual Single Tone assumes that the input is intended to contain one dominant test tone.

The initial fundamental candidate is the strongest valid local spectral peak from:

```text
20 Hz to min(20 kHz, Nyquist)
```

DC is excluded.

The candidate is refined using the same sinusoidal fit as defined-tone mode.

Spectral Bench 1.1.0 does not attempt general-purpose musical pitch tracking or missing-fundamental inference.

##### Tone confidence

A candidate stimulus tone is not considered valid merely because a spectral bin is above a very low numerical floor. The candidate must also be resolved above its nearby spectrum.

For the current 1.0 validation rule, the candidate peak must be at least:

```text
12 dB
```

above the median local spectral floor measured in a surrounding window. The peak main lobe is excluded from that local-floor estimate. A very low absolute floor remains as a numerical sanity backstop, but does not by itself establish a valid stimulus.

This confidence rule applies to single-tone fundamentals and to both required carriers of the defined IMD stimuli. It is a stimulus-validity test only; low-level distortion products are still measured with targeted searches and are not required to satisfy the carrier prominence threshold.

#### Sinusoidal Fit

Precision tone measurements must not depend solely on the height of a single FFT bin.

The FFT provides the initial frequency estimate.

The measurement engine then performs a least-squares sinusoidal fit on the unwindowed analysis samples near that frequency.

For a trial angular frequency `omega`, fit:

```text
x[n] ~= a*cos(omega*n) + b*sin(omega*n) + c
```

where the DC term `c` prevents DC offset from biasing the tone fit.

The fitted peak amplitude is:

```text
Apeak = sqrt(a^2 + b^2)
```

The frequency is refined locally to minimize residual squared error.

The exact numerical optimizer is an implementation detail, but it must:

- start from the spectral estimate
- remain inside the defined local search region
- be deterministic
- avoid heap allocation in real-time code
- meet the validation tolerances

This fit is used for:

- measured fundamental frequency
- fundamental amplitude
- harmonic amplitude extraction
- subtraction of the fundamental for THD+N

#### Harmonic Analysis

For a measured fundamental frequency `f0`, candidate harmonic frequencies are:

```text
fn = n * f0
```

for:

```text
n = 2 ... 10
```

Only harmonics below Nyquist and inside the active measurement bandwidth are valid.

Each harmonic amplitude is measured using a sinusoidal least-squares projection/fitting operation at the expected harmonic frequency rather than by reading one FFT bin.

The default displayed product is:

```text
Hn_dBc = 20 * log10(Vn / V1)
```

where `V1` and `Vn` are fitted peak amplitudes.

This measurement path avoids window-main-lobe width becoming part of the definition of harmonic amplitude.

#### THD

Spectral Bench 1.1.0 THD uses H2 through H10 where valid.

```text
THD = sqrt(V2^2 + V3^2 + ... + V10^2) / V1
THD_percent = 100 * THD
```

Terms above Nyquist or outside the valid measurement range are omitted.

The UI should make invalid/unavailable harmonics visibly unavailable rather than treating them as zero.

#### THD+N

THD+N uses an explicit measurement bandwidth.

Initial user-selectable bandwidths:

- 20 Hz to 20 kHz
- 20 Hz to Nyquist

Default:

- 20 Hz to 20 kHz when Nyquist permits it

If the requested upper limit exceeds Nyquist, the actual upper limit is clamped below Nyquist and the UI must display the actual bandwidth used.

##### Fundamental Removal

THD+N is not calculated by simply deleting one FFT bin.

The fitted fundamental sinusoid is reconstructed and subtracted from the unwindowed time-domain analysis frame:

```text
residual[n] = input[n] - fittedFundamental[n]
```

The residual therefore intentionally retains:

- harmonics
- intermodulation products
- broadband noise
- hum
- spurious components

The residual is windowed and transformed for band-power integration.

##### Residual Power

In-band residual power is integrated with window-energy / Parseval-consistent normalization.

DC and frequencies below the selected lower bandwidth limit are excluded.

The denominator is the RMS power of the fitted fundamental.

Conceptually:

```text
THD+N = sqrt(P_residual_in_band / P_fundamental)
THD+N_percent = 100 * THD+N
```

The displayed result always includes the actual measurement bandwidth.

##### Weighting

No A-weighting, CCIR/ITU weighting, AES weighting, or other weighting filter is part of Spectral Bench 1.1.0.

#### Defined Single-Tone Tests

Spectral Bench 1.1.0 includes four distinct single-tone measurement modes:

- 100 Hz
- 1 kHz
- 10 kHz
- Manual Single Tone

The three defined-frequency modes use the local search region specified under
Defined-Tone Modes. Manual Single Tone retains dominant-tone detection across
the normal audio analysis range.

For each applicable test, the measurement panel can show:

- input RMS, dBFS
- input sample peak, dBFS
- nominal tone frequency where defined
- measured fundamental frequency, Hz
- fitted fundamental amplitude, dBFS
- H2 through H10, dBc
- THD, %
- THD+N, %
- actual THD+N bandwidth

#### CCIF / DFD-Style 19 + 20 kHz Test

Stimulus:

```text
f1 = 19 kHz
f2 = 20 kHz
equal amplitudes
```

Mean frequency:

```text
19.5 kHz
```

Difference frequency:

```text
1 kHz
```

Products explicitly inspected in 1.1.0:

```text
f2 - f1        = 1 kHz
2*f1 - f2      = 18 kHz
2*f2 - f1      = 21 kHz
```

The 21 kHz product is only valid when it is below Nyquist and inside the usable analyzer range.
The numerical analyzer is allowed to report that product even though the live spectrum display is intentionally capped at 20 kHz; the display limit is not an analysis-bandwidth limit.

Each available product is shown numerically in dBc.

##### Important Naming Rule

Spectral Bench may describe this as `CCIF / DFD-style 19 + 20 kHz`.

It must not claim normative CCIF/ITU-R conformance until the exact normative result normalization used by the intended standard has been verified from the standard itself.

A single aggregate CCIF/DFD percentage result remains deliberately OPEN for that reason.

The individual product measurements are fully defined and can be implemented independently of that open normalization question.

#### SMPTE-Style 60 Hz + 7 kHz Test

Stimulus:

```text
fL = 60 Hz
fH = 7 kHz
low/high amplitude ratio = 4:1
```

The ratio is a linear amplitude ratio, approximately 12.041 dB.

Products explicitly inspected:

Second-order sideband pair:

```text
fH - fL = 6940 Hz
fH + fL = 7060 Hz
```

Third-order sideband pair:

```text
fH - 2*fL = 6880 Hz
fH + 2*fL = 7120 Hz
```

Each product is shown numerically and marked on the spectrum.

##### Important Naming Rule

Spectral Bench may describe this as `SMPTE-style 60 Hz + 7 kHz`.

It must not claim normative SMPTE conformance until the exact normative aggregate percentage normalization has been verified from the relevant standard.

A single aggregate SMPTE IMD percentage result therefore remains deliberately OPEN.

The current implementation reports the selective second-order and third-order sideband-pair levels in dBc. These are useful product measurements, but they are not presented as a normative aggregate SMPTE IMD result.

#### Shared Test Definition Requirement

Stimulus frequencies and expected product frequencies must not be duplicated independently between Signal Bench and Spectral Bench once shared test definitions are introduced.

Expected IMD products should be representable by integer relationships such as:

```text
m*f1 + n*f2
```

rather than unrelated absolute-frequency constants where practical.

#### Deliberately Open Measurement Decisions

The following remain intentionally open after the macOS 2.1.0 release:

1. exact normative aggregate CCIF/DFD percentage normalization
2. exact normative aggregate SMPTE percentage normalization
3. final numerical tolerances for validation
4. empirical review of the frozen 12 dB local-prominence threshold across supported interfaces and FFT/window settings

These items require either normative-source verification or broader empirical validation before implementation is considered complete.

#### Implemented Spectrum Control Semantics

The following previously specified spectrum behaviors are now implemented in the current development build.

##### Averaging

Averaging is exponential averaging in linear power:

```text
Pavg_new = alpha * Pavg_old + (1 - alpha) * Pnew
```

with:

```text
alpha = exp(-hopSeconds / tau)
```

Modes:

```text
Off       direct spectrum
Fast      tau = 0.25 s
Medium    tau = 1.00 s
Slow      tau = 4.00 s
```

##### Peak Hold / Decay

Modes:

- Off
- Hold
- Decay

Decay rate:

```text
20 dB/s
```

An explicit reset clears stored peak state.

##### Display Grid

The display grid is visual only and does not affect measurement math.

Magnitude hierarchy:

- strongest: 10 dB increments
- medium: 5 dB increments
- faint: 1 dB increments

Frequency hierarchy on the logarithmic axis:

- strongest: labelled/decade reference lines
- medium: selected 2x and 5x subdivisions
- faint: remaining integer subdivisions within each decade

##### Display Range

The selected display floor affects rendering only.

Current choices:

- -80 dBFS
- -100 dBFS
- -120 dBFS
- -140 dBFS

Changing the display floor does not alter FFT calibration, averaging, bandwidth, or any measurement result.

#### 15-second single-tone statistics

For the Manual Tone, 100 Hz, 1 kHz, and 10 kHz modes, Spectral Bench can
accumulate a 15-second measurement window. SMPTE-style and CCIF modes keep
this helper disabled because they currently report selective products rather
than a normative aggregate measurement.

The capture uses only new analysis frames. A frame is accepted only when the
selected single-tone stimulus passes the same fundamental/confidence validation
used by the live measurement. Rejected stimulus frames are counted but are not
included in the averages.

A completed 15-second result is considered valid only when at least 8 accepted
frames were captured and at least 80 percent of all observed analysis frames
were accepted. The result reports the accepted/total frame count explicitly.

Accepted levels and distortion ratios are averaged in the linear power domain.
For a level `L` in dBFS or dB:

```text
P = 10^(L / 10)
```

The mean power is accumulated over the capture interval and converted back:

```text
Lmean = 10 log10(Pmean)
```

The timed result reports:

- broadband RMS level
- fitted fundamental/tone level
- THD when valid product-qualified THD frames are available
- THD+N when valid THD+N frames are available
- accepted/total stimulus-frame count

THD and THD+N use their own valid-frame counts; an unavailable distortion
result is not substituted with a noise-floor estimate. The statistics function
does not alter FFT calibration, spectrum averaging, display View offset, or the
underlying analyzer data.

#### Current single-tone measurement foundation

The current development build provides:

- refined fundamental-frequency estimate
- fundamental level in dBFS
- H2 through H10 where valid below the analyzer/Nyquist limit
- harmonic levels in dBc relative to the fundamental
- THD from the valid H2 through H10 terms
- THD+N over the implemented measurement bandwidth


##### Live numeric display stabilization

The live numeric distortion readouts are intentionally stabilized independently of FFT spectrum averaging. Valid readings use light exponential smoothing, and an invalid analysis run is held for up to 1.2 s before the UI changes the value to `--`. The hold is applied only while the analysis result is invalid; continuously valid readings continue to update on every UI timer tick and therefore settle to the actual stable measured value. This is display-only behavior: the spectrum trace, analyzer confidence decisions, and 15-second timed-measurement validity continue to use their existing analysis paths.

#### Measurement result CSV export

The **Save Result...** action writes three companion files with the same basename: a single-row CSV record, a mode-aware plain-text report, and a PNG snapshot of the actual spectrum graph.

Unavailable or invalid quantities are represented by empty CSV fields. The literal UI placeholder `--` is never exported as a measurement value.

The record includes provenance (`Spectral Bench`, version, `60°N Signal Works`, timestamp), analyzer configuration, time-domain levels, applicable single-tone/harmonic/THD results, and applicable CCIF/SMPTE-style selective products. The export is intentionally a measurement summary, not a spectrum-bin dump.

Export terminology deliberately separates the live analyzer selection from an available sweep result. The common CSV field is `analyzer_mode` (for example `Manual Tone`), while the appended sweep section uses `sweep_type` (currently `referenced_transfer`). The text report likewise uses `Analyzer mode:` in its common header and `Sweep type:` inside the separate `Sweep measurement` section. A saved sweep can therefore coexist with any current analyzer mode without implying that the analyzer mode describes the sweep.

##### Human-readable text report

The `.txt` companion report contains common provenance, analyzer settings, and level information, followed by only the measurement section relevant to the current mode:

- single-tone modes: fundamental, H2-H10 table, THD, THD+N
- CCIF mode: detected stimulus tones and 1 kHz / 18 kHz / 21 kHz selective products
- SMPTE-style mode: detected LF/HF stimulus tones and IM2 / IM3 selective-product groups

Invalid values are displayed as `--` in the human-readable report. The CSV continues to use empty fields for invalid/not-applicable numeric data.

##### Spectrum graph PNG

The `.png` companion is rendered directly from the Spectrum component at save time rather than reconstructed from exported numbers. It therefore preserves the current frequency/dB graph, view offset, spectrum trace, and enabled peak trace. Introduced on macOS 2.0.1 and retained in 2.1.0, Save Result freezes the last valid in-graph cursor measurement and renders the crosshair plus the fixed Trace/Cursor readouts into the PNG. The CSV and TXT report include cursor frequency, cursor dBFS, trace dBFS at the same frequency, and signed cursor-to-trace dB difference when valid.

The PNG is a visual record; the CSV and text report remain the authoritative numeric exports.


#### 2.0.1 macOS spectrum viewport and input gain

macOS 2.0.1 preserves the logarithmic frequency axis for every preset and Custom view. Custom limits do not linearize, stretch, or otherwise alter the log-frequency mapping. Adaptive frequency labels use engineering 1-2-5 values rather than arbitrary evenly spaced Hz values.

The Y-axis can be zoomed to spans from 120 dB through 10 dB and vertically positioned within the practical -120 to 0 dBFS inspection region. The grid adapts to the selected span. Y zoom and position affect display only.

Input Gain is independent and ranges from -20 to +40 dB. It is applied to the selected analysis input before FFT/measurement processing and therefore intentionally changes measured dBFS values. It does not change the audio passed through the plugin.

The dB viewport controls are coupled. `dB Span = dB Top - dB Floor` at all times. Changing dB Top anchors the top boundary; changing dB Floor anchors the floor boundary; changing dB Span then preserves the most recently selected boundary and moves the opposite boundary. The graph and exported `db_span`, `db_top_dbfs`, and `db_floor_dbfs` values use this same resolved viewport state.

The macOS 2.0.1 graph also provides a free crosshair measurement cursor. Fixed top-right Trace and Cursor readouts avoid distracting label movement. The Cursor readout reports mouse frequency and dBFS plus the signed dB difference to the spectrum trace at the same frequency; the Trace readout reports the corresponding trace point. Command-S opens Save Result without requiring the mouse to leave the measurement point.

Windows and Linux remain at the validated 1.1.0 feature set and are outside the current development roadmap.

#### macOS 2.1.0 Referenced Sweep Measurement

For user-facing procedures and recommended starting settings, see [MEASUREMENT_GUIDE.md](MEASUREMENT_GUIDE.md).

The production sweep is always referenced and measures one DUT channel at a time. The selected DUT channel is paired with the same-numbered input; the other channel is the reference output/input. Both outputs receive identical sample-synchronous deterministic exponential sine-sweep samples. The reference path is intended to be looped directly back while the DUT path passes through the device under test.

Transfer magnitude is `DUT / Reference` and is reported in dB. The Actual view reports the locally captured DUT sinusoidal amplitude in dBFS. Actual is intentionally not normalized to the reference, so common physical-path response and sweep endpoint/boundary effects remain visible there while cancelling from Transfer.

##### Phase semantics

Phase is wrapped to +/-180 degrees and low-confidence points may be omitted rather than displaying phase dominated by noise.

- **Raw** preserves the complete referenced phase, including constant transport delay.
- **Auto** removes a constant delay estimated from the sweep alignment. The estimate is phase compensation only; it is not an authoritative latency measurement and can be influenced by DUT response.
- **Baseline** divides the current referenced complex transfer by a stored baseline referenced complex transfer. The guided Baseline A/B workflow captures A, prompts for the DUT-state change, captures B, and displays B relative to A. Routing must remain unchanged between the two captures.
- **Manual** removes exactly the user-entered constant delay. When actual DUT transport latency is required, measure it independently, for example with 60°N Latency Bench, and enter that result in milliseconds.

There is no universal phase-only method for deciding whether a linear phase term is transport delay or genuine linear-phase DUT response. For that reason Spectral Bench exposes the compensation choice rather than silently flattening phase.

## 4.3 Application and feature reference

**Spectral Bench** is a cross-platform real-time audio spectrum analyzer and focused audio measurement tool by **60°N Signal Works**.

It is intended as a companion to Signal Bench:

- **Signal Bench** generates known test signals.
- **Spectral Bench** analyzes what happened to them.

Spectral Bench is deliberately not intended to become a kitchen-sink analyzer. The design goal is a technically correct, exceptionally clear and readable spectrum analyzer with a limited set of useful distortion measurements.

For practical setup and step-by-step use, see **[Measurement Guide](docs/MEASUREMENT_GUIDE.md)**. It covers recommended starting settings for live spectrum work, noise inspection, single-tone/distortion measurements, referenced sweeps, Actual response, phase, Baseline A/B, and IMD measurements.

#### Status

Spectral Bench has a validated cross-platform 1.1.0 baseline. Windows x64 and Linux x86_64 intentionally remain on that release for now.

macOS **2.1.0 is released and validated**. The release passes the full 20-test automated suite. Its Standalone viewport, crosshair/readout, Input Gain, referenced sweep, Actual response, Raw/Auto/Manual/Baseline phase modes, guided Baseline A/B workflow, Help, Save Result/Command-S, and export behavior passed manual/physical qualification. The final package was clean-installed with Standalone, AU, and VST3 at their intended system locations; the AU passed full `auval` validation, VST3 metadata was verified, and the installed Standalone passed functional sweep/Transfer/Actual/Phase smoke tests.

The spectrum analyzer, level measurements, defined single-tone modes, H2-H10, THD, THD+N, SMPTE-style selective IM products, CCIF/DFD-style individual-product analysis, stimulus/result confidence checks, 15-second single-tone measurement helper, and measurement-result export remain implemented across the applicable platform versions.

#### Platforms and Formats

##### macOS
- Standalone
- Audio Unit (AU)
- VST3

##### Windows x64
- Standalone
- VST3

##### Linux x86_64
- Standalone
- VST3

The implementation uses JUCE and C++.

#### Design Principles

- Architecture first, implementation second.
- Correctness before features.
- The spectrum analyzer is the primary feature and should dominate the UI.
- Measurements must have explicit, documented definitions.
- No context-free “magic numbers”.
- DSP and measurement code must remain independent of the UI, plugin wrapper, standalone wrapper, and platform packaging.
- Platform-specific DSP should be avoided.
- Warnings are treated seriously.
- Validation is required; “it seems to work” is not sufficient.
- Avoid featuritis.

#### Version Status

##### 2.1.0 (macOS)

Spectral Bench 2.1.0 is the current macOS release. Windows x64 and Linux x86_64 intentionally remain on the validated 1.1.0 baseline and are not part of the current development roadmap.

macOS 2.1.0 includes the instrument-style spectrum viewport controls introduced during the macOS 2.x development cycle without changing the logarithmic nature of the frequency axis or the calibrated measurement math:

- additional logarithmic frequency-view presets: 10 Hz-1 kHz, 20 Hz-2 kHz, 100 Hz-5 kHz, 1 kHz-20 kHz, and 5 kHz-20 kHz
- Custom frequency view with explicit minimum/maximum frequency and adaptive 1-2-5 engineering grid generation
- coupled dB Top, dB Floor, and dB Span controls from a 120 dB overview down to a 10 dB zoomed view
- changing dB Top or dB Floor selects that boundary as the zoom anchor; subsequent dB Span changes preserve the selected boundary while the opposite boundary follows
- independent analysis Input Gain from -20 to +40 dB
- adaptive dB grid density for narrow amplitude views
- fixed top-right Trace/Cursor measurement readouts with a free crosshair cursor
- cursor readout includes mouse frequency/dBFS, trace level at the same frequency, and signed dB difference
- `Save Result… ⌘S` captures the active cursor/trace measurement in the PNG, CSV, and TXT report

Input Gain is the only new viewport-area control that changes the samples presented to the analyzer. Frequency range, dB span, and dB position are display controls. The analyzed audio pass-through is not gain-modified.

The released 2.1.0 macOS implementation passes the 20-test automated suite. Referenced magnitude, Actual response, phase modes, guided Baseline A/B, multiple levels/sample rates/buffer sizes, and physical DUT filter behavior are qualified. Documentation/export wording, package installation, AU validation, VST3 metadata, and installed Standalone smoke checks are complete.


##### 1.1.0

Spectral Bench 1.1.0 remains the current fully cross-platform validated release baseline. It has been built and tested on:

- macOS
- Windows x64
- Linux x86_64

The 1.1.0 release remains the validated Windows/Linux baseline; the later macOS-only 1.2.0 work is retained below as release history.

##### 1.2.0

Spectral Bench 1.2.0 adds two spectrum-display features:

- selectable **20 Hz to 20 kHz** and **100 Hz to 10 kHz** analyzer views
- user-selectable **Raw** and **Noise Smooth** trace presentation

**Noise Smooth** is intended especially for broadband-noise work. It reduces the visually thick/highly variable trace produced by Pink and White noise, particularly at higher frequencies, while Raw retains the original detailed spectrum presentation.

The smoothing is a **display-only operation**. It does not change the calibrated measurement snapshot used for numerical measurements, cursor source data, harmonic analysis, THD, THD+N, intermodulation measurements, analyzer confidence, or authoritative numeric exports.

Spectral Bench 1.2.0 has currently been **built, installed, and tested on macOS only**.

macOS 1.2.0 validation completed so far includes:

- clean Release build
- all automated tests passed
- Standalone functional test
- 20 Hz to 20 kHz / 100 Hz to 10 kHz range switching
- Raw / Noise Smooth switching
- macOS installer package build and installation
- installed Standalone launch
- installed Audio Unit version verified as 1.2.0
- full `auval` validation passed
- Logic Pro AU load and functional smoke test
- both new 1.2.0 controls tested successfully in Logic Pro

**Windows x64 and Linux x86_64 remain on the validated 1.1.0 release. No Windows/Linux update is currently scheduled; those platforms are outside the active roadmap.**


#### Core analyzer and measurement scope

##### Spectrum Analyzer

The central display is a real-time audio spectrum analyzer with:

- logarithmic frequency axis
- magnitude shown in dB
- normal audio-frequency view of approximately 20 Hz to 20 kHz
- optional display toward Nyquist where useful
- adjustable useful display dynamic range
- properly calibrated FFT amplitudes
- selectable FFT size
- a deliberately small set of useful window functions
- averaging
- peak hold
- readable grid and labels
- frequency/amplitude cursor or readout

The spectrum itself will normally remain calibrated in dBFS.

##### Basic Level Measurements

The UI also shows:

- input RMS level in dBFS
- input sample-peak level in dBFS
- measured fundamental frequency in Hz when applicable

RMS and sample peak are intended to be calculated in the time domain so that they do not depend on FFT size, window, averaging, or overlap.

True-peak metering is outside the 1.0.0 scope.

##### Single-Tone Analysis

For defined or detected single-tone measurements, Spectral Bench shows:

- fundamental frequency
- fundamental amplitude in dBFS
- H2 through H10 where valid below Nyquist
- individual harmonic levels in dBc relative to the fundamental
- THD
- THD+N
- explicit THD+N measurement bandwidth

Initial defined single-tone tests:

- 100 Hz
- 1 kHz
- 10 kHz
- manual/detected single tone

##### THD

THD is conceptually:

```text
THD = sqrt(V2^2 + V3^2 + ... + Vn^2) / V1
```

For 1.0.0, harmonic analysis is intended to include H2 through H10 where those harmonics are valid below Nyquist.

The implemented harmonic analyzer reports fitted H2 through H10 values where valid below Nyquist and computes THD from the qualified harmonic amplitudes.

##### THD+N

THD+N must always have an explicit measurement bandwidth.

Initial intended bandwidth choices:

- 20 Hz to 20 kHz
- 20 Hz to Nyquist

The default is intended to be 20 Hz to 20 kHz where the sample rate permits it.

The implemented THD+N path subtracts the fitted fundamental and integrates residual power over the explicit measurement bandwidth; implementation details are documented in `docs/MEASUREMENTS.md`.

##### Two-Tone / IMD Analysis

Two-tone stimuli are treated as IMD measurements, not THD tests.

Implemented test families:

- CCIF / ITU-R-style 19 kHz + 20 kHz, equal amplitudes
- SMPTE-style 60 Hz + 7 kHz, 4:1 amplitude ratio

The implemented CCIF/DFD-style and SMPTE-style modes report selective products with documented stimulus requirements. Spectral Bench does not claim normative aggregate-percentage compliance for those standards.

##### FFT Choices

Supported FFT sizes:

- 4096
- 8192
- 16384
- 32768
- 65536

Default: **16384**.

Supported windows:

- Hann
- 4-term Blackman-Harris
- Flat Top

Window coherent gain and equivalent noise bandwidth (ENBW) are explicit properties of each supported window.

##### Averaging

Supported averaging choices:

- Off
- Fast
- Medium
- Slow

Averaging operates on linear power, with conversion to dB performed afterward.

##### Peak Hold

Supported peak behavior:

- Off
- Hold
- Decay

An explicit reset action is provided.

#### UI Direction

The spectrum display should consume most of the available area.

A compact measurement area should present RMS, sample peak, measured fundamental frequency, fundamental amplitude, harmonics, THD, THD+N, and bandwidth as applicable.

Initial conceptual analysis modes:

- Spectrum
- 100 Hz
- 1 kHz
- 10 kHz
- Manual Tone
- CCIF 19 + 20 kHz
- SMPTE 60 Hz + 7 kHz

The measurement panel should sit naturally on top of the spectrum-analysis architecture rather than behave like an unrelated meter panel.

#### Architecture Direction

Conceptually:

```text
Audio input
    |
    v
Analysis FIFO / history
    |
    +--> time-domain statistics
    |      RMS
    |      sample peak
    |
    v
Windowing
    |
    v
Real FFT
    |
    v
Calibrated complex spectrum
    |
    +--> display processing
    |      averaging
    |      peak hold
    |
    +--> measurement engine
           fundamental estimation
           harmonic analysis
           THD
           THD+N
           predefined IMD measurements
```

The audio callback must remain lightweight. FFT analysis and measurement work should not be performed in the real-time audio callback.

The UI must not calculate measurements.

See `docs/ARCHITECTURE.md` and `docs/MEASUREMENTS.md`.

#### Shared Signal Bench / Spectral Bench Test Definitions

Signal Bench and Spectral Bench should eventually share test definitions so that the generator and analyzer do not independently hard-code incompatible test concepts.

There is no requirement for runtime communication between the applications in the current release.

A future shared definition should be able to describe:

- test identity and name
- one or more stimulus tones
- nominal frequencies
- relative amplitudes
- measurement type
- expected distortion/intermodulation products
- product frequencies derived from the stimulus where possible

For two-tone products, definitions should prefer relationships such as:

```text
f2 - f1
2*f1 - f2
2*f2 - f1
```

instead of separately hard-coded absolute product frequencies.

See `docs/ARCHITECTURE.md`.

#### Validation

Spectral Bench uses automated and manual validation of the measurement engine.

Automated and reference validation cover:

- FFT amplitude calibration
- frequency accuracy
- supported FFT sizes
- supported windows
- coherent-gain correction
- ENBW handling
- RMS
- sample peak
- harmonic amplitude accuracy
- THD
- THD+N
- measurement bandwidth
- IMD calculations
- supported sample rates
- behavior near Nyquist

The permanent independent reference-validation gate verifies, among other cases, that a bin-centred digital sine with peak amplitude 0.5 reads approximately **-6.0206 dBFS** independent of supported FFT size and selected window, within the frozen numerical tolerance.

See `docs/VALIDATION.md`.

#### Saving measurement results

Spectral Bench can save the current measurement result using **Save Result...**. On macOS 2.1.0 the button is shown as **Save Result… ⌘S**, and Command-S invokes the same save dialog without moving the measurement cursor. Each save creates three files with the same basename:

- `.csv` — structured, spreadsheet/script-friendly data
- `.txt` — compact, mode-aware human-readable measurement report
- `.png` — snapshot of the actual spectrum graph as displayed at save time

The export is a single-row measurement record rather than a raw FFT-bin dump. It includes:

- ISO-8601 timestamp
- product, version, and vendor
- selected measurement mode
- sample rate and input channel
- FFT size, window, averaging, and peak mode
- RMS and sample peak
- fitted fundamental and H2-H10 values where valid
- THD and THD+N where valid
- CCIF selective products where valid
- SMPTE-style IM2/IM3 groups where valid
- on macOS 2.1.0, cursor frequency/dBFS, trace dBFS at the same frequency, and signed cursor-to-trace dB difference when a valid graph cursor measurement exists

Fields that are not applicable or not currently valid are left empty rather than being exported as `--` or as fabricated numeric values. Stimulus-valid flags are included for the CCIF and SMPTE-style modes.

The CSV remains the structured interchange format for spreadsheets and scripts. The accompanying text report is intended for direct reading, lab notes, email, and issue reports, and omits sections that are irrelevant to the selected measurement mode. The PNG uses the actual spectrum-component rendering, including the current graph range, view offset, spectrum trace, and enabled peak trace. On macOS 2.1.0, Save Result freezes the last valid in-graph crosshair measurement and includes the crosshair plus fixed Trace/Cursor readouts in the saved PNG. The CSV and text report carry product/version/vendor metadata so saved numeric results remain attributable later.

#### macOS installer

The reproducible macOS packaging script builds:

```text
dist/Spectral-Bench-2.1.0-macOS.pkg
```

The package installs:

```text
/Applications/60°N Signal Works Audio Bench Suite/Spectral Bench.app
/Library/Audio/Plug-Ins/Components/Spectral Bench.component
/Library/Audio/Plug-Ins/VST3/Spectral Bench.vst3
```

The macOS 2.1.0 package is unsigned. `packaging/macos/build-pkg.sh` builds it from the current Release Standalone, AU, and VST3 artifacts and verifies the packaged artifact set and VST3 vendor metadata.

#### Windows x64 build and installer

Prerequisites:

- Git
- CMake 3.22 or newer
- Visual Studio 2022 Build Tools with the C++ workload
- Inno Setup 6 for the installer

From PowerShell:

```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
ctest --test-dir build -C Release --output-on-failure
powershell -ExecutionPolicy Bypass -File .\packaging\windows\build-installer.ps1
```

The installer output is:

```text
dist\Spectral-Bench-1.1.0-Windows-x64.exe
```

It installs the Standalone application under `C:\Program Files\Spectral Bench\` and the VST3 under `C:\Program Files\Common Files\VST3\Spectral Bench.vst3`.

The Windows installer is unsigned unless a separate signing workflow is used. The Spectral Bench 1.1.0 Windows x64 Release build, automated tests, installer, installed Standalone, VST3 installation, and CSV/TXT/PNG result export have been validated on Windows.

#### Linux x86_64 build and package

Prerequisites include Git, CMake 3.22 or newer, Ninja or another supported CMake generator, a C++17 compiler, and the JUCE development dependencies required by the target distribution.

On Ubuntu/Linux with Ninja:

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build -j "$(nproc)"
ctest --test-dir build --output-on-failure
./packaging/linux/build-package.sh
```

The package output is:

```text
dist/Spectral-Bench-1.1.0-Linux-x86_64.tar.gz
```

After extracting the archive, run `./install.sh`.

Per-user installation paths are:

```text
~/.local/bin/spectral-bench
~/.vst3/Spectral Bench.vst3
~/.local/share/applications/spectral-bench.desktop
~/.local/share/icons/hicolor/256x256/apps/spectral-bench.png
```

Run `./uninstall.sh` from the extracted archive to remove the per-user installation.

The portable archive depends on compatible runtime libraries and is not claimed to run on every Linux distribution. The Spectral Bench 1.1.0 Linux x86_64 Release build, automated tests, package, installed Standalone, VST3 installation, desktop integration, and CSV/TXT/PNG result export have been validated on Linux.

#### Deferred / Future Development

Deferred and post-1.1 development ideas are documented in `docs/FUTURE.md`.

The list is retained intentionally so that future additions are explicit design decisions rather than accidental feature growth.

Spectral Bench 1.2.0 implements the previously planned user-selectable **100 Hz to 10 kHz** zoomed view in addition to the normal **20 Hz to 20 kHz** view, together with explicit user-selectable Raw / Noise Smooth trace presentation for broadband-noise work.

##### Selectable analyzer view and trace presentation

The 1.2.0 implementation keeps measurement math separate from trace presentation. Noise Smooth uses display-side processing to show Pink and especially White noise as a cleaner, thinner representative trace. Raw remains available for detailed spectrum inspection. The selected presentation is explicit in the UI and does not alter numeric measurements, peak detection, harmonic analysis, THD/THD+N, IM-product calculations, or authoritative numeric exports.

#### Repository

Spectral Bench is a standalone project and does not inherit Signal Bench or the earlier Pink Noise Generator Git history.

Spectral Bench 1.1.0 is the intended repository baseline. The repository history will be initialized from this validated feature state.

The `v1.1.0` Git tag is reserved for the finalized release after macOS, Windows x64, and Linux x86_64 validation of the same source state.

#### Author / Brand

**60°N Signal Works**

#### Measurement Specification Status

The core Spectral Bench measurement model is specified in `docs/MEASUREMENTS.md`.

Key frozen decisions include:

- FFT sizes: 4096 through 65536
- default FFT size: 16384
- fixed 75% overlap
- Hann, 4-term Blackman-Harris, and Flat Top windows
- coherent-gain calibrated tone spectrum
- window-energy calibrated integrated noise power
- power-domain spectrum averaging
- averaging time constants of 0.25 s, 1 s, and 4 s
- spectral peak hold with optional 20 dB/s decay
- 400 ms time-domain RMS averaging
- rolling 1 s sample peak
- FFT-assisted, least-squares-refined tone measurement
- fitted H2 through H10
- THD from fitted harmonic amplitudes
- THD+N by fitted-fundamental subtraction plus explicit-bandwidth residual power integration

The 19+20 kHz and 60 Hz+7 kHz IMD stimuli and individual products are defined, but Spectral Bench does not claim normative CCIF/ITU-R or SMPTE aggregate-percentage compliance until the exact normative result normalization has been verified from the relevant standard.

#### Current Spectrum Analyzer Features

Spectral Bench 1.1.0 includes the real-time spectrum analyzer core and measurement UI.

Spectrum display:

- logarithmic frequency axis
- default display range: 20 Hz to 20 kHz
- calibrated dBFS magnitude display
- selectable display floor: -80, -100, -120, or -140 dBFS
- live oscilloscope-style green spectrum trace
- separate amber peak trace
- frequency/amplitude cursor readout
- hierarchical logarithmic frequency grid
- hierarchical 1 dB / 5 dB / 10 dB magnitude grid

FFT sizes:

- 4096
- 8192
- 16384
- 32768
- 65536

Window functions:

- Hann
- 4-term Blackman-Harris
- Flat Top

Spectrum averaging:

- Off
- Fast: 0.25 s
- Medium: 1.0 s
- Slow: 4.0 s

Averaging is performed in the linear power domain rather than directly in dB.

Peak display:

- Off
- Hold
- Decay
- explicit peak reset

Peak decay is 20 dB/s.

The analyzer also displays time-domain RMS and sample peak values in dBFS.

##### Standalone Input

JUCE's default standalone wrapper mutes audio input as feedback protection. Spectral Bench uses a custom JUCE standalone application so that analysis input is explicitly enabled in Standalone mode.

AU and VST3 do not use this standalone-specific behavior.

##### Realtime Diagnostics

The current UI also exposes:

- dropped input block/sample count
- analysis-frame overlap continuity error count

These diagnostics were added while investigating occasional broadband spectrum bursts.

With the current implementation, normal operation has been verified with zero FIFO drops and zero frame-overlap continuity errors.

The diagnostic counters are retained for realtime-pipeline diagnostics and validation.

##### Current Validation Checkpoint

The current macOS 1.1.0 build has verified:

- live audio input reaches the Standalone analyzer
- calibrated level and FFT behavior with known sine stimuli
- FFT/window/averaging/peak/display-range controls
- defined single-tone, THD/THD+N, SMPTE-style, and CCIF measurement behavior
- 6/6 automated tests, including the permanent independent reference-validation gate
- AU validation with `auval`
- Logic Pro AU loading and smoke testing
- VST3 factory/class vendor metadata as UTF-8 `60°N Signal Works`
- generated macOS 1.1.0 package installation and Standalone/Logic smoke testing

Distortion analysis is implemented and covered by automated and independent reference validation.

#### Spectrum Level Semantics

Spectral Bench's current spectrum display is calibrated in **dBFS/bin**.

This is the intended representation for the normal real-time spectrum view and
for tone, harmonic, and intermodulation measurements.

For broadband noise, the displayed level of an individual FFT bin depends on
bin bandwidth. Doubling FFT size halves bin bandwidth, so broadband noise power
per bin should fall by approximately 3.01 dB even though the broadband RMS
signal level is unchanged.

A coherent sine tone does not follow this same 3 dB-per-doubling behavior.

Spectral Bench 1.1.0 does not include a power-spectral-density
display in dBFS/Hz. That remains a possible later noise-analysis feature.

##### 15-second statistics capture

The four single-tone modes (Manual Tone, 100 Hz, 1 kHz, and 10 kHz) include a 15-second measurement helper. It accumulates unique analysis frames only while the selected stimulus remains valid, tracks accepted and rejected frames, and enforces stimulus continuity so a dropout cannot silently become part of a valid result.

The completed measurement reports averaged RMS and fitted fundamental level, plus THD and THD+N when those results have sufficient valid-frame coverage. SMPTE-style and CCIF selective-product modes intentionally do not use this aggregate 15-second helper.

#### License

MIT License. See [LICENSE](LICENSE).

Copyright (c) 2026 Harri Saastamoinen

#### Automated Sweep and Phase Measurement (macOS 2.1.0)

Spectral Bench 2.1.0 adds an automated logarithmic sine-sweep measurement using a fixed two-channel referenced topology. The selected **DUT ch** is the DUT output/input path and the other channel is the direct reference path. Both outputs receive the same sample-synchronous deterministic sweep. Transfer magnitude is calculated as DUT/Reference, so response common to both paths cancels.

The sweep result selector chooses what the graph displays: **Transfer**, **Actual**, **Phase**, or **Live**. Transfer is the referenced magnitude response in dB. Actual is the locally captured DUT amplitude in dBFS and therefore includes the physical path and sweep-boundary behaviour; it is not a normalized transfer function. Phase shows the referenced phase result. Live returns to the normal real-time analyzer.

##### Phase modes

**Raw** shows the complete measured referenced phase, including fixed DUT transport delay. A constant delay therefore appears as a linear phase slope and repeated wrapping at +/-180 degrees.

**Auto** estimates and removes one constant delay from the phase display. This is a convenience phase-alignment estimate, **not a measurement of DUT latency**. The DUT's own phase/group-delay response can influence the estimate, so the displayed `Comp ms` value must not be interpreted as authoritative device latency.

**Baseline** compares two DUT states. Use **Baseline A/B...**: Spectral Bench automatically runs and stores the baseline sweep, asks the user to change only the DUT state, then automatically runs the comparison sweep and displays B relative to A. Intermediate sweep visuals are not part of the procedure. Fixed transport delay, unchanged interface/path phase, and other unchanged response cancel. This is normally the clearest mode for measuring the phase change caused by enabling an EQ/filter or another processing block.

**Manual** removes exactly the constant delay entered in `Comp ms`. Use it when the DUT transport latency is already known independently. If it is not known, it can be measured separately with **60°N Latency Bench** and the measured value entered in milliseconds. This deliberately keeps latency measurement separate from phase interpretation.

A constant transport delay and genuine linear phase are mathematically indistinguishable from phase data alone. Spectral Bench therefore does not silently claim that Auto has discovered the DUT's true latency. Raw preserves everything, Auto is an explicit estimate, Baseline uses a physical A/B reference, and Manual removes exactly the delay chosen by the user.

<!-- FIGURE PLACEHOLDER: Figure 4.2
Application: Spectral Bench
Subject: Saved or validation measurement
Show: A representative validated spectrum, sweep or phase result with numeric readouts.
Suggested size: full text width
Caption: Example of a Spectral Bench validation measurement.
-->

**Figure 4.2.** Example of a Spectral Bench validation measurement.


## 4.4 Validation

#### Principle

Spectral Bench measurements must be validated against deterministic reference signals and independently calculated expected results.

“Looks right” is not a validation method.

#### Reference Sample Rates

At minimum:

- 44.1 kHz
- 48 kHz
- 96 kHz
- 192 kHz

#### FFT Sizes

Validate every supported size:

- 4096
- 8192
- 16384
- 32768
- 65536

#### Windows

Validate:

- Hann
- 4-term Blackman-Harris
- Flat Top

For each window verify:

- coefficient generation
- coherent gain
- sum of squared coefficients
- ENBW
- exact-bin amplitude correction

#### Spectral Amplitude Reference

For every supported FFT size/window combination:

Input:

```text
bin-centred sine
peak amplitude = 0.5
```

Expected fitted/displayed tone amplitude:

```text
-6.020599913 dBFS
```

The independent deterministic reference matrix and its frozen v1.0 pass/fail tolerances are enforced by `SpectralBenchReferenceValidation`.

#### dBFS Meter References

##### Full-scale sample

```text
x = 1.0
sample peak = 0 dBFS
```

##### Full-scale-peak sine

```text
sine peak = 1.0
sample peak = 0 dBFS
RMS = -3.010299957 dBFS
```

##### Half-scale-peak sine

```text
sine peak = 0.5
sample peak = -6.020599913 dBFS
RMS = -9.030899870 dBFS
```

#### Overlap / Scheduling

Verify that:

```text
hop = N / 4
```

for every FFT size.

Analysis output cadence must match sample-rate-derived hop duration rather than UI repaint cadence.

#### Averaging

Verify exponential power averaging for:

- Fast: 0.25 s
- Medium: 1.00 s
- Slow: 4.00 s

Test at multiple FFT sizes/sample rates to confirm that equivalent physical time constants are preserved.

#### Spectrum Peak Hold

Verify:

- Hold never decreases without reset
- Reset clears stored peaks
- Decay falls at 20 dB/s
- a new higher value immediately replaces a decayed held value

#### Fundamental Estimation

Use deterministic tones:

- exact-bin
- half-bin offset
- other non-coherent offsets
- 100 Hz
- 1 kHz
- 10 kHz
- representative intermediate frequencies

Verify both:

- FFT initial estimate
- least-squares refined frequency/amplitude

Also verify stimulus confidence independently of absolute level:

- a resolved tone below -120 dBFS remains valid when it has at least 12 dB local prominence and remains above the very-low numerical sanity backstop
- a shallow nominal-frequency noise bump without 12 dB local prominence is rejected
- a stronger unrelated off-frequency tone does not steal a defined-tone measurement
- both carriers of SMPTE-style and CCIF stimuli must independently satisfy the prominence check

#### Harmonic Analysis

Build deterministic synthetic signals containing a known fundamental and H2 through H10 at independently selected levels.

Verify:

- fitted fundamental level
- each valid harmonic level
- dBc conversion
- above-Nyquist products marked unavailable
- THD RSS calculation

#### THD

For known harmonic amplitudes:

```text
THD = sqrt(sum(Vn^2)) / V1
```

Compare against independently computed reference values.

#### THD+N

Use deterministic cases containing:

1. fundamental only
2. fundamental + known H2/H3
3. fundamental + deterministic broadband noise
4. fundamental + harmonics + noise
5. fundamental + hum/spurious tones

Verify both bandwidth modes:

- 20 Hz to 20 kHz
- 20 Hz to Nyquist

Verify that fitted-fundamental subtraction does not materially dominate the residual for a pure tone.

Verify Parseval/window-energy consistency of integrated residual power.

#### CCIF / DFD-Style Test

Stimulus:

```text
19 kHz + 20 kHz
equal amplitudes
```

Verify extraction and spectrum markers for:

- 1 kHz
- 18 kHz
- 21 kHz where below Nyquist and inside the analyzer data range

Also verify that a valid 21 kHz product is still reported numerically when the live spectrum display is capped at 20 kHz. The graph limit must not silently become an analysis-bandwidth limit.

Do not add a normative aggregate percentage pass/fail test until the exact intended standard normalization is verified.

#### SMPTE-Style Test

Stimulus:

```text
60 Hz + 7 kHz
4:1 low/high linear amplitude ratio
```

Verify extraction and spectrum markers for:

- 6880 Hz
- 6940 Hz
- 7060 Hz
- 7120 Hz

Do not add a normative aggregate percentage pass/fail test until the exact intended standard normalization is verified.


#### Independent Reference Harness

Sprint 032 adds `SpectralBenchReferenceValidation` as a pre-release evidence
collector. It generates deterministic time-domain signals from analytic
definitions, passes them through the production FFT/analyzer path, and compares
the results with independently calculated references.

The first matrix covers:

- all 4 reference sample rates
- all 5 supported FFT sizes
- all 3 supported windows
- exact-bin amplitude calibration
- non-coherent frequency/amplitude estimation
- H2-H10 and RSS THD
- CCIF selective products
- SMPTE-style selective product-pair RSS

The harness is a permanent CTest release gate. The v1.0 deterministic
reference-validation tolerances are frozen as follows:

| Quantity | v1.0 validation tolerance |
|---|---:|
| Exact-bin amplitude | ±0.01 dB |
| Off-bin frequency | ±0.10 FFT bin |
| Off-bin amplitude | ±0.25 dB |
| H2-H10 levels | ±0.05 dB |
| THD | ±0.05 dB |
| CCIF selective products | ±1.0 dB |
| SMPTE-style selective product pairs | ±1.0 dB |

These limits apply to the deterministic synthetic reference matrix and are
intended to guard the DSP implementation against regression. They are **not**
blanket claims that a complete real-world measurement setup, audio interface,
DUT, or analog loop has the same absolute measurement accuracy.


#### Spectral Bench 1.2.0 Platform Status

##### macOS — validated

Spectral Bench 1.2.0 has been built, installed, and functionally tested on macOS.

Completed checks:

- Release build passed
- all automated tests passed
- Standalone launched and passed functional smoke testing
- 20 Hz to 20 kHz / 100 Hz to 10 kHz view selection verified
- Raw / Noise Smooth trace selection verified
- Noise Smooth behavior checked with broadband-noise input
- macOS 1.2.0 installer package built successfully
- installer package installed successfully
- installed Standalone launched successfully
- installed AU bundle reports version 1.2.0
- `auval -v aufx Sgnz Sn60` passed the full validation suite
- Logic Pro loaded Spectral Bench 1.2.0 successfully
- both new 1.2.0 controls were functionally verified in Logic Pro

During validation, an obsolete user-level Spectral Bench 1.1.0 AU copy was found in `~/Library/Audio/Plug-Ins/Components`, while the 1.2.0 installer had correctly installed the current AU in `/Library/Audio/Plug-Ins/Components`. Removing the obsolete user-level copy resolved the host version ambiguity; subsequent `auval` correctly reported **Component Version 1.2.0 (0x10200)**.

##### Windows x64 — retained at 1.1.0

The validated Windows release remains **1.1.0**. Later macOS feature lines have not been ported or validated there, and no Windows update is currently scheduled.

##### Linux x86_64 — retained at 1.1.0

The validated Linux release remains **1.1.0**. Later macOS feature lines have not been ported or validated there, and no Linux update is currently scheduled.

The existing 1.1.0 cross-platform validation record remains valid and should be retained.


#### Cross-Platform Release Validation

The finalized Spectral Bench 1.1.0 source state has completed native validation on all three target platforms.

##### macOS
- automated test suite and deterministic reference validation passed
- Standalone tested
- Audio Unit validated with `auval` and smoke-tested in Logic Pro
- VST3 metadata checked
- 1.1.0 package built, installed, and smoke-tested
- CSV/TXT/PNG Save Result export functionally verified

##### Windows x64
- Release build and automated tests passed
- installer built and tested
- installed Standalone and VST3 validated
- CSV/TXT/PNG result export validated

##### Linux x86_64
- Release build and automated tests passed
- portable package validated
- installed Standalone and VST3 validated
- desktop integration validated
- CSV/TXT/PNG result export validated

Build warnings and validation failures remain release blockers until understood and deliberately resolved.

#### Current Realtime Validation Checkpoint

The realtime analyzer has been exercised natively on macOS Standalone with live interface input; the finalized 1.1.0 source state has additionally completed the cross-platform validation summarized above.

Observed checkpoint:

- processor input and analyzer sample peak agree
- 1 kHz sine at approximately -6 dBFS reads approximately -6 dBFS peak
- sine RMS settles approximately 3.01 dB below peak
- calibrated FFT places the 1 kHz tone at the expected amplitude
- all supported FFT sizes can be selected
- all supported window functions can be selected
- averaging Off/Fast/Medium/Slow operates
- peak Off/Hold/Decay and peak reset operate
- display floors through -140 dBFS operate
- current automated tests pass

Development diagnostics currently include FIFO drop counts and exact overlap continuity checks between consecutive analysis frames.

A longer steady-tone run has shown:

```text
Drops        = 0
Frame errors = 0
```

The earlier occasional broadband burst has not been observed during the latest validation run, but the diagnostics remain enabled until broader testing is complete.

The current automated suite includes deterministic validation for THD, THD+N, SMPTE-style selective product measurements, and CCIF product measurements.

#### Pink-noise dBFS/bin validation

The spectrum calibration was checked using Signal Bench pink noise routed
digitally through BlackHole into Spectral Bench.

Test conditions:

```text
Signal Bench: Pink, 0 dB
Spectral Bench: Blackman-Harris
Averaging: Slow
Peak: Off
View: 0 dB
Hold: Off
Capture: 15 s statistics
```

Measured results:

```text
FFT      RMS dBFS    1 kHz/bin dBFS    Delta      Frames
4096      -14.40        -39.53            --         284
8192      -14.65        -42.59          -3.06        282
16384     -15.34        -45.44          -2.85        177
32768     -13.99        -48.36          -2.92         89
65536     -15.01        -51.10          -2.74         45
```

The theoretical broadband-noise change for each FFT-size doubling is:

```text
-10 log10(2) = -3.0103 dB
```

The measured per-doubling changes were:

```text
-3.06 dB
-2.85 dB
-2.92 dB
-2.74 dB
```

This is considered a successful validation of the current dBFS/bin spectrum
behavior.

The RMS values varied stochastically across independent 15-second pink-noise
captures, but did not show a systematic FFT-size-dependent trend.

The 65536-point FFT also takes visibly longer to settle after a configuration
change than smaller FFT sizes. This is expected because long FFT frames and
large hop sizes produce fewer fresh analysis frames per unit time.

No claim is made here for dBFS/Hz power spectral density, because that
representation is not implemented.

#### 1.1.0 CSV export validation

The measurement CSV exporter is deterministic for a supplied snapshot/context. Automated coverage should verify:

- fixed column/header order
- CSV quoting of textual metadata
- valid numeric fields are emitted
- invalid/not-applicable result fields are empty
- CCIF/SMPTE stimulus-valid flags are preserved
- the companion text report contains provenance and only the mode-relevant result section
- Save Result also writes a non-empty PNG rendered from the Spectrum component


#### Spectral Bench 2.1.0 macOS release validation

Status: **complete/released**. Native macOS Release build, the full 20-test automated suite, sweep/phase physical qualification, guided Baseline A/B qualification, Help/UI manvis, export terminology verification, package qualification, and installed-artifact smoke checks are complete. The final package clean-installed Standalone, AU, and VST3 at the intended system locations. The AU passed full `auval`; VST3 version/bundle/vendor metadata were verified; and the installed Standalone passed basic sweep, Transfer, Actual, and Phase functional checks.

Validated in Standalone: logarithmic X behavior across preset/Custom views, adaptive engineering grid behavior, 10-120 dB spans, coupled dB Top/Floor/Span behavior with Top/Floor zoom anchoring, Input Gain independence from the display viewport, cold-open crosshair hover, stable fixed Trace/Cursor readouts, Command-S Save Result, and cursor/trace capture in saved PNG/data. Automated suite: 20/20 passed. Final package validation confirmed version 2.1.0 and the expected Standalone/AU/VST3 installation payload.

Windows x64 and Linux x86_64 remain on the validated 1.1.0 baseline. No Windows/Linux update is currently scheduled; they are outside the active roadmap.

#### macOS 2.1.0 Sweep and Phase Physical Qualification

The referenced sweep architecture was physically qualified with direct dual-channel loopback and a Neural DSP Quad Cortex DUT. Direct loopback channel swapping produced equal-and-opposite small high-frequency phase slope, confirming that the remaining phase is real physical channel/path mismatch rather than an estimator artifact.

Magnitude repeatability in direct loopback was approximately 0.000023 dB worst-case over 30 Hz-18 kHz across repeated sweeps. Known 1 kHz 12 dB/oct and 24 dB/oct low-pass responses behaved as expected. Level-dependence checks at -6, -12, -24 and -48 dBFS passed, and physical sweep checks covered 44.1, 48 and 96 kHz plus representative 16, 64 and 512 sample buffers.

Phase-mode qualification used the Quad Cortex. Raw preserved the DUT transport-delay slope. Auto produced a useful response-dependent compensation estimate, but that estimate differed from the independently measured DUT latency, as expected from the delay/linear-phase ambiguity. Latency Bench measured the tested QC path at 89.15 samples / 1.857 ms at 48 kHz, while Spectral Bench Auto estimated about 1.42 ms for the tested response. Entering the independently measured 1.857 ms in Manual removed the expected constant-delay phase component and produced an essentially flat LPF-off response through the useful band.

The guided Baseline A/B workflow passed two physical tests: LPF off -> 1 kHz LPF on produced the expected baseline-relative filter phase without transport-delay wraps, and LPF off -> LPF off produced an essentially 0-degree null across the displayed band. These results validate the semantics of Raw, Auto, Manual and Baseline as distinct explicit phase references rather than interchangeable latency estimators.


#### macOS 2.1.0 Export Terminology Qualification

The final export wording distinguishes live analyzer state from completed sweep state. CSV uses `analyzer_mode` for the analyzer measurement selector and `sweep_type` for the appended referenced sweep. TXT uses `Analyzer mode:` and `Sweep type:` respectively. Phase exports also record the selected phase mode and, for Auto/Manual, the applied compensation in milliseconds. This avoids the previous ambiguous combination of a top-level `Mode: Manual Tone` line and a separate sweep result in the same report.

## 4.5 Architecture reference

#### Purpose

This document describes the implemented Spectral Bench architecture. The portable 1.1.0 foundation remains the Windows/Linux baseline, while the current macOS architecture includes the released 2.1.0 viewport, referenced sweep, Actual-response, and phase systems.

#### Primary Boundaries

There are three independent concerns:

1. real-time audio capture
2. measurement / analysis
3. presentation

The UI must not define measurement semantics.

The plugin and standalone wrappers must not contain analyzer DSP.

#### High-Level Data Flow

```text
Audio input
    |
    +--> time-domain meter path
    |      RMS
    |      rolling sample peak
    |
    v
Analysis sample FIFO
    |
    v
Analysis frame builder
    |  N samples
    |  hop N/4
    |
    +------------------------------+
    |                              |
    v                              v
Window + FFT                 tone measurement
    |                              |
    v                              +--> FFT-assisted initial frequency
calibrated spectrum                |
    |                              +--> least-squares frequency refinement
    +--> power averaging           |
    |                              +--> fitted fundamental/harmonics
    +--> spectral peak hold        |
    |                              +--> fundamental subtraction
    |                              |       |
    |                              |       v
    |                              |   residual FFT
    |                              |       |
    |                              |       v
    |                              |   THD+N band integration
    |                              |
    +-------------+----------------+
                  |
                  v
          MeasurementSnapshot
                  |
                  v
                 UI
```

#### Real-Time Audio Thread

The audio callback may:

- read/select the input channel
- update preallocated time-domain meter accumulators
- copy samples into a preallocated analysis FIFO

It must not:

- allocate
- perform FFTs
- perform least-squares fitting
- perform IMD/THD calculations
- call UI code
- wait on blocking locks

#### Analysis Scheduling

FFT size is user-selectable.

Analysis hop is fixed at:

```text
N / 4
```

giving 75% overlap.

Analysis is scheduled by sample availability, not repaint events.

#### Spectrum Engine

The spectrum engine owns:

- window generation
- coherent-gain metadata
- window-energy metadata
- ENBW metadata
- FFT execution
- one-sided amplitude calibration
- broadband/noise power calibration
- spectral averaging
- spectral peak hold

The displayed spectrum is calibrated in dBFS.

#### Tone Measurement Engine

The tone measurement engine is separate from the display FFT even though the FFT provides its initial frequency estimate.

This is deliberate.

Precision harmonic and THD measurements must not become dependent on:

- a tone landing exactly on an FFT bin
- selected window main-lobe width
- arbitrary bin-integration width

The engine refines the tone using deterministic least-squares sinusoidal fitting on the analysis samples.

#### THD+N Engine

THD+N uses fitted-fundamental subtraction in the time domain followed by residual spectral power integration in an explicit bandwidth.

This avoids defining the fundamental notch as “remove one FFT bin”.

#### Measurement Snapshot

The analysis engine publishes immutable/coherent snapshots to the UI.

A conceptual snapshot may contain:

```text
input RMS
input sample peak

spectrum data
peak-hold spectrum

nominal test definition
measurement validity

measured fundamental frequency
fundamental amplitude

harmonic products
THD
THD+N
THD+N bandwidth

IMD product levels
IMD aggregate result when normatively defined
```

The exact C++ type is an implementation detail.

#### UI Update Rate

UI repaint rate and analysis rate are independent.

The UI may repaint more frequently than new FFT data arrives, but it must never manufacture intermediate measurement results.

#### Shared Test Definitions

Signal Bench and Spectral Bench should eventually share a small, platform-independent test-definition module.

It should contain data and derivation rules, not JUCE UI code.

Conceptually:

```cpp
struct ToneDefinition
{
    double frequencyHz;
    double relativeLevelDb;
};

struct ProductDefinition
{
    int coefficientF1;
    int coefficientF2;
    const char* label;
};

struct TestDefinition
{
    TestId id;
    const char* name;
    MeasurementType type;
    std::vector<ToneDefinition> tones;
    std::vector<ProductDefinition> products;
};
```

The representation shown here is illustrative.

A product such as:

```text
2*f1 - f2
```

should be derived from the stimulus definition rather than separately hard-coded as an unrelated absolute frequency.

#### Runtime Independence

Spectral Bench 1.1.0 requires no runtime communication with Signal Bench.

There is no:

- IPC
- plugin-to-plugin connection
- automatic mode switching
- automatic test sequencing

Shared definitions are a source-level compatibility mechanism.

#### Platform Boundary

DSP and measurement code must remain portable C++.

JUCE is used for cross-platform application/plugin infrastructure.

Platform-specific code should be confined to wrappers, build configuration, installation, and packaging wherever possible.

#### Spectrum Processing Controls

Spectrum post-processing belongs to the analysis engine rather than the UI.

The processing order is conceptually:

```text
input samples
    -> overlapped analysis frame
    -> window
    -> calibrated FFT
    -> power-domain averaging
    -> peak hold / peak decay
    -> immutable MeasurementSnapshot
    -> UI
```

The UI requests configuration changes, but the analysis worker owns and applies the actual FFT/window/averaging/peak state.

Current 1.1.0 spectrum controls are:

- FFT size: 4096, 8192, 16384, 32768, 65536
- Hann, 4-term Blackman-Harris, Flat Top
- averaging Off/Fast/Medium/Slow
- peak Off/Hold/Decay
- explicit peak reset
- display floor -80/-100/-120/-140 dBFS

Changing FFT size or window causes the analysis engine to rebuild the relevant analysis state on the worker side.

#### Standalone Wrapper

Spectral Bench uses a custom JUCE standalone application.

This exists because JUCE's standard StandalonePluginHolder mutes audio input by default for feedback protection. Spectral Bench is an analyzer, so live Standalone input is expected.

This behavior is isolated to the Standalone target and does not affect AU or VST3.

#### Realtime Continuity Diagnostics

During development, Spectral Bench records:

- dropped input blocks
- dropped input samples
- FFT-frame overlap continuity errors

With 75% overlap, consecutive frames share `N - N/4` samples. Those overlapping samples must be identical. Any mismatch increments the frame-continuity error counter.

These diagnostics are development instrumentation and do not define user-facing measurement semantics.

#### 1.2.0 trace-presentation layer

Spectral Bench 1.2.0 adds a user-selectable **100 Hz to 10 kHz** zoomed view alongside the normal **20 Hz to 20 kHz** view and adds explicit **Raw / Noise Smooth** trace presentation.

This display layer remains downstream of the calibrated analyzer results. It does not change FFT calibration, analyzer confidence, numeric distortion measurements, cursor source data, or authoritative numeric exports. Raw presentation remains selectable, and the active presentation mode is explicit in the UI.

The 1.2.0 layer was validated on macOS and was subsequently incorporated into the macOS 2.x line. Windows and Linux remain intentionally on the validated 1.1.0 baseline; no port is currently scheduled.


#### 2.0.1 macOS viewport architecture

The macOS 2.0.1 UI extends the spectrum display as an instrument-style viewport. Frequency zoom remains strictly logarithmic: selecting a preset or Custom changes only the visible frequency limits. The X mapping remains log10-based. Custom grid lines are generated from 1-2-5 engineering frequencies per decade and labels are thinned according to available pixel spacing.

The Y viewport is expressed as span plus vertical position. Span is selectable from 120 dB down to 10 dB; position selects the visible dBFS region. Horizontal grid density adapts to the visible span. These are presentation controls and do not modify analyzer calibration.

Input Gain is separate from viewport position. On macOS it is applied only to the selected analysis-channel samples before they are submitted to AnalysisEngine; the plugin audio pass-through remains unchanged.

The dB viewport has one canonical Top/Floor/Span state, with `Span = Top - Floor`. Editing Top or Floor makes that boundary the current zoom anchor; editing Span preserves the current anchor and moves the opposite boundary. The UI controls, graph mapping, and Save Result metadata are all updated from the same canonical state.

The macOS 2.0.1 cursor is a display/measurement layer. Mouse X is converted through the same logarithmic viewport mapping and mouse Y through the active dB viewport. The trace value at the same X is interpolated from analyzer bins. Trace and Cursor readouts are fixed at the top-right of the plot for stable instrument-style presentation. Save Result can freeze the last valid cursor measurement so Command-S preserves the measurement point while the save dialog is opened; the frozen state is used by PNG and numeric/text export.

Windows and Linux retain the validated 1.1.0 behavior and version and are outside the current development roadmap.

#### macOS 2.1.0 Sweep / Transfer Architecture

The production sweep path is a two-channel referenced measurement. The generator renders the deterministic logarithmic sweep once and copies the exact samples to both output channels. One complete output/input path is the DUT and the other is the reference. Swapping DUT channel swaps both output and input roles.

Magnitude/Actual use the qualified integer-delay alignment path. Phase has separate explicit interpretation modes: Raw, Auto, Baseline and Manual. Raw mathematically restores the measured relative delay after coherent sweep projection; Auto applies the estimator-derived constant compensation; Manual subtracts exactly the requested constant delay; Baseline compares the current complex referenced response against a stored physical baseline. These phase choices do not alter the qualified magnitude/Actual estimator path.

The guided Baseline A/B UI is orchestration only. It runs the same underlying sweep engine twice, stores the first completed capture as the baseline, pauses only for the physical DUT-state change, then publishes the second result relative to the baseline.


#### macOS 2.1.0 Export Identity

The export model keeps live analyzer state and completed sweep state distinct. The base measurement snapshot records `analyzer_mode`; when a completed sweep is available, a separate sweep section records `sweep_type`, sweep settings, DUT/reference routing, phase mode, and applicable phase compensation. The human-readable report follows the same distinction with `Analyzer mode:` and `Sweep type:` labels. This prevents a current live analyzer selection such as Manual Tone from being mistaken for the type of a saved sweep result.

# 5. Latency Bench

Latency Bench measures relative physical-path/DUT timing with simultaneous reference and DUT paths.


<!-- FIGURE PLACEHOLDER: Figure 5.1
Application: Latency Bench
Subject: Main window configured for DUT measurement
Show: Audio device, Reference OUT/IN, DUT OUT/IN, baseline state, measurement controls and result area.
Suggested size: full text width
Caption: Latency Bench configured for a physical-path DUT latency measurement.
-->

**Figure 5.1.** Latency Bench configured for a physical-path DUT latency measurement.


## 5.1 User and measurement guide

This guide is the practical operating procedure for 60°N Latency Bench. For the estimator theory and limitations, see `MEASUREMENT_METHOD.md`. For the physical release-validation data, see `REFERENCE_MEASUREMENTS.md`.

#### What Latency Bench measures

Latency Bench measures the extra physical-path delay of a DUT relative to a simultaneous direct reference path. It does not use the audio driver's reported latency as the result.

Use one multichannel interface for both paths:

```text
Reference: Interface OUT A -> Interface IN A
DUT:       Interface OUT B -> DUT -> Interface IN B
```

The same deterministic broadband probe is sent to both outputs. The two returns are captured together, and normalized cross-correlation estimates their relative delay. A direct-loop baseline removes the fixed difference between the two interface channels and cables.

#### Recommended starting setup

- Use two output and two input channels from the same interface and, where practical, the same converter families.
- Start with the default probe level of -30 dBFS.
- Aim for healthy received peaks, roughly -40 to -20 dBFS. Matching amplitudes are not required.
- Disable software loopback and any monitoring route that feeds a measurement input back to a measurement output.
- Keep sample rate, buffer size, channel selection, interface mixer routing and gains unchanged between baseline and DUT measurements.

At 48 kHz, one sample is about 0.020833 ms and 48 samples are exactly 1 ms.

#### 1. Configure the audio interface

Open **Options...** and select the measurement interface, sample rate, buffer size and active physical I/O channels. Then select the Reference out, DUT out, Reference in and DUT in channels in the main window.

Latency Bench persists the selected device and channels. It does not silently switch to the current macOS default device if the saved interface is unavailable.

#### 2. Measure the baseline

Wire both paths directly:

```text
OUT A -> IN A
OUT B -> IN B
```

Click **Measure baseline**. A successful baseline is stored together with the exact device, sample rate, buffer size and four selected channels.

The baseline represents only the fixed differential offset between the two measurement paths. It is not DUT latency. Changing the relevant audio setup invalidates the stored baseline automatically.

#### 3. Insert and measure the DUT

Leave the reference path unchanged and insert the DUT only in the DUT path:

```text
OUT A -> IN A
OUT B -> DUT IN -> DUT OUT -> IN B
```

Click **Measure DUT**. Latency Bench performs ten consecutive runs and reports median, mean, minimum, maximum, standard deviation, correlation and received levels for every run.

Use the **median** as the primary scalar result. The distribution of all ten runs is important when a DUT has multiple internal timing states or produces an ambiguous correlation shape.

#### Cancelling a measurement

**Cancel** is available while either a baseline measurement or a DUT series is running. Cancelling stops the current probe/capture, discards the partial capture and any partial DUT-series results, and returns the application to idle. It does **not** erase a previously valid stored baseline.

This is also the recovery action if a measurement is waiting because the expected audio callbacks or physical return are not arriving. After correcting the device, routing or cabling, the measurement can be started again normally.

#### Reading the result

The corrected latency is:

```text
corrected samples = raw DUT/reference offset - stored baseline offset
milliseconds      = 1000 * corrected samples / sample rate
```

Fractional-sample values come from interpolation around the correlation peak. They are useful for repeatability and comparison, but they should not be interpreted as universally exact physical timing when the DUT strongly changes bandwidth, phase, waveform or internal timing.

##### Correlation

Correlation describes how strongly the captured DUT waveform matches a delayed version of the reference waveform. A simple transparent path can correlate very strongly. Distortion, filtering, modulation and other processing can lower the value without automatically invalidating a stable latency result.

Judge correlation together with repeatability, the ten-run distribution and the DUT's processing.

##### Bandwidth-limited and subwoofer outputs

There is **no fixed minimum LF, maximum HF, absolute-bandwidth, or octave-span requirement**. A DUT may legitimately be a subwoofer output, crossover branch, cabinet/EQ path, or another strongly bandwidth-limited transfer function. Do not bypass intended filtering merely to make the signal more broadband.

Latency Bench first uses the normal fast broadband analysis. If that run fails specifically because timing evidence is weak or because another lag is too competitive, the application automatically retries with **extended analysis**. The retry uses a longer probe and correlation window and spectrally matches the captured reference magnitude to the DUT before correlation. DUT phase is preserved. Silence, clipping, routing, and other non-timing failures are not hidden by this retry.

The report shows `extended` on an individual run and `Extended-analysis runs: N/10 runs` in the DUT-series summary. The main-window subtitle, `extended analysis when needed`, refers to this automatic retry; there is no separate mode to select.

Low-frequency paths particularly benefit from longer observation because their cycles are long. Even then, no algorithm can manufacture a unique delay from a signal that contains genuinely competing timing interpretations. If the extended analysis still has insufficient primary evidence, Latency Bench reports **`Timing evidence too weak for a reliable result.`** If a separate candidate reaches the competing-evidence limit, it reports **`Competing timing peaks make the result ambiguous.`** In either case, the diagnostic candidate values are shown but are **not valid latency results**.

Physical v1.1.1 qualification at 48 kHz includes a realistic **20–160 Hz** subwoofer-style path. With the same wideband path measuring **89.15 samples / 1.857 ms bypassed**, the 20–160 Hz path measured **383.20 / 7.983 ms at 24 dB/oct** and **493.18 / 10.275 ms at 48 dB/oct**, with all 10 runs using extended analysis and standard deviations of only 0.005 and 0.006 samples respectively. This demonstrates why a blanket kHz-bandwidth requirement would be wrong.

For strongly filtered paths, the reported latency describes the timing of the **complete filtered response**. It includes the underlying transport latency plus the filter's phase/group-delay contribution. For example, the 48 dB/oct 20–160 Hz result above is not evidence of 10.275 ms of bare DSP transport latency; relative to the 1.857 ms bypass path, about 8.417 ms of additional timing displacement is associated with the complete filtered transfer function. For loudspeaker/subwoofer alignment, that complete-response timing may be exactly the useful quantity.

##### NEAR-EQUAL alternative peak

Some processed signals produce more than one plausible correlation maximum. The report retains the historical `NEAR-EQUAL` diagnostic at 99% of the selected peak's lag-selection evidence. In v1.1.1, however, the validity policy is stricter: a run is rejected as ambiguous when the strongest separate candidate reaches **90%** of the primary evidence. A valid v1.1.1 run therefore will not normally reach the 99% `NEAR-EQUAL` marker.

Latency Bench deliberately does not force the earlier or later candidate. A rejected ambiguity report shows both candidates as diagnostics instead of hiding the uncertainty or guessing which delay the user expected.

#### Polarity inversion

A polarity-inverting DUT can still be measured. Latency Bench selects delay using the **absolute magnitude** of normalized correlation, so reversing polarity changes the sign of the correlation but should not by itself change the measured delay.

#### Analog and digital paths

The reported result is the latency of the complete physical DUT path inserted between the selected output and input. That can include DSP block latency, converters, digital routing, analog effects loops, external converters and any other processing in that path.

For example, an analog loop inside an otherwise digital device may add a measurable D/A -> analog path -> A/D delay. Measure configurations separately if the goal is to determine the increment contributed by a particular block or loop.

#### Comparing configurations

For A/B latency comparisons:

1. Keep the same valid baseline and measurement-interface configuration.
2. Measure configuration A and save the report.
3. Change only the DUT state being investigated.
4. Measure configuration B.
5. Compare the medians, while also checking standard deviation and individual runs.

If the interface configuration or measurement routing changes, repeat the baseline first.

#### Troubleshooting

If no valid result is obtained, check the physical returns and received peak levels first. Make sure the selected physical channels are active, software loopback is disabled, and no feedback route exists in the interface mixer.

A very low level can make correlation unreliable; clipping can also invalidate the capture. Strong time-varying or nonlinear processing may legitimately produce lower or ambiguous correlation. Bypass processing progressively when diagnosing such a path.

If the measurement does not progress, use **Cancel**, correct the audio-device/routing condition, and run it again.

#### RME TotalMix

With RME interfaces, the Hardware Input fader controls monitoring/routing into a hardware-output submix; it does not set the CoreAudio ADC level received by Latency Bench. Do not raise a Hardware Input fader into a measurement output merely to increase the application's input level, because that can create feedback.

For the validated Babyface Pro workflow, route Software Playback normally to the selected physical outputs, keep Hardware Input monitoring to those outputs off, keep TotalMix Loopback off, and set ADC/input level using the actual input gain/reference-level controls.

#### Saving results

After a completed DUT series, use **Save As...** to store the complete text report. Keep the report when comparing DUT configurations: the individual runs, correlation values, levels and ambiguity flags are useful evidence beyond the headline median.

## 5.2 Measurement method

#### Scope

Latency Bench measures differential **physical-path latency** between a direct reference loop and an arbitrary DUT loop. It is intended for real analog I/O measurements, including converters and DSP devices, rather than merely reporting host or driver buffer settings.

#### Physical topology

The same multichannel measurement interface drives both paths from the same callback:

```text
Reference: OUT A -> IN A
DUT:       OUT B -> DUT -> IN B
```

For baseline calibration the DUT path is replaced by a second direct loop:

```text
OUT A -> IN A
OUT B -> IN B
```

Equivalent output/input channels from the same converter families are preferred. Baseline calibration removes the fixed differential offset of the complete measurement hardware and cabling.

#### Common-mode cancellation

The two captured channels share the same interface, converter clock, and host callback stream. The following are therefore common to both paths and largely cancel from the relative result:

- application scheduling before the output callback,
- CoreAudio output buffering common to both channels,
- interface USB/Thunderbolt transport common to the channels,
- input callback timing,
- host-side capture buffering.

The direct reference path still contains its own D/A conversion, analog cable, and A/D conversion. Latency Bench measures the DUT path relative to that reference and then removes the measured baseline mismatch between the two interface paths.

#### Baseline and corrected result

Let the direct-loop baseline offset be `B` samples and the raw DUT/reference offset be `R` samples.

```text
L = R - B
L_ms = 1000 * L / sample_rate
```

A baseline is valid only for the same audio device, sample rate, buffer size, reference output, DUT output, reference input, and DUT input. Latency Bench persists a successful baseline but restores it only when that setup still matches. A setup change invalidates it.

#### Probe and correlation

Latency Bench emits the same deterministic pseudo-random bipolar broadband burst on both outputs. The default amplitude is -30 dBFS.

The received reference and DUT signals are compared by normalized cross-correlation over the supported lag range. Absolute correlation magnitude is used so a polarity-inverting DUT can still be measured. A three-point parabolic interpolation around the selected correlation maximum provides a fractional-sample estimate.

The full lag range is searched. For performance, each candidate lag is evaluated over the known probe-bearing reference window rather than over the entire capture buffer. This avoids long UI stalls during ten-run series without narrowing the allowed latency search.

The integer sample offset is the fundamental observable. Fractional-sample interpolation improves repeatability and comparison, but should not be over-interpreted when the DUT has unusual bandwidth, phase response, modulation, nonlinear processing, or multiple internal timing states.

#### Repeated DUT measurements

A DUT measurement consists of ten consecutive runs. The report contains:

- median,
- mean,
- minimum and maximum,
- standard deviation,
- each individual latency result,
- correlation for each run,
- reference and DUT capture peaks.

Median is the primary summary statistic because it is robust to occasional alternate states or estimator selections. Mean and standard deviation are retained because they expose instability rather than hiding it.

A low correlation value does not by itself mean the latency result is invalid. Strong nonlinear or frequency/phase-altering processing can make the DUT waveform substantially different from the direct reference while still producing a stable delay estimate. Run-to-run clustering and the complete report should be considered together.

#### Levels

The default probe level is -30 dBFS. Practical received peaks are roughly -40...-20 dBFS. Exact amplitudes do not need to match because normalized correlation is used.

Latency Bench rejects captures that are effectively silent or too close to clipping. External analog gains and hardware mixer routing are not controlled by the application.

#### RME TotalMix note

When using an RME interface, a Hardware Input fader controls monitoring/routing to the currently selected hardware output. It does not set the CoreAudio ADC level received by Latency Bench. Raising a Hardware Input fader into the measurement output submix can therefore create feedback without improving the captured input level.

For the validated Babyface Pro setup:

- route Software Playback channels to the intended physical measurement outputs,
- keep Hardware Input monitoring to those measurement outputs off,
- keep TotalMix Loopback off,
- set ADC/input level with the actual input gain/reference-level controls,
- do not change TotalMix routing or gains between baseline and DUT runs.

#### Cancellation semantics

A running baseline or DUT measurement can be cancelled explicitly. Cancellation returns the engine to idle, stops probe emission, and discards the partial capture. Cancelling a DUT series also discards any runs accumulated by that incomplete series. A previously valid stored baseline is left unchanged. The next measurement starts with freshly cleared capture buffers.

This is a control/recovery operation only; cancellation does not produce or save a partial latency result.

#### Known limitations and interpretation

Latency Bench reports a scalar relative delay. Some DUTs do not have one perfectly invariant latency:

- modulation and time-varying effects can change the waveform from run to run,
- reverbs and delays can produce several correlation features,
- aggressive nonlinear processing can reduce correlation,
- frequency-dependent group delay can make latency signal-dependent,
- internally block-scheduled DSP/converter systems can potentially expose discrete timing states.

The validated Quad Cortex reference series contains examples where simple paths repeat to approximately 0.001 sample standard deviation, while more complex active-DSP paths occasionally form a second cluster roughly five samples above the main cluster. The observation is retained in the documentation without attributing the cause to the DUT or estimator.

See `REFERENCE_MEASUREMENTS.md` for the complete authoritative reports.

#### Correlation ambiguity reporting

Latency Bench also characterizes the strongest separate local correlation maximum. Adjacent integer samples around the selected maximum are treated as the same interpolation lobe and are excluded from this search.

The alternative peak does **not** replace the selected peak automatically. The report gives its corrected latency, signed separation from the selected result, ordinary normalized-correlation magnitude, selection-evidence score, and evidence strength relative to the selected peak.

The historical `NEAR-EQUAL` marker remains defined at 99% of primary selection evidence. Starting with v1.1.1, validity is deliberately stricter: a separate candidate at **90% or more** of primary evidence rejects the run as ambiguous. Consequently, a valid v1.1.1 DUT series will not normally contain a `NEAR-EQUAL` run; the marker remains useful for historical reports and diagnostics.

This deliberately avoids a DUT-specific rule such as "always choose the earlier peak." A strongly processed waveform can legitimately contain more than one strong correlation candidate, and the measurement itself may not establish which candidate corresponds to the most useful physical interpretation. In that case v1.1.1 rejects the run rather than silently choosing the expected, earlier, or later delay.

During Quad Cortex qualification, the active four-block chain consistently produced simultaneous peaks near 174.7 and 179.8 samples, separated by about 5.1 samples. Either peak could become the numerically strongest one by a very small correlation margin. This demonstrated estimator ambiguity rather than evidence, by itself, of the DUT switching between two exclusive latency states.
#### Quad Cortex validation example

The v1.0.0 physical validation used these Quad Cortex blocks as the concrete processed-DUT example:

```text
Jewel Comp -> Analog FX Loop -> Brit 2203 Amp -> Analog Delay -> Brit 412 GB Cab
```

The active four-block measurement used Jewel Comp, Brit 2203 Amp, Analog Delay, and Brit 412 GB Cab. The final validation case additionally inserted the physical Analog FX Loop after Jewel Comp, adding the Quad Cortex D/A -> analog patch cable -> A/D path. These block names describe the validation setup only; the Latency Bench measurement method itself remains DUT-agnostic.


#### Candidate evidence and bandwidth-limited DUTs

Candidate lags can have different valid overlap lengths near capture boundaries.
Raw normalized-correlation coefficients are not equally persuasive when they
are estimated from very different sample counts. Peak selection therefore uses
an evidence score:

`abs(correlation) * sqrt(actual overlap / nominal correlation window)`

The nominal window is 4096 samples. Full-window candidates are unchanged.
Short-overlap edge candidates are down-weighted according to their reduced
statistical evidence. This does not prefer positive latency, impose an expected
latency, or reduce the signed search range.

The displayed primary `corr` value remains the ordinary absolute normalized
correlation coefficient at the selected lag. Candidate selection and displayed
correlation therefore have deliberately different roles.

A strongly bandwidth-limited DUT can produce deterministic nearby correlation
lobes. Such alternatives are not automatically errors: they can reflect the
DUT transfer function itself. Repeatability, alternative-peak strength and
physical plausibility should be considered together. If the remaining signal
does not contain enough timing information for a defensible estimate, the
measurement should be treated as ambiguous rather than forcing an expected
latency.


#### Confidence diagnostics

A rejected run retains and reports the selected candidate lag, raw correlation, overlap-aware selection evidence, and strongest separate alternative. This is diagnostic information, not a valid latency result. It distinguishes weak absolute timing evidence from genuinely competing lag interpretations.


#### Confidence policy after physical bandwidth qualification

Physical qualification showed that a fixed raw normalized-correlation cutoff is
not a valid general reliability criterion. A 1 kHz / 48 dB/oct HPF produced a
stable selected candidate at 133.60 samples with raw correlation 0.1856 and
selection evidence 0.1856; its strongest separate candidate had only 51.2% of
the primary evidence. Rejecting that run solely because `corr < 0.20` discarded
useful deterministic timing information.

Validity therefore uses the same overlap-aware evidence used for lag selection:

- primary selection evidence must be at least 0.10;
- the strongest separate candidate must remain below 90% of the primary
  selection evidence.

The 0.10 evidence floor is intentionally conservative for the nominal
4096-sample correlation window, while no longer assuming that spectral
colouration must preserve a raw correlation of 0.20. The 90% competing-evidence
limit preserves the physically validated 300–3400 Hz / 24 dB/oct case, whose
deterministic nearby lobe was about 83.3%, while rejecting cases with genuinely
competing timing interpretations.

The existing `NEAR-EQUAL` diagnostic remains at 99% for reporting, but such a
case is already invalid under the stricter 90% validity rule.


#### Automatic extended analysis for bandwidth-limited DUTs

The normal measurement uses a 2048-sample probe and a 4096-sample correlation window. This is fast and has been physically qualified across broadband, LPF, HPF, band-pass and EQ-shaped paths.

A legitimate LF-only DUT can require a longer observation time. Physical qualification with a 20–160 Hz, 48 dB/oct band-pass demonstrated this limit directly: the normal capture produced only 0.0696 primary evidence, with a 99.1% competing candidate. The result was correctly rejected, but the DUT bandwidth itself is realistic for a subwoofer output.

For a DUT run that fails specifically because timing evidence is weak or competing, Latency Bench therefore retries that run automatically with an 8192-sample probe and a 12288-sample correlation window. During that retry, the captured reference is magnitude-matched to the DUT spectrum before correlation; DUT phase is not altered. Level, clipping and routing failures are not retried. The signed lag search range and confidence policy are unchanged.

This is deliberately evidence-driven rather than based on fixed LF/HF bandwidth limits. There is no universal frequency-span rule that guarantees unique time-delay estimation: filter phase, group delay, spectral weighting and observation duration all matter. If the extended capture still cannot establish a unique timing interpretation, the result remains rejected rather than being forced.

Physical 20–160 Hz qualification at 48 kHz demonstrated the completed fallback:

- bypassed path: 89.15 samples / 1.857 ms, normal analysis, 0/10 extended runs;
- 20–160 Hz, 24 dB/oct HPF+LPF: 383.20 / 7.983 ms, 10/10 extended, standard deviation 0.005 samples, primary correlation/evidence about 0.853 and strongest alternative about 66.4%;
- 20–160 Hz, 48 dB/oct HPF+LPF: 493.18 / 10.275 ms, 10/10 extended, standard deviation 0.006 samples, primary correlation/evidence about 0.798 and strongest alternative 78.0%.

Before spectral matching, the same 20–160 Hz / 48 dB/oct path was correctly rejected: primary evidence was only 0.0662. Its positive alternative was about 492.12 samples, within about 1.1 samples of the final qualified 493.18-sample solution. The slope-dependent 24/48 dB/oct results and immediate return to the 89.15-sample bypass result provide a physical sanity check that the extended solution follows the filtered transfer function rather than an arbitrary remote correlation lobe.

Additional physical boundary tests exercised the same policy without an expected-latency bias:

- broadband/bypassed path: 89.15 samples / 1.857 ms, normal analysis;
- 2 kHz HPF, 48 dB/oct: 90.91 / 1.894 ms, stable, strongest alternative 77.0%;
- 2–4 kHz band-pass, 48+48 dB/oct: 114.05 / 2.376 ms, stable, strongest alternative 81.5%;
- 2–3 kHz band-pass: rejected as ambiguous at 91.6% competing evidence;
- 100–500 Hz band-pass: rejected as ambiguous at 92.4% competing evidence;
- 20–160 Hz, 24 dB/oct: 383.20 / 7.983 ms after extended analysis;
- 20–160 Hz, 48 dB/oct: 493.18 / 10.275 ms after extended analysis.

These cases demonstrate that neither octave span nor absolute bandwidth alone defines measurability. The estimator's evidence and competition tests are the operative criteria.

The difference between bypass and a strongly filtered result is not bare device processing latency. It includes the filter's phase/group-delay contribution. For loudspeaker/subwoofer alignment this complete-response timing can be the quantity of interest, but it must be interpreted accordingly.

<!-- FIGURE PLACEHOLDER: Figure 5.2
Application: Latency Bench
Subject: Bandwidth-limited DUT result
Show: A completed extended-analysis result with evidence and alternative diagnostics visible.
Suggested size: full text width
Caption: Extended analysis of a strongly bandwidth-limited DUT.
-->

**Figure 5.2.** Extended analysis of a strongly bandwidth-limited DUT.


## 5.3 Reference and qualification measurements

> **Status:** These are the final authoritative v1.0.0 release-validation reference measurements.

#### Purpose

This document records the authoritative physical reference series used during Latency Bench validation. These are real saved application reports, not synthetic expected values.

Measurement interface: **RME Babyface Pro**  
DUT: **Neural DSP Quad Cortex**  
Sample rate: **48 kHz**  
Audio buffer: **16 samples**  
Stored baseline for these reports: **0.00 samples**

The baseline was obtained with two direct physical interface loopbacks. For the DUT series, the reference path remained direct while the Quad Cortex occupied only the DUT path. Interface configuration, channel selections, mixer routing, and gains were kept unchanged.

The four DUT cases were intentionally arranged as a progression:

1. Quad Cortex cable-only path, no DSP blocks.
2. Same general preset topology with four DSP blocks present but bypassed.
3. The same four DSP blocks active.
4. The same active four-block chain plus a physical analog FX loop, with the loop send connected directly to the return by a patch cable.

The active four-block chain used during this validation was:

```text
Jewel Comp -> Brit 2203 Amp -> Analog Delay -> Brit 412 GB Cab
```

For the FX-loop case, the physical D/A -> patch cable -> A/D loop was inserted after the compressor.

#### Summary

| Configuration | Median | Mean | Min | Max | Std dev |
| --- | ---: | ---: | ---: | ---: | ---: |
| Cable only / no DSP blocks | 89.14 samples / 1.857 ms | 89.14 | 89.14 | 89.14 | 0.001 samples / 0.0000 ms |
| Four blocks present, all bypassed | 153.14 / 3.190 ms | 153.14 | 153.14 | 153.14 | 0.001 / 0.0000 ms |
| Four blocks active | 174.69 / 3.639 ms | 175.19 | 174.64 | 179.76 | 1.524 / 0.0318 ms |
| Four blocks active + analog FX loop | 296.03 / 6.167 ms | 297.53 | 295.94 | 301.10 | 2.334 / 0.0486 ms |

Median-to-median increments:

```text
Cable only -> four blocks present/bypassed:
+64.00 samples = +1.333 ms

Four blocks bypassed -> four blocks active:
+21.55 samples = +0.449 ms

Four blocks active -> active + analog FX loop:
+121.34 samples = +2.528 ms
```

The simple cable-only and all-bypassed cases are exceptionally stable. The active four-block case contains one result at 179.76 samples while the main cluster is approximately 174.64...174.72 samples. The active + analog-loop case contains a main cluster around 295.94...296.03 samples and a second cluster around 301.08...301.10 samples.

These clustered results are deliberately preserved. They may represent a DUT timing state, correlation ambiguity, or another deterministic interaction. The reference data alone does not establish the cause. The median remains a robust summary of the dominant state.

#### Raw application reports

##### Cable only / no DSP blocks

```text
Latency Bench DUT measurement
Sample rate: 48000 Hz
Runs: 10
Baseline: 0.00 samples
Corrected latency:
Median: 89.14 samples / 1.857 ms
Mean: 89.14 samples / 1.857 ms
Min: 89.14 samples / 1.857 ms
Max: 89.14 samples / 1.857 ms
Std dev: 0.001 samples / 0.0000 ms

Runs:
1: 89.14 samples / 1.857 ms | corr 0.8214 | ref -15.8 dBFS | DUT -14.6 dBFS
2: 89.14 samples / 1.857 ms | corr 0.8210 | ref -15.8 dBFS | DUT -14.7 dBFS
3: 89.14 samples / 1.857 ms | corr 0.8205 | ref -15.8 dBFS | DUT -14.7 dBFS
4: 89.14 samples / 1.857 ms | corr 0.8205 | ref -15.8 dBFS | DUT -14.7 dBFS
5: 89.14 samples / 1.857 ms | corr 0.8212 | ref -15.8 dBFS | DUT -14.7 dBFS
6: 89.14 samples / 1.857 ms | corr 0.8220 | ref -15.8 dBFS | DUT -14.7 dBFS
7: 89.14 samples / 1.857 ms | corr 0.8224 | ref -15.8 dBFS | DUT -14.6 dBFS
8: 89.14 samples / 1.857 ms | corr 0.8222 | ref -15.8 dBFS | DUT -14.6 dBFS
9: 89.14 samples / 1.857 ms | corr 0.8220 | ref -15.8 dBFS | DUT -14.6 dBFS
10: 89.14 samples / 1.857 ms | corr 0.8215 | ref -15.8 dBFS | DUT -14.6 dBFS
```

##### Four DSP blocks present, all bypassed

```text
Latency Bench DUT measurement
Sample rate: 48000 Hz
Runs: 10
Baseline: 0.00 samples
Corrected latency:
Median: 153.14 samples / 3.190 ms
Mean: 153.14 samples / 3.190 ms
Min: 153.14 samples / 3.190 ms
Max: 153.14 samples / 3.190 ms
Std dev: 0.001 samples / 0.0000 ms

Runs:
1: 153.14 samples / 3.190 ms | corr 0.8240 | ref -15.8 dBFS | DUT -14.7 dBFS
2: 153.14 samples / 3.190 ms | corr 0.8247 | ref -15.8 dBFS | DUT -14.7 dBFS
3: 153.14 samples / 3.190 ms | corr 0.8248 | ref -15.8 dBFS | DUT -14.6 dBFS
4: 153.14 samples / 3.190 ms | corr 0.8246 | ref -15.8 dBFS | DUT -14.6 dBFS
5: 153.14 samples / 3.190 ms | corr 0.8243 | ref -15.8 dBFS | DUT -14.6 dBFS
6: 153.14 samples / 3.190 ms | corr 0.8238 | ref -15.8 dBFS | DUT -14.7 dBFS
7: 153.14 samples / 3.190 ms | corr 0.8231 | ref -15.8 dBFS | DUT -14.7 dBFS
8: 153.14 samples / 3.190 ms | corr 0.8228 | ref -15.8 dBFS | DUT -14.7 dBFS
9: 153.14 samples / 3.190 ms | corr 0.8233 | ref -15.8 dBFS | DUT -14.7 dBFS
10: 153.14 samples / 3.190 ms | corr 0.8241 | ref -15.8 dBFS | DUT -14.7 dBFS
```

##### Four DSP blocks active

```text
Latency Bench DUT measurement
Sample rate: 48000 Hz
Runs: 10
Baseline: 0.00 samples
Corrected latency:
Median: 174.69 samples / 3.639 ms
Mean: 175.19 samples / 3.650 ms
Min: 174.64 samples / 3.638 ms
Max: 179.76 samples / 3.745 ms
Std dev: 1.524 samples / 0.0318 ms

Runs:
1: 174.70 samples / 3.640 ms | corr 0.3319 | ref -15.8 dBFS | DUT -22.0 dBFS
2: 174.72 samples / 3.640 ms | corr 0.3340 | ref -15.8 dBFS | DUT -22.0 dBFS
3: 174.71 samples / 3.640 ms | corr 0.3345 | ref -15.8 dBFS | DUT -22.0 dBFS
4: 174.71 samples / 3.640 ms | corr 0.3344 | ref -15.8 dBFS | DUT -22.1 dBFS
5: 174.67 samples / 3.639 ms | corr 0.3322 | ref -15.8 dBFS | DUT -22.2 dBFS
6: 174.64 samples / 3.638 ms | corr 0.3315 | ref -15.8 dBFS | DUT -22.0 dBFS
7: 174.64 samples / 3.638 ms | corr 0.3333 | ref -15.8 dBFS | DUT -22.0 dBFS
8: 174.64 samples / 3.638 ms | corr 0.3296 | ref -15.8 dBFS | DUT -22.0 dBFS
9: 179.76 samples / 3.745 ms | corr 0.3302 | ref -15.8 dBFS | DUT -22.0 dBFS
10: 174.69 samples / 3.639 ms | corr 0.3306 | ref -15.8 dBFS | DUT -22.1 dBFS
```

##### Four DSP blocks active + analog FX loop

```text
Latency Bench DUT measurement
Sample rate: 48000 Hz
Runs: 10
Baseline: 0.00 samples
Corrected latency:
Median: 296.03 samples / 6.167 ms
Mean: 297.53 samples / 6.198 ms
Min: 295.94 samples / 6.166 ms
Max: 301.10 samples / 6.273 ms
Std dev: 2.334 samples / 0.0486 ms

Runs:
1: 301.10 samples / 6.273 ms | corr 0.3375 | ref -15.8 dBFS | DUT -21.8 dBFS
2: 296.01 samples / 6.167 ms | corr 0.3340 | ref -15.8 dBFS | DUT -21.9 dBFS
3: 296.03 samples / 6.167 ms | corr 0.3364 | ref -15.8 dBFS | DUT -21.8 dBFS
4: 296.03 samples / 6.167 ms | corr 0.3371 | ref -15.8 dBFS | DUT -22.0 dBFS
5: 296.03 samples / 6.167 ms | corr 0.3383 | ref -15.8 dBFS | DUT -22.3 dBFS
6: 296.00 samples / 6.167 ms | corr 0.3375 | ref -15.8 dBFS | DUT -22.4 dBFS
7: 295.96 samples / 6.166 ms | corr 0.3364 | ref -15.8 dBFS | DUT -22.0 dBFS
8: 295.94 samples / 6.166 ms | corr 0.3389 | ref -15.8 dBFS | DUT -22.0 dBFS
9: 301.09 samples / 6.273 ms | corr 0.3370 | ref -15.8 dBFS | DUT -22.0 dBFS
10: 301.08 samples / 6.273 ms | corr 0.3379 | ref -15.8 dBFS | DUT -21.8 dBFS
```

#### v1.0.0 release reference measurements

The following four measurements are the authoritative Latency Bench v1.0.0
release-validation reference set. They were repeated after the application
and installer were frozen and validated.

All measurements used 48 kHz, ten DUT runs, and a stored direct-loopback
baseline of 0.00 samples. The same measurement-interface and routing setup
was retained across the four DUT cases.

##### 1. Quad Cortex, cable only / no DSP blocks

Corrected latency:

- Median: 89.15 samples / 1.857 ms
- Mean: 89.15 samples / 1.857 ms
- Min: 89.15 samples / 1.857 ms
- Max: 89.15 samples / 1.857 ms
- Standard deviation: 0.001 samples / 0.0000 ms
- Near-equal alternative correlation peak: 0/10 runs
- Correlation: approximately 0.8144...0.8162
- Reference peak: -15.8 dBFS
- DUT peak: -14.6...-14.7 dBFS

This simple path is effectively sample-stable across the complete series.

##### 2. Four DSP blocks present, all bypassed

Corrected latency:

- Median: 153.15 samples / 3.191 ms
- Mean: 153.15 samples / 3.191 ms
- Min: 153.15 samples / 3.191 ms
- Max: 153.15 samples / 3.191 ms
- Standard deviation: 0.001 samples / 0.0000 ms
- Near-equal alternative correlation peak: 0/10 runs
- Correlation: approximately 0.8168...0.8186
- Reference peak: -15.8 dBFS
- DUT peak: -14.6...-14.7 dBFS

Relative to the cable-only case, merely inserting the four bypassed blocks
adds 64.00 samples, approximately 1.334 ms.

##### 3. Four DSP blocks active

Chain:

`Jewel Comp -> Brit 2203 Amp -> Analog Delay -> Brit 412 GB Cab`

Corrected latency:

- Median: 174.71 samples / 3.640 ms
- Mean: 175.20 samples / 3.650 ms
- Min: 174.65 samples / 3.638 ms
- Max: 179.78 samples / 3.745 ms
- Standard deviation: 1.528 samples / 0.0318 ms
- Near-equal alternative correlation peak: 5/10 runs
- Selected correlation: approximately 0.3298...0.3349
- Reference peak: -15.8 dBFS
- DUT peak: -22.0...-22.2 dBFS

The known secondary correlation maximum remains visible approximately
5.1 samples from the primary maximum. In one run the alternative maximum
slightly exceeds the usual maximum and is selected. The ambiguity reporting
therefore behaves as designed; the series median remains representative of
the dominant latency cluster.

Relative to the bypassed four-block case, activating the blocks adds
21.56 samples, approximately 0.449 ms by the reported median values.

##### 4. Four DSP blocks active plus physical analog FX loop

The complete Quad Cortex validation chain for this case was:

`Jewel Comp -> Analog FX Loop -> Brit 2203 Amp -> Analog Delay -> Brit 412 GB Cab`

The same four active DSP blocks were used as in the preceding case, with the
physical Analog FX Loop inserted after Jewel Comp. The loop adds a D/A ->
analog patch cable -> A/D path.

Corrected latency:

- Median: 296.31 samples / 6.173 ms
- Mean: 296.32 samples / 6.173 ms
- Min: 296.26 samples / 6.172 ms
- Max: 296.40 samples / 6.175 ms
- Standard deviation: 0.051 samples / 0.0011 ms
- Near-equal alternative correlation peak: 0/10 runs
- Selected correlation: approximately 0.3755...0.3847
- Reference peak: -15.8 dBFS
- DUT peak: -22.4...-23.0 dBFS

A secondary maximum remains visible about 5.46...5.59 samples later, but its
relative correlation strength is only about 86.6...88.2%, so none of the ten
runs meets the 99% near-equal threshold.

Relative to the active four-block case, adding the physical analog FX loop
adds 121.60 samples, approximately 2.533 ms by the reported median values.

#### Release-reference summary

| DUT configuration | Median samples | Median ms | Std dev samples | Near-equal |
| --- | ---: | ---: | ---: | ---: |
| Cable only / no blocks | 89.15 | 1.857 | 0.001 | 0/10 |
| Four blocks, bypassed | 153.15 | 3.191 | 0.001 | 0/10 |
| Four blocks, active | 174.71 | 3.640 | 1.528 | 5/10 |
| Four blocks active + analog FX loop | 296.31 | 6.173 | 0.051 | 0/10 |

Median-to-median increments:

- Cable only -> four bypassed blocks: +64.00 samples / about +1.334 ms
- Four bypassed -> four active: +21.56 samples / about +0.449 ms
- Four active -> active + analog FX loop: +121.60 samples / about +2.533 ms

These measurements validate both the very high repeatability of simple paths
and the ambiguity-aware correlation reporting required for more complex,
strongly processed signals. They are validation/reference measurements for
Latency Bench itself; they are not intended as general specifications for the
DUT.


#### v1.1.1 estimator and bandwidth qualification

The v1.0.0 Quad Cortex reports above remain historical release-reference measurements and are not rewritten. v1.1.1 adds a separate estimator-robustness qualification series, performed at 48 kHz with the same physical measurement concept.

Key physically observed cases:

| DUT response | Result | Analysis / interpretation |
| --- | ---: | --- |
| Wideband bypass | 89.15 samples / 1.857 ms | Normal analysis, 0/10 extended |
| 2 kHz HPF, 48 dB/oct | 90.91 / 1.894 ms | Stable, alternative 77.0% |
| 2–4 kHz, 48+48 dB/oct | 114.05 / 2.376 ms | Stable, alternative 81.5% |
| 2–3 kHz | Rejected | Competing timing peaks, 91.6% |
| 100–500 Hz | Rejected | Competing timing peaks, 92.4% |
| 20–160 Hz, 24 dB/oct | 383.20 / 7.983 ms | Extended 10/10, std dev 0.005 samples |
| 20–160 Hz, 48 dB/oct | 493.18 / 10.275 ms | Extended 10/10, std dev 0.006 samples |

For the 20–160 Hz / 48 dB/oct case, the pre-spectral-match extended analysis was correctly rejected with only 0.0662 primary evidence. Its positive alternative was about 492.12 samples. With spectrally matched extended analysis, all ten runs converged at 493.17–493.18 samples with primary correlation/evidence about 0.798 and the strongest alternative at 78.0%. The 24 dB/oct case independently converged at 383.19–383.21 samples with correlation/evidence about 0.853. Immediate bypass returned to 89.15 samples using normal analysis.

The 20–160 Hz results are **complete-response timing measurements**, not bare DSP transport-latency specifications. Relative to the 89.15-sample / 1.857 ms bypass result, the 24 dB/oct response adds about 294.05 samples / 6.126 ms and the 48 dB/oct response about 404.03 samples / 8.417 ms. The slope-dependent difference is consistent with the filters' phase/group-delay contribution being part of the measured timing.

#### Documentation scope

These reports are retained as historical physical validation data. Practical operating instructions are maintained separately in `MEASUREMENT_GUIDE.md`; estimator theory and interpretation remain in `MEASUREMENT_METHOD.md`. UI/control maintenance such as measurement cancellation does not change the numerical reference data above.

## 5.4 Application reference

Version: **1.1.1**

Latency Bench is a focused macOS utility for measuring **true physical signal-path latency** through an arbitrary device under test (DUT) or complete analog/digital signal chain.

It is deliberately DUT-agnostic. A DUT may be a modeler, converter, audio interface, digital mixer, DSP processor, pedal, rack device, or a chain of several devices. The application measures the physical path rather than relying on a driver's reported latency.

#### Measurement principle

One multichannel audio interface provides two simultaneous output paths and two simultaneous return paths:

```text
Reference: Interface OUT A -> Interface IN A
DUT:       Interface OUT B -> DUT -> Interface IN B
```

Latency Bench emits the same deterministic broadband probe on both outputs and captures both returns in the same audio callback stream. Normalized cross-correlation estimates the relative sample offset between the two captures. A direct-loop baseline measures fixed channel-to-channel mismatch in the measurement interface and cabling; that offset is subtracted from the DUT result.

```text
corrected latency = DUT/reference offset - stored baseline offset
milliseconds       = 1000 * corrected samples / sample rate
```

At 48 kHz, one sample is approximately 0.020833 ms and 48 samples are exactly 1 ms.

#### Why the two-path method

Both return channels use the same interface, host callback stream, and converter clock. Host scheduling and much of the interface/transport buffering are therefore common to both paths and largely cancel from the differential result. The remaining fixed difference between the two physical measurement channels is removed by baseline calibration.

For best accuracy, use equivalent physical output/input channels from the same converter families and do not change the interface configuration between baseline and DUT measurements.

#### Wiring

##### Baseline

```text
Interface OUT A -> Interface IN A
Interface OUT B -> Interface IN B
```

##### DUT

```text
Interface OUT A -> Interface IN A
Interface OUT B -> DUT IN -> DUT OUT -> Interface IN B
```

Do not enable software loopback on the measurement channels.

#### Workflow

1. Open **Options...** and select the measurement interface, sample rate, buffer size, and enabled physical I/O.
2. Select the reference and DUT output/input channels in the main window.
3. Set the probe level. The default is -30 dBFS.
4. Wire both paths as direct loopbacks and run **Measure baseline**.
5. Insert the DUT only in path B. Do not change the interface, mixer routing, gains, sample rate, buffer size, or selected channels.
6. Run **Measure DUT**. Latency Bench performs ten consecutive measurements. Use **Cancel** at any time to abort the current baseline or DUT measurement safely without changing a previously valid baseline.
7. Inspect the median, mean, minimum, maximum, standard deviation, correlation, and individual runs.
8. Use **Save As...** to save the complete result report as text.

A successful baseline persists across relaunches together with the device, sample rate, buffer size, and four selected measurement channels. It is restored only when the setup still matches. Changing the setup invalidates the baseline. DUT measurement is blocked when no valid baseline is available.

The selected audio interface and JUCE device state are also persisted. Latency Bench does not silently adopt the current macOS default device when a previously selected device is unavailable.

#### Levels and external mixer routing

The default digital probe level is **-30 dBFS**. A practical received peak range is roughly **-40 to -20 dBFS**. There is no measurement benefit in operating near clipping.

Analog output levels, input gains, and hardware routing remain under the interface's own control software. With RME TotalMix, the Hardware Input fader is a monitoring/routing control and does not determine the level delivered to Latency Bench through CoreAudio. Avoid routing a measurement input back to its measurement output, because that creates feedback. Software Playback to the selected physical outputs should be routed normally, Hardware Input monitoring to those outputs should be off, and TotalMix Loopback should be off.

#### Analysis

The probe is a deterministic pseudo-random bipolar broadband burst. Latency is estimated with normalized cross-correlation, using absolute correlation magnitude so an inverting DUT can still be measured. A three-point parabolic interpolation around the selected correlation maximum provides the fractional-sample estimate.

The full supported lag range is searched, but correlation is calculated from the known probe-bearing reference window rather than repeatedly scanning the entire capture buffer. This keeps ten-run measurements responsive while preserving the lag search and sub-sample refinement.

The individual run results matter. Strongly nonlinear, time-varying, phase-altering, or internally block-scheduled DUTs can produce lower correlation or more than one strong correlation candidate. Median is therefore the primary summary statistic, while mean, range, standard deviation, correlation, and all ten raw runs remain visible.

Latency Bench also reports the strongest separate local correlation peak. v1.1.1 rejects a run as ambiguous when that separate candidate reaches 90% of the primary lag-selection evidence. The historical `NEAR-EQUAL` diagnostic remains defined at 99%, but valid v1.1.1 runs normally cannot reach it because the 90% validity rule is stricter. The application never forces an expected, earlier, or later candidate.

##### Bandwidth-limited paths

There is no fixed LF, HF, or octave-span requirement. If the normal broadband analysis cannot establish reliable timing, Latency Bench automatically retries the DUT run with a longer probe/window and spectrally matches the reference magnitude to the captured DUT before correlation. The DUT phase is left intact. If a unique timing interpretation still cannot be established, the result is rejected rather than forced.

There is no fixed LF, HF, absolute-bandwidth, or octave-span requirement; measurability is determined from timing evidence. Physical qualification includes a realistic 20–160 Hz subwoofer-style path. At 48 kHz, the same path measured 89.15 samples / 1.857 ms bypassed, 383.20 / 7.983 ms with 24 dB/oct HPF+LPF, and 493.18 / 10.275 ms with 48 dB/oct HPF+LPF. These filtered results represent the timing displacement of the complete transfer function, including filter phase/group-delay behaviour; the added delay must not be interpreted as bare device transport/processing latency.

#### Physical validation

The method has been validated at **48 kHz / 16 samples** using an **RME Babyface Pro** as the measurement interface and a **Neural DSP Quad Cortex** as a real DUT. Direct two-channel loopback calibration produced a 0.00-sample baseline. The Quad Cortex DSP example used for the active-chain validation was:

```text
Jewel Comp -> Analog FX Loop -> Brit 2203 Amp -> Analog Delay -> Brit 412 GB Cab
```

For the four-block active case, the Analog FX Loop was not inserted in the physical path. For the final FX-loop case it was enabled after Jewel Comp, adding the physical D/A -> analog patch cable -> A/D path.

The authoritative four-case reference series includes:

| Quad Cortex configuration | Median latency | Mean | Min...max | Std dev |
| --- | ---: | ---: | ---: | ---: |
| Cable only / no DSP blocks | 89.14 samples / 1.857 ms | 89.14 | 89.14...89.14 | 0.001 samples |
| Four DSP blocks present, all bypassed | 153.14 / 3.190 ms | 153.14 | 153.14...153.14 | 0.001 |
| Four DSP blocks active | 174.69 / 3.639 ms | 175.19 | 174.64...179.76 | 1.524 |
| Four DSP blocks active + analog FX loop | 296.03 / 6.167 ms | 297.53 | 295.94...301.10 | 2.334 |

Using the medians, the observed increments are approximately:

- four bypassed blocks present versus cable-only: **+64.00 samples / +1.333 ms**
- activating the four blocks: **+21.55 samples / +0.449 ms**
- adding the physical D/A -> patch cable -> A/D FX loop: **+121.34 samples / +2.528 ms**

The two more complex active-DSP cases show occasional tightly grouped results roughly five samples above the main cluster. The measurements document that behavior without assigning its cause to either the DUT or the estimator.

For practical operating procedures, see [`docs/MEASUREMENT_GUIDE.md`](docs/MEASUREMENT_GUIDE.md). The complete ten-run reports and exact validation notes are in [`docs/REFERENCE_MEASUREMENTS.md`](docs/REFERENCE_MEASUREMENTS.md). The measurement theory and limitations are in [`docs/MEASUREMENT_METHOD.md`](docs/MEASUREMENT_METHOD.md).

#### Build and verify

JUCE is expected by default at:

```text
../rf-fingerprint/JUCE
```

or can be supplied with `-DJUCE_DIR=/absolute/path/to/JUCE`.

Run:

```bash
./scripts/verify.sh
```

The verification build checks the application bundle, bundle identifier `works.60n.latencybench`, and the required macOS microphone/audio-input usage description.

#### Current status

Version 1.1.1 adds overlap-aware lag-selection evidence, confidence-based rejection of weak or competing timing interpretations, and automatic extended spectrally matched analysis for strongly bandwidth-limited DUTs. The normal broadband path remains unchanged when it already produces reliable timing evidence. Release qualification is tracked in `docs/ROADMAP.md`.

No measurement result should be interpreted more precisely than the DUT and signal permit. In particular, fractional-sample interpolation is useful for repeatability and comparison, but unusual DUT bandwidth, phase response, modulation, or multiple internal processing states can make a single scalar latency an incomplete description.

#### macOS installer package

Build the verified local installer with:

```bash
./scripts/build-pkg.sh
```

The script performs a clean Release verification first and then writes:

```text
Dist/Latency-Bench-1.1.1.pkg
```

The package installs the application at:

```text
/Applications/60°N Signal Works Audio Bench Suite/Latency Bench.app
```

The current package is intended for local/test installation and is not Developer ID signed or notarized. Signing/notarization is a separate release-distribution step if required.


#### Artwork

The application icon and in-app logo use `assets/Latency-Bench-Logo.png`.

# 6. Matrix Bench

Matrix Bench is the suite's low-latency routing, mixing and monitoring environment.


<!-- FIGURE PLACEHOLDER: Figure 6.1
Application: Matrix Bench
Subject: Main routing matrix
Show: Input strips, crosspoint matrix, Main/Aux destinations, meters and information area.
Suggested size: full text width
Caption: Matrix Bench main routing and monitoring view.
-->

**Figure 6.1.** Matrix Bench main routing and monitoring view.


## 6.1 Complete user and architecture reference

**Matrix Bench** is a low-latency macOS audio routing, processing and monitoring tool by **60°N Signal Works**.

Matrix Bench provides an 8-channel virtual Core Audio device, flexible input-to-output matrix routing, independent Main and Aux physical destinations, per-input filtering and polarity control, output compression, MIDI control, snapshots and persistent engine-owned state.

Version **2.1.1** uses a headless architecture: the audio engine runs independently of the graphical application and remains active when the Matrix Bench window is closed.

#### Current status

Matrix Bench 2.1.1 is the current release candidate. Its 2.1.1 state-ownership, snapshot, persistence and CLI changes are being qualified before the production release checkpoint.

The production architecture has been validated with independent headless engine operation, simultaneous Main and Aux routing, virtual Core Audio I/O, physical-device hotplug and recovery, mixed sample-rate physical outputs, persistent routing/mixer/DSP state, SS1-SS4 snapshots, MIDI control and MIDI Learn, snapshot topology transitions, linked Main/Aux output compressors, launchd startup, preferred virtual stereo-pair persistence, latency regression tests, and extended FIFO/SRC/independent-clock stress testing.

The automated test suite currently contains 14 tests.

### Architecture

Matrix Bench 2.1.1 separates the macOS audio runtime from the graphical controller.

```text
macOS applications
       |
       | Core Audio
       v
60°N Audio Matrix HAL device
       |
       v
MatrixBenchEngine
       |
       +---- routing matrix / DSP / MIDI / state
       |
       +---- Main physical output
       |
       +---- Aux physical output

Matrix Bench.app
       |
       | control / state / telemetry IPC
       v
MatrixBenchEngine
```

#### MatrixBenchEngine

`MatrixBenchEngine` is the authoritative runtime owner. It owns physical audio-device I/O, virtual-device audio exchange, input DSP, matrix routing, Main and Aux destination processing, output compression, MIDI input and mapping execution, snapshots, persistent runtime state, physical-device recovery, sample-rate conversion and independent-output clock handling.

The engine runs independently of Matrix Bench.app.

#### Matrix Bench.app

`Matrix Bench.app` is an optional controller and monitor for the engine. The GUI does not own the audio runtime.

Closing the application does not stop the audio path. Reopening the GUI reconnects to the running engine and synchronizes to authoritative engine state.

Control changes are sent to the engine, and runtime state changes, including MIDI-driven changes, are reflected back to the UI.

#### 60°N Audio Matrix virtual device

The included Core Audio HAL driver exposes an **8-input / 8-output virtual audio device** named `60°N Audio Matrix`.

Applications can use it like a normal Core Audio device. The virtual device is part of the Matrix Bench architecture and does not require BlackHole or a macOS Multi-Output Device for Matrix Bench's internal routing.

The HAL device exposes the Matrix Bench device icon through the standard Core Audio device-icon property.

### Signal flow

The audio engine uses a single coherent routing architecture for Main and Aux.

```text
Physical / virtual input
        |
        v
Raw input meter
        |
        v
Per-input processing
  - gain / mute
  - polarity invert
  - HPF
  - LPF
        |
        v
Crosspoint routing matrix
        |
        +-----------------------+
        |                       |
        v                       v
      Main                     Aux
        |                       |
        v                       v
Linked stereo compressor Linked stereo compressor
        |                       |
        v                       v
Destination gain / mute   Destination gain / mute
        |                       |
        v                       v
Final master level        Final master level
   (-inf ... 0 dB)           (-inf ... 0 dB)
        |                       |
        v                       v
Output metering           Output metering
        |                       |
        v                       v
Physical Main output      Physical Aux output
```

Main and Aux are first-class independent matrix destinations. An input can be routed to Main, Aux, both, or neither, with independent crosspoint gain for each destination.

The compressor is post-matrix processing and runs before the destination gain/mute stage. Main and Aux each have their own independent linked compressor. Version 2.1.0 added an independent final Main/Aux master attenuation stage after compressor and destination gain/mute, immediately before output metering and physical output. Each master ranges from exact digital silence (-inf dB / 0x) to unity (0 dB / 1x) and adds no buffering or lookahead. Output peak and clip metering occurs after the final master stage.

Gain-reduction metering is telemetry only and does not form part of the audio signal path.

### Controls, mouse and keyboard shortcuts

Matrix Bench uses direct clicks for the common routing and mute operations, with modifier clicks and context menus for secondary functions.

#### Inputs

- Click the input **M** control to toggle mute.
- Right-click an input label to open its context menu.
- The input context menu provides mute, polarity inversion, input gain presets, HPF and LPF configuration.
- HPF and LPF frequency and slope selections are available directly from their context submenus.
- MIDI Learn/Clear is available separately for input gain, mute, polarity, HPF enable and LPF enable.

#### Main and Aux outputs

- Click the output **M** control to toggle mute.
- Right-click an output header to open its context menu.
- The output context menu provides mute, gain presets at 0, -3, -6, -12, -20, -40, +3, +6 and +12 dB, and MIDI Learn/Clear for output gain and mute.

The same interaction model applies to Main and Aux outputs.

Main and Aux also have independent horizontal final master controls. These are attenuation-only controls from -inf dB to 0 dB and operate after the compressor and destination gain/mute stages. Option-click the master scale area to start MIDI Learn without changing the fader value.

#### Matrix crosspoints

- Click a crosspoint to operate its route.
- Right-click a crosspoint to open its context menu.
- The crosspoint context menu provides gain presets at 0, -3, -6, -12, -20, -40, +3, +6 and +12 dB.
- MIDI Learn/Clear is available separately for **Crosspoint gain** and **Route on/off**.

Main and Aux crosspoints use the same interaction model.

#### Snapshots

- Click **SS1-SS4** to recall a snapshot.
- Shift-click **SS1-SS4** to save/capture the current state to that snapshot.
- Option-click **SS1-SS4** to start MIDI Learn for snapshot recall.
- Right-click **SS1-SS4** to rename the snapshot.

#### Compressor controls

Double-click an individual compressor control to reset that parameter to its default value.

#### MIDI Learn

Press **Esc** to cancel an active MIDI Learn operation.

### Routing matrix

The matrix provides independent crosspoints from each input to Main and Aux.

Each crosspoint supports route enable/disable, independent gain and MIDI Learn/Clear.

Main and Aux destination controls operate consistently and independently.

The routing topology is retained even when a configured physical output temporarily disappears. A missing endpoint is treated as unavailable hardware rather than as a reason to destroy the logical routing configuration.

Main and Aux crosspoint routing is destination-device scoped. Each destination remembers its own routing bank, so changing a physical output does not reinterpret the previous device's channel indexes as routes for the newly selected device. Returning to a previously used destination restores that destination's remembered crosspoints. Main and Aux keep independent banks.

### Input processing

Each input provides gain, mute, polarity inversion, high-pass filter, low-pass filter and input metering.

HPF and LPF slopes support 6 dB/oct, 12 dB/oct and 24 dB/oct.

Input meters represent the raw input before the normal per-input processing chain.

### Main and Aux output processing

Main and Aux each provide independent matrix routing, destination gain, mute, linked stereo compression, final master attenuation, output metering and independent physical-device selection.

The two destinations may use separate physical devices and separate clock domains.

Temporary loss of one physical destination does not stop the other destination.

### Output compressors

Main and Aux each have an independent bypassable linked stereo master compressor.

Controls are threshold, ratio, attack, release and makeup gain.

Compressor characteristics:

- fixed 6 dB soft knee;
- zero lookahead;
- stereo-linked gain reduction.

Default settings:

```text
Threshold   -12 dB
Ratio        2:1
Attack       20 ms
Release      200 ms
Makeup        0 dB
```

Detailed compressor controls are located in the Options window so that the main matrix view remains compact.

Double-clicking an individual compressor control resets that control to its default value.

Parameter changes are coalesced during dragging at approximately 60 Hz, followed by an exact final update when the gesture ends. Authoritative engine updates do not fight an actively manipulated control.

#### Gain-reduction display

Main and Aux have compact amber/yellow gain-reduction meters.

The display uses conventional downward gain-reduction indication with a negative dB scale and numeric readout.

Display-only smoothing is 5 ms attack and 250 ms release. The bar and numeric readout use the same smoothed display value.

These UI ballistics do not alter compressor DSP behavior or raw gain-reduction telemetry.

### Physical-device handling

Matrix Bench separates logical routing topology from physical endpoint availability.

Validated behavior includes:

- Main and Aux using different physical devices;
- device hotplug;
- automatic recovery after a configured device returns;
- preservation of configured device identity;
- preservation of matrix topology while an endpoint is unavailable;
- continued operation of one destination when the other disappears;
- rejection of feedback-prone selection of the `60°N Audio Matrix` virtual device as a physical output endpoint.

The primary JUCE `AudioDeviceManager` path is input-only. Main and Aux physical outputs are explicitly owned and managed by the engine.

### Independent output clocks and sample-rate conversion

Main and Aux physical devices can operate in clock domains that are independent of the engine and of each other.

The physical-output bridge provides asynchronous buffering, sample-rate conversion, bounded FIFO operation and rate-servo correction for clock drift.

Live mixed-rate configurations have been validated, including 44.1 kHz engine/Main with a 48 kHz Aux endpoint, 48 kHz engine with 44.1 kHz physical outputs, simultaneous Main and Aux output, and 16-sample engine-buffer operation.

Deterministic stress coverage also exercises mismatched and continuously varying producer/consumer block sizes.

### Virtual stereo-pair preference

The virtual Core Audio device remains fully available as eight channels.

Its standard preferred-stereo-channel property can be set independently to 1-2, 3-4, 5-6 or 7-8.

The headless engine owns and persists this configuration, so Matrix Bench.app does not need to be opened to configure it.

```bash
matrixbenchctl stereo-pair 1-2
matrixbenchctl stereo-pair 3-4
matrixbenchctl stereo-pair 5-6
matrixbenchctl stereo-pair 7-8
```

Current engine state can be inspected with:

```bash
matrixbenchctl status
```

The configured stereo pair is reapplied when the engine starts.

### Snapshots

Matrix Bench provides four snapshots: SS1, SS2, SS3 and SS4.

Snapshots restore the relevant engine-owned routing, mixer, device and DSP state. Snapshot names are editable, and snapshots can be recalled through MIDI Learn.

#### Atomic topology transitions

Topology-changing snapshot recall uses a silence-held transaction.

The current audio state fades fully to silence before physical topology changes begin. Silence remains held while input devices, Main and Aux devices, topology, routing and processing state are restored and validated.

The silence hold is released only after the complete recalled state is installed, after which normal ramp-up begins.

This avoids exposing intermediate routing/device states to the audible output.

### Persistence

Runtime state is owned and persisted by the headless engine.

Persistent state includes the applicable physical-device selections, virtual preferred stereo pair, routing, crosspoint gains, Main and Aux destination state, input processing, compressor settings, MIDI input selection, MIDI channel selection, MIDI mappings and current live state.

SS1-SS4 snapshot state is stored separately as snapshot state rather than replacing normal live-state persistence.

### MIDI

Matrix Bench provides engine-owned MIDI control with persistent MIDI Learn mappings.

Supported MIDI configuration includes MIDI input-device selection, Omni mode, channel 1-16 filtering and persistent mapping state.

MIDI Learn/Clear is available for input gain, input mute, polarity, HPF enable, LPF enable, Main/Aux destination gain and mute, Main/Aux final master level, Main/Aux compressor enable, Main/Aux crosspoint gain and route enable, and SS1-SS4 recall.

A single CC may control more than one mapped target.

Input, destination and crosspoint gains use the same fixed gain steps as the UI. The 7-bit CC ranges are: `0-7 = -40 dB`, `8-23 = -20 dB`, `24-39 = -12 dB`, `40-55 = -6 dB`, `56-71 = -3 dB`, `72-87 = 0 dB`, `88-103 = +3 dB`, `104-119 = +6 dB`, and `120-127 = +12 dB`. Main/Aux final master controls instead use their continuous attenuation law, with CC 0 at exact silence and CC 127 at 0 dB/unity.

For switch-like controls, values 0-63 are off and 64-127 are on.

MIDI-driven state changes are executed by the engine and propagated back to the GUI.

MIDI endpoint inventory is engine-owned and refreshed for endpoint changes/hotplug. The GUI populates MIDI devices from the authoritative initial runtime snapshot and resynchronizes automatically if it is opened before the engine IPC endpoint is ready. Learned master and compressor-enable mappings remain active with the GUI closed and persist across engine restarts.

### Headless service

On macOS the engine runs as a per-user launchd service.

LaunchAgent label: `works.60n.matrixbench.engine`

LaunchAgent:

```text
~/Library/LaunchAgents/works.60n.matrixbench.engine.plist
```

Per-user runtime directory:

```text
~/Library/Application Support/60N Signal Works/Matrix Bench/
```

The directory contains `MatrixBenchEngine` and `matrixbenchctl`.

The engine IPC socket is:

```text
/tmp/works.60n.matrixbench.engine.sock
```

The service is independent of Matrix Bench.app.

### Installation

The macOS installer installs:

```text
/Applications/60°N Signal Works Audio Bench Suite/Matrix Bench.app
```

HAL driver:

```text
/Library/Audio/Plug-Ins/HAL/60N Audio Matrix.driver
```

Canonical engine and control-tool copies:

```text
/Library/Application Support/60N Signal Works/Matrix Bench/
```

The installer provisions the corresponding per-user runtime files and LaunchAgent for the logged-in console user.

Launchd setup uses `enable`, `bootstrap`, then `kickstart`, in that order, so a persistent launchd disabled override can be recovered during installation.

The installer does not kill, restart or otherwise control `coreaudiod`.

The HAL driver is discovered through normal macOS Core Audio lifecycle behavior.

The current installer package is unsigned.

### Build and test

Matrix Bench is implemented in C++ using JUCE and CMake.

For the current release-validation build:

```bash
cmake --build build-release-check -j
ctest --test-dir build-release-check --output-on-failure
```

The current 2.1.1 development baseline passes all 14 automated tests; final 2.1.1 release qualification is performed before packaging and the Git release checkpoint.

### macOS package

The package builder is `packaging/build-macos-pkg.sh`.

Example:

```bash
packaging/build-macos-pkg.sh build-release-check 2.1.1 "$PWD/Dist"
```

Result:

```text
Dist/Matrix-Bench-2.1.1.pkg
```

The package is built as a non-relocatable application installation so reinstall/upgrade behavior restores the canonical application path rather than following stale macOS relocation metadata.

The completed HAL driver bundle is ad-hoc re-signed after bundle assembly so its `Info.plist` and `Contents/Resources` are included in the code-signing seal. The Release and installed HAL bundles pass `codesign --verify --deep --strict`.

The final 2.1.1 package has passed a complete package-only clean installation after removal of the existing Matrix Bench application, HAL driver, headless runtime and LaunchAgent. The virtual HAL device, engine, controller utility and GUI reinstalled and operated without manual repair or post-install signing. The installed app and HAL report version 2.1.1, and the installed HAL passes strict code-signature verification.

### Latency

Several latency quantities are intentionally treated separately.

#### Application processing path

Deterministic impulse regression shows that the steady-state direct Matrix engine processing path adds **0 samples** of additional application-level block latency.

This has been verified at callback sizes 16, 32, 64, 128, 256 and 512 samples.

#### Independent physical-output bridge

The independent output bridge intentionally maintains a 1024-source-frame startup reservoir.

Approximate reservoir duration:

```text
44.1 kHz   23.220 ms
48 kHz     21.333 ms
```

#### HAL/device path

Live same-client persistent-I/O validation covers **16, 32, 64, 128, 256 and 512-frame** Core Audio quanta. For every validated quantum, the actual IOProc callback size matches the requested quantum and virtual-device loopback displacement is exactly **2 x the active client quantum**.

The real-time HAL path follows the `ioBufferFrameSize` supplied to `DoIOOperation()`. A process-local driver variable observed from another process must not be used to infer a Core Audio client's active callback quantum.

The HAL advertises zero additional HAL latency and safety offset.

For the 2.1.0 release candidate, the persistent virtual-HAL regression was repeated after addition of the final master stages. Two complete 48 kHz sweeps passed at 16, 32, 64, 128, 256 and 512 frames, with callback quantum matching the requested quantum, correlation 1.0 and loopback displacement remaining exactly 2 x quantum. Two Babyface physical regression spot checks also produced valid paired-marker results at 145.850 frames / 3.039 ms and 152.574 frames / 3.179 ms. Those physical spot checks reported 512-frame Core Audio properties and are retained only as regression checks; they do not replace the authoritative documented 2.0.1 physical 16-512 sweep.

For the final 2.1.1 qualification, the complete Babyface 48 kHz physical sweep was repeated at all six Matrix Bench quanta, producing median round-trip results of 147.908, 172.934, 315.020, 492.592, 949.968 and 1944.856 frames respectively. Persistent virtual-HAL validation passed two complete 16-512 sweeps during qualification and two further complete sweeps against the package-installed final HAL; every point retained exact callback-quantum agreement, correlation 1.0 and displacement exactly 2 x quantum.

These values describe different parts of the system and should not be treated as though they represented the same measurement point.

Repeatable virtual-HAL and physical-I/O procedures, PASS criteria, commands and interpretation are documented in [`docs/LATENCY_TESTING.md`](docs/LATENCY_TESTING.md). Completed reference measurements cover both the virtual HAL path and the physical round-trip path at 48 kHz across 16, 32, 64, 128, 256 and 512-sample Matrix Bench quanta.

### Validation

Matrix Bench has been exercised with, among others:

- RME Babyface Pro;
- Neural DSP Quad Cortex;
- JBL Bluetooth audio;
- the built-in `60°N Audio Matrix` virtual device.

Validation has included direct routing, simultaneous Main/Aux routing, independent device clocks, sample-rate conversion, 16-sample engine buffers, hotplug and endpoint recovery, persistent state, MIDI control, snapshot recall, topology-changing snapshot recall, linked output compression, cold-start launchd operation, package reinstall, Core Audio health checks, and long-running/high-volume FIFO/SRC stress tests.

One automated stress group processes 15,000,000 source frames across fixed, mismatched and continuously varying producer/consumer block-size scenarios while checking exact per-channel sequence integrity and bounded FIFO behavior.

### Design principles

Matrix Bench is intentionally functionality-first.

The priorities are deterministic behavior, low latency, explicit routing, visible state, recoverable device handling, headless operation, minimal hidden magic, straightforward controls, reliable persistence and testable audio behavior.

The GUI is deliberately a controller for the underlying engine rather than the architectural center of the application.

### Project documentation

Detailed engineering history, completed sprint work, validation notes and roadmap closure are retained in `docs/ROADMAP.md`.

That document contains development chronology. This README describes the current Matrix Bench 2.1.1 architecture and behavior.

### Version

**Matrix Bench 2.1.1**

60°N Signal Works

<!-- FIGURE PLACEHOLDER: Figure 6.2
Application: Matrix Bench / Audio MIDI Setup
Subject: Virtual-device configuration
Show: The 60°N Audio Matrix virtual device and representative channel configuration.
Suggested size: full text width
Caption: Matrix Bench virtual Core Audio device configuration on macOS.
-->

**Figure 6.2.** Matrix Bench virtual Core Audio device configuration on macOS.


## 6.2 Latency and HAL validation

This document defines the repeatable latency validation procedures for both the
`60°N Audio Matrix` virtual Core Audio HAL device and real physical audio I/O.

The two measurements are deliberately separate. A virtual HAL loopback result
must not be interpreted as physical converter/driver round-trip latency, and a
physical round-trip result contains hardware/driver contributions outside the
Matrix Bench processing path.

#### 1. Virtual HAL persistent-I/O latency

##### Purpose

Verify the real Core Audio `AudioDeviceIOProc` path at the active client quantum,
without relying on the driver's process-local `gBufferFrameSize` as evidence of
the client callback size.

The important property of this test is lifetime: the same Core Audio client
sets the quantum, creates and starts its IOProc, observes the actual callback
frame count, measures loopback displacement, and only then destroys that I/O
context.

##### Build

```bash
cd ~/Projects/audio-matrix
cmake --build build-hal --target MeasureHalPersistentIOLatency -j6
```

##### Run

```bash
./build-hal/MeasureHalPersistentIOLatency 3
```

The argument is the measurement duration in seconds per quantum.

##### Required coverage

The regression sweep is:

```text
16 32 64 128 256 512 frames
```

For every quantum `Q`, PASS requires:

- setting `kAudioDevicePropertyBufferFrameSize` succeeds;
- reading the property immediately after the set returns `Q`;
- actual IOProc callbacks are `Q` frames (`callback_min == callback_max == Q`);
- the property remains `Q` while that same IOProc is running;
- generated and captured streams correlate cleanly;
- measured virtual loopback displacement is exactly `2 * Q` samples.

At 48 kHz the validated reference values are:

| Quantum | Callback | Displacement | Latency |
| ---: | ---: | ---: | ---: |
| 16 | 16 | 32 samples | 0.666667 ms |
| 32 | 32 | 64 samples | 1.333333 ms |
| 64 | 64 | 128 samples | 2.666667 ms |
| 128 | 128 | 256 samples | 5.333333 ms |
| 256 | 256 | 512 samples | 10.666667 ms |
| 512 | 512 | 1024 samples | 21.333333 ms |

Reference validation on 2026-09-11 produced correlation `1.000000000` at every
quantum and `summary=PASS failures=0`.

##### Interpretation

The production real-time HAL path uses the `ioBufferFrameSize` supplied to
`DoIOOperation()`. Live same-client testing proves that Core Audio can run the
device with 16...512-frame callbacks even when a process-local diagnostic view
of driver state is not a reliable representation of another Core Audio
client's active quantum.

Therefore, do not infer real I/O callback size or latency from a separate
process observing a process-local `gBufferFrameSize`.

The HAL advertises zero additional HAL latency and zero safety offset. The
measured virtual-device displacement is nevertheless `2 * Q`; that measured
transport displacement and the advertised HAL latency properties are different
quantities.

##### Regression rule

`MeasureHalPersistentIOLatency` is retained as the authoritative live virtual
HAL latency regression. Any change to HAL buffering, timestamps, I/O lifecycle,
ring transport, or buffer-size handling must rerun this sweep.

#### 2. Physical I/O round-trip testing

**Validation status:** completed at 48 kHz on 2026-09-11 using an RME Babyface Pro and a physical output-to-input cable loopback. The previously saved setup-only output was not a latency result and is intentionally not retained.

##### Purpose

Measure the complete live path involving Matrix Bench and a real Core Audio
device. This validates behavior that cannot be established by the virtual HAL
test alone: physical driver buffering, hardware I/O, converter latency and the
actual external loopback path.

##### Hardware setup

Use a real physical interface and a cable loopback appropriate for its
line-level I/O. Keep levels conservative and disable processing in the physical
interface/mixer that would alter timing or the marker signal.

The virtual Matrix device and the physical Main path must run at the same sample
rate. The measurement utility intentionally refuses mismatched rates.

##### List devices

```bash
cd ~/Projects/audio-matrix
cmake --build build-hal --target MeasurePhysicalRoundtrip -j6
./build-hal/MeasurePhysicalRoundtrip --list
```

##### Run

```bash
./build-hal/MeasurePhysicalRoundtrip "<physical-device-name-substring>" <input-channel-1based> <seconds>
```

Example shape only:

```bash
./build-hal/MeasurePhysicalRoundtrip "Babyface" 1 5
```

Choose the input channel that receives the physical cable loopback.

The tool reports, among other fields:

- virtual output device;
- selected physical input;
- physical input channel;
- sample rate;
- virtual Core Audio frame size;
- physical Core Audio frame size;
- receive peak;
- transmitted marker count;
- received marker count;
- measured marker timing/displacement statistics when sufficient markers are captured.

##### Buffer sweep

Physical validation should be repeated at each supported/target buffer size,
especially:

```text
16 32 64 128 256 512 frames
```

Record the Matrix Bench quantum used for every run and how it was confirmed.
For the reference sweep below, the active quantum was changed manually and
confirmed in the running Matrix Bench UI. Separate Core Audio frame-size
property readbacks from the measurement process are not authoritative for the
active Matrix Bench client quantum.

##### Recorded 48 kHz reference sweep

The Matrix Bench buffer quantum was changed manually in the running UI and
confirmed in the application info display before each measurement.

| Matrix Bench quantum | Median physical round-trip |
| ---: | ---: |
| 16 | 147.512-151.952 frames / 3.073-3.166 ms across three valid runs |
| 32 | 163.166 frames / 3.399 ms |
| 64 | 263.872 frames / 5.497 ms |
| 128 | 457.538 frames / 9.532 ms |
| 256 | 1035.586 frames / 21.575 ms |
| 512 | 1839.860 frames / 38.330 ms |

All recorded sweep points produced a valid physical return signal and eight
paired marker events. Full results and test-path details are retained in
`latency-results/physical-48k-20260911-final.txt`.

The Core Audio frame-size properties observed by the physical measurement
process remained at 512 frames during the sweep. Those separate property
readbacks are not used as evidence of the active Matrix Bench client quantum.
The persistent same-client HAL test in section 1 independently verifies the
actual IOProc callback quantum.

##### PASS criteria

A physical run is valid only when:

- the intended physical device and loopback channel are unambiguous;
- virtual and physical Main-path sample rates match;
- the requested/effective buffer configuration is recorded;
- transmitted markers are observed at the physical input;
- the receive level is safely above the detection floor and not clipping;
- enough markers are captured for a stable result;
- repeated measurements are consistent within the expected hardware/driver
  variation.

Physical latency is not expected to equal the virtual HAL `2 * Q` result.
It includes physical Core Audio driver buffering and hardware converter/path
latency. Compare physical results only with runs using the same documented
hardware topology and rate/buffer configuration unless the comparison is
explicitly intended to measure those differences.

##### Saving results

Keep significant physical validation runs under:

```text
latency-results/
```

Use filenames containing the path/rate/date where practical. The result file
must contain enough setup information to reproduce the measurement.

#### 3. Application processing regression

The direct steady-state Matrix engine processing path is separately tested by
`ApplicationPathLatencyTests`. It verifies zero additional application-level
block displacement for the covered callback sizes.

This is a third measurement point and must not be substituted for either the
live virtual HAL test or the physical round-trip test.

#### 4. Pre-release latency validation

Before a release that changes audio transport or device handling:

```bash
cd ~/Projects/audio-matrix
cmake --build build-hal -j6
ctest --test-dir build-hal --output-on-failure
./build-hal/MeasureHalPersistentIOLatency 3
```

Then perform the documented physical round-trip sweep on the release validation
hardware and save the significant results in `latency-results/`.

Automated/unit tests can protect deterministic code behavior. Live HAL and
physical-device measurements remain required for claims about the actual Core
Audio and hardware paths.

#### 5. Matrix Bench 2.1.0 release regression (2026-09-12)

The 2.1.0 final Main/Aux master stages are sample-wise attenuation with de-click ramping. They add no buffering, lookahead or additional audio callback stage.

After the 2.1.0 audio-path changes, the persistent virtual-HAL test completed two full 48 kHz sweeps at 16, 32, 64, 128, 256 and 512 frames. Both sweeps passed with observed callback quantum equal to the requested quantum, correlation 1.0 and loopback displacement exactly `2 * Q` at every point.

Two additional RME Babyface physical-path spot checks produced valid return signals and eight paired marker events each:

| Spot check | Median frames | Median ms | MAD ms |
| ---: | ---: | ---: | ---: |
| 1 | 145.850 | 3.038542 | 0.030125 |
| 2 | 152.574 | 3.178625 | 0.020125 |

The physical tool reported both virtual and physical Core Audio frame-size properties as 512 during these spot checks. These measurements therefore confirm that the 2.1.0 physical path remains consistent with the established Babyface round-trip baseline, but they are not a new authoritative 16-frame property-state measurement and do not replace the complete 2.0.1 physical sweep documented above.

#### 6. Matrix Bench 2.1.1 final qualification (2026-09-13)

The 2.1.1 release qualification repeated the complete RME Babyface physical round-trip sweep at 48 kHz. The physical loopback was Analog Out 1 to Analog In 1, with the Matrix path routed to Babyface Analog Out 1. Every point produced eight paired marker events with a stable return signal.

| Matrix Bench quantum | Median frames | Median ms |
| ---: | ---: | ---: |
| 16 | 147.908 | 3.081 |
| 32 | 172.934 | 3.603 |
| 64 | 315.020 | 6.563 |
| 128 | 492.592 | 10.262 |
| 256 | 949.968 | 19.791 |
| 512 | 1944.856 | 40.518 |

As in the established physical procedure, the measurement process reported 512-frame Core Audio properties while the running Matrix Bench engine was independently confirmed at each effective 16-512 quantum. These cross-process property values are not used to infer the active Matrix Bench callback size.

The persistent virtual-HAL test also completed two full 48 kHz 16-512 sweeps during 2.1.1 qualification. After the final package-only clean installation, two additional complete sweeps were run against the installed HAL. All four sweeps passed at 16, 32, 64, 128, 256 and 512 frames with requested/property/callback quantum agreement, correlation 1.0 and virtual loopback displacement exactly `2 * Q`.

The final package-installed HAL passed strict `codesign --verify --deep --strict` verification. Mixed-rate 44.1 kHz / 48 kHz output switching and recovery also passed manual audible validation.

# 7. MIDI Bench

MIDI Bench is a focused MIDI monitor, sender and deterministic command-file sequencer.


<!-- FIGURE PLACEHOLDER: Figure 7.1
Application: MIDI Bench
Subject: Main MIDI monitor/sender window
Show: MIDI IN/OUT selectors, channel control, Incoming/Outgoing monitors and send controls.
Suggested size: full text width
Caption: MIDI Bench monitoring and sending MIDI messages.
-->

**Figure 7.1.** MIDI Bench monitoring and sending MIDI messages.


## 7.1 Complete user reference

60°N Signal Works

MIDI Bench is a compact MIDI I/O utility built with C++, JUCE and CMake.

The current macOS standalone implementation provides MIDI monitoring, filtering,
deterministic MIDI transmission, hotplug/reconnect handling and persistent
device/control state.

#### MIDI Bench 2.0.0

macOS release focused on a clearer bidirectional MIDI workflow:

- separate side-by-side MIDI IN and MIDI OUT monitor panes
- incoming and outgoing events are logged to their respective panes
- IN and OUT events use a common monotonic timestamp origin for direct timing comparison
- restrained terminal-style monitor palette: charcoal background, green MIDI IN and cyan MIDI OUT
- monitor controls grouped more tightly with the input channel controls
- reduced minimum window width while retaining rational spacing around the send controls
- `.mbmidi` command-file runner with strict validation, WAIT/LOOP, Browse/Edit/Run/Stop and persisted file selection
- command files support CC, PC, Note On/Off, Pitch Bend, Channel Pressure and Polyphonic Aftertouch

#### Current validated state

##### MIDI IN

- MIDI input device selector
- Omni / Ch 1-16 filtering
- bounded 1024-event callback queue
- UI drain at 20 Hz
- decoded:
  - Control Change
  - Program Change
  - Note On
  - Note Off
- bounded MIDI IN monitor display
- Clear button
- MIDI device hotplug/reconnect
- configured device identity retained while temporarily unavailable

##### Monitor controls

- Pause freezes visible monitor updates
- the bounded MIDI callback queue continues to be drained while paused
- resume displays new events only, without dumping stale paused traffic
- Auto-scroll can be enabled or disabled independently
- Auto-scroll state persists across application runs
- optional raw MIDI byte display
- Raw bytes state persists across application runs
- Pause intentionally does not persist

##### MIDI OUT

- separate bounded MIDI OUT monitor with comparable timestamps
- outgoing GUI sends are logged in the MIDI OUT pane
- MIDI output device selector
- output channel selector
- Control Change send:
  - controller number 0-127
  - value 0-127
- Program Change send:
  - program 0-127
- MIDI output hotplug/reconnect
- configured device identity retained while temporarily unavailable

##### MIDI IN / MIDI OUT monitors

MIDI Bench 2.0.0 uses separate side-by-side MIDI IN and MIDI OUT monitors.
Incoming events are written only to MIDI IN; manual and command-file sends are
written to MIDI OUT. Both monitors use the same monotonic timestamp origin, so
send/receive timing can be compared directly. The monitor panes use a
terminal-style dark palette with distinct IN and OUT text colours.

Pause, Auto-scroll and Raw bytes apply to monitoring as provided by the UI.
The minimum window width is reduced while retaining the full sender controls.

##### MIDI command files

MIDI Bench can load and run UTF-8 `.mbmidi` command files. The first non-empty,
non-comment line must be `MIDI-BENCH-FILE 1.0`.

Commands are one per line. Blank lines and `#` comments are allowed.

```text
MIDI-BENCH-FILE 1.0

CH 1 CC 12 VAL 67
CH 3 PC 4
CH 2 NOTE 60 VEL 100 ON
WAIT 250
CH 2 NOTE 60 OFF
CH 4 BEND -1200
CH 5 PRESSURE 72
CH 6 POLYAT 60 VAL 80
WAIT 500
LOOP
```

Supported grammar:

- `CH <1..16> CC <0..127> VAL <0..127>`
- `CH <1..16> PC <0..127>`
- `CH <1..16> NOTE <0..127> VEL <0..127> ON`
- `CH <1..16> NOTE <0..127> OFF`
- `CH <1..16> BEND <-8192..8191>`
- `CH <1..16> PRESSURE <0..127>`
- `CH <1..16> POLYAT <0..127> VAL <0..127>`
- `WAIT <0..3600000>` milliseconds
- `LOOP` as the final command

The command-file controls are Browse, Edit, Run, Stop and Syntax. Browse selects
a `.mbmidi` file and remembers the last successfully selected file/location.
Edit opens that file explicitly in macOS TextEdit, so no `.mbmidi` file
association is required. Syntax shows the compact command reference.

Run always reloads and validates the file from disk immediately before
execution, so edits saved in TextEdit are used without a separate Reload step.
After a failed validation, Run remains available while the selected file still
exists, allowing Edit -> fix -> save -> Run without browsing again.

The whole file is validated when selected and revalidated from disk before every
Run. MIDI Bench rejects the wrong extension, wrong/missing header, malformed commands, out-of-range values,
commands after `LOOP`, and files larger than 1 MiB. A rejected file shows a
compact `Invalid file (line N)` status and a detailed line-numbered diagnostic.
Stop interrupts WAIT and LOOP execution immediately. Every Run starts at the
beginning of the file; after Stop, a new Run does not resume from the previous
position. `LOOP` must be the final command and restarts execution from the
beginning until Stop is pressed.

File-generated MIDI uses the selected MIDI OUT device and appears in the MIDI
OUT monitor with the same timestamp basis as manual sends and MIDI IN. The
Syntax button shows the compact command reference.

##### Persistence

The application restores rational user-selected operational state across runs:

- MIDI input device
- MIDI input Omni/channel selection
- MIDI output device
- MIDI output channel
- CC number
- CC value
- Program Change number
- last successfully selected `.mbmidi` command file

##### Test utility

`MidiBenchSendMidiTest` provides deterministic programmatic MIDI transmission
for external and loopback validation.

Supported modes include:

- MIDI output enumeration
- explicit CC send
- explicit Program Change send
- deterministic smoke sequence

The smoke sequence is:

- Ch 1, CC 7 = 23
- Ch 1, Program Change 17
- Ch 1, CC 7 = 99

The helper is intentionally not registered as a CTest because it sends real
MIDI to an external destination.

##### Validation

Validated on macOS using CoreMIDI, including IAC loopback:

- MIDI input monitoring, including channel voice plus MIDI Clock, Start/Continue/Stop, Song Position Pointer and SysEx display
- deterministic MIDI sender -> IAC -> MIDI Bench input
- GUI CC send -> IAC -> MIDI Bench input
- GUI Program Change send -> IAC -> MIDI Bench input
- `.mbmidi` command-file sends -> IAC -> MIDI Bench input
- command-file WAIT, LOOP, Stop and restart-from-beginning behavior
- command-file invalid-content rejection and edit/revalidation recovery
- persistence across quit/reopen
- MIDI device unplug/replug and automatic reconnect
- automated tests

#### Branding

The application uses the 60°N Signal Works Bench-style visual treatment.

`resources/midi-bench-icon.png` is the canonical MIDI Bench graphic and is used
both as the application icon and as the in-app logo.

#### Build

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
```

#### Deterministic MIDI sender

List available outputs:

```sh
build/MidiBenchSendMidiTest_artefacts/Release/MidiBenchSendMidiTest --list
```

Run the smoke sequence:

```sh
build/MidiBenchSendMidiTest_artefacts/Release/MidiBenchSendMidiTest \
  --device "IAC Driver Bus 1" \
  --smoke
```


#### Current MIDI support

MIDI Bench currently supports monitoring and sending the common MIDI 1.0 channel-voice messages:

- Note On / Note Off
- Control Change
- Program Change
- Pitch Bend
- Channel Pressure
- Polyphonic Aftertouch

The monitor also supports:

- MIDI input device selection
- Omni or channel 1-16 filtering
- Pause
- Auto-scroll
- Optional raw MIDI byte display
- Hotplug/reconnect while retaining configured device identity
- Persistent rational user-selected settings

MIDI OUT supports persistent output device/channel selection and persistent values for the available send controls.

- User-selected MIDI input/output devices, channels, monitor options and MIDI OUT values persist across application restarts.

- macOS 2.0.0 distribution is provided as a graphical `.pkg` installer. The package upgrades MIDI Bench in `/Applications`.

#### Testing

- Sustained mixed MIDI traffic validated at 250 messages/second for 10 minutes (150000 messages total); the monitor remains responsive by batching event-view updates.
- Generic stress CC traffic uses CC11 Expression rather than semantically special controllers such as Bank Select CC0/32.

<!-- FIGURE PLACEHOLDER: Figure 7.2
Application: MIDI Bench
Subject: Run from file workflow
Show: Browse, Edit, Run, Stop and Loop controls together with a short valid command file.
Suggested size: full text width
Caption: A repeatable MIDI command-file measurement workflow.
-->

**Figure 7.2.** A repeatable MIDI command-file measurement workflow.


# 8. Cross-Bench measurement workflows

## 8.1 Characterizing an audio DUT

A general workflow is to generate a defined stimulus with Signal Bench, inspect level/frequency/distortion behavior with Spectral Bench, measure timing with Latency Bench when required, use MIDI Bench for repeatable control-state changes, and use Matrix Bench where routing or monitoring needs to be more elaborate.

## 8.2 Filtered and crossover outputs

Establish a bypass/reference state where possible. Then measure the filtered state. A large timing change after a steep crossover does not automatically mean the device acquired the same amount of additional transport latency: complete-response timing includes filter phase/group-delay behavior.

Latency Bench can automatically use extended spectrally matched analysis when ordinary broadband analysis cannot establish reliable timing. If evidence remains insufficient or competing timing peaks are too strong, rejection is the correct outcome.

## 8.3 Spectrum and distortion workflow

Use a defined Signal Bench stimulus, verify headroom, then choose the matching Spectral Bench measurement mode. Preserve the exact stimulus and measurement definition with the saved result.

## 8.4 MIDI-controlled repeatability

When comparing DUT states controlled over MIDI, use MIDI Bench to make the state transition deterministic. Save the command sequence and settling delay with the measurement notes.


<!-- FIGURE PLACEHOLDER: Figure 8.1
Application: Audio Bench Suite
Subject: Example multi-Bench workflow
Show: A manually prepared screenshot collage or routing diagram showing generator, DUT, analyzer/latency path and optional MIDI control.
Suggested size: full text width
Caption: Example of a repeatable multi-Bench DUT measurement workflow.
-->

**Figure 8.1.** Example of a repeatable multi-Bench DUT measurement workflow.


# 9. Validation and qualification philosophy

## 9.1 Synthetic tests versus physical qualification

Automated tests are useful for known mathematical cases, regressions and boundary behavior. Physical tests are required where operating-system audio stacks, interfaces, independent clocks, analog paths or real DUT transfer functions can expose behavior that a synthetic model does not reproduce. The strongest qualification combines both.

## 9.2 Reference paths and loopbacks

A known-good cable or loopback establishes a reference state. Repeating it after a difficult test helps detect accidental routing or configuration changes.

## 9.3 Repetition and statistics

Repeatability is evidence, but repeatability alone does not prove correctness. Combine repeated-run statistics with a known reference, an independent method, a predictable parameter change or a synthetic case with a known answer.

## 9.4 Validation coverage in the suite

Matrix Bench documents virtual-HAL persistent-I/O, physical round-trip and application-path latency validation. Spectral Bench documents amplitude, FFT/window, THD/THD+N, IMD, sweep/phase and export validation. Latency Bench documents broadband, bandwidth-limited, ambiguity and LF/subwoofer qualification. Signal Bench documents pink-noise and platform validation. MIDI Bench documents deterministic MIDI IN/OUT behavior and command-file operation.

## 9.5 Limits of validation

A passed validation set establishes behavior within the tested conditions. It does not imply that every third-party driver, interface, operating-system version, sample rate, DUT transfer function or routing topology has been tested.

# 10. Troubleshooting and measurement pitfalls

## 10.1 No signal or implausibly low level

Check physical routing, selected channels, interface mixer routing, mute state and DUT state.

## 10.2 Clipping

Reduce stimulus or upstream gain. Clipping invalidates many spectral/distortion measurements and can alter correlation behavior.

## 10.3 Unexpected latency

Separate bare transport latency from timing changes caused by filtering, sample-rate conversion, wireless transport, independent-clock bridging or other processing.

## 10.4 Ambiguous latency

Do not force a number. Narrow or strongly periodic responses can support multiple plausible timing peaks. If extended analysis still rejects the result, the available signal does not support a sufficiently unique timing interpretation under the current conditions.

## 10.5 Matrix feedback

Treat physical and virtual routing as a complete graph. Avoid returning an output into an input path that is simultaneously routed back to that output unless feedback is intentionally under test.

# 11. Technical and publication appendix

## 11.1 Terminology

**Baseline:** Reference measurement used to remove fixed path mismatch or establish a known state.  
**DUT:** Device under test.  
**dBFS:** Digital level relative to full scale; exact semantics depend on the measured quantity.  
**FFT:** Fast Fourier Transform.  
**Group delay:** Frequency-dependent timing associated with phase response.  
**Correlation:** Similarity measure used by Latency Bench to estimate relative timing.  
**Selection evidence:** Timing-candidate score used by Latency Bench.  
**THD:** Total harmonic distortion under the documented Spectral Bench definition.  
**THD+N:** Total harmonic distortion plus noise under the documented Spectral Bench definition.  
**HAL:** macOS Core Audio Hardware Abstraction Layer.

## 11.2 Publication figure checklist

Replace every `FIGURE PLACEHOLDER` with a real screenshot, photograph or manually prepared diagram before PDF publication. Preserve figure numbers/captions unless the surrounding text is also updated.

Use the actual released application version, crop unrelated desktop content, keep UI text readable at printed size, avoid personal paths/serial numbers/notifications, and use a consistent macOS appearance where practical.

## 11.3 Source-document policy

The individual project documentation remains the engineering source of truth. Development roadmaps are not reproduced wholesale as user-manual content, but validated technical facts and qualification material are incorporated where useful. Future handbook revisions should be checked against the current project Markdown documents before publication.
