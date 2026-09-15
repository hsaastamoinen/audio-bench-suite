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

Signal Bench 2.0.0 for macOS is the suite's deterministic audio test-signal generator. It provides broadband Pink and White noise, single- and dual-sine stimuli, standard analyzer-test presets, guitar-oriented two-tone stimuli, deterministic envelope shaping and optional harmonic or pick-attack components.

The design priority is repeatability. Signal Bench is intended to produce known, controllable stimuli for engineering work, not to imitate an instrument or make a test signal subjectively more natural.

<!-- FIGURE PLACEHOLDER: Figure 3.1
Application: Signal Bench
Subject: Main application window
Show: Signal type, primary generator controls, Output Level, Mute and stereo meters.
Crop: Application window only.
Suggested size: full text width
Caption: Signal Bench 2.0.0 main window and primary signal-generation controls.
-->

**Figure 3.1.** Signal Bench 2.0.0 main window and primary signal-generation controls.

## 3.1 Before generating a signal

Choose the required signal type, begin with a conservative **Output Level**, verify the intended output device and physical routing, and only then raise the level as required.

A digital level in dBFS does not define the analog voltage at a DUT. Interface calibration, output gain and any analog attenuation or amplification determine the actual voltage. Signal Bench deliberately does not insert an automatic limiter, because limiting would alter the measurement stimulus. Complex Dual Sine combinations can therefore exceed full scale if individual tone levels, harmonics, Pick Attack and master level are set too high.

The default master Output Level is `-18.0 dB`, providing a conservative starting point.

## 3.2 Signal modes at a glance

Signal Bench has three primary signal modes:

| Mode | Primary use |
| --- | --- |
| **Pink** | broadband testing with approximately equal energy per octave |
| **White** | broadband testing with approximately equal power density per Hz |
| **Dual Sine** | single-tone, two-tone, IMD and deterministic guitar-oriented stimuli |

Pink and White can use bandwidth filters. Dual Sine instead generates its spectral components directly and provides the tone, preset, harmonic, Slicer and Pick Attack controls described below.

## 3.3 Pink noise

Signal Bench uses Stefan Stenzel's **A New Shade of Pink** multirate algorithm, specifically the extended low-frequency form with 20 octave-spaced one-bit noise sources. The method combines octave-rate one-bit sequences using first-order-hold interpolation and a small FIR correction near Nyquist.

This architecture is attractive for a real-time generator because it combines good spectral accuracy with low computational cost. Signal Bench adapts the algorithm to ordinary C++ floating-point arithmetic rather than relying on the IEEE-754 accumulator trick used by the reference implementation.

A fixed scale factor of `1.6` follows the generator. It is a compatibility normalization for practical RMS level and headroom, not part of Stenzel's algorithm and not a change to the spectral shape.

Left and right Pink channels use independent deterministic states, so the stereo output is decorrelated rather than duplicated mono noise. Resetting the processor restores deterministic starting states, which is useful in repeatable testing.

### 3.3.1 Pink-noise validation

The implementation has been validated using a deterministic 16,777,216-sample float capture, overlapping Hann-window periodograms and 1/6-octave power averaging. Spectral shape is compared with a fitted ideal `1/f` power spectral density, independently of absolute level.

| Interpreted sample rate | RMS spectral error vs fitted 1/f PSD | Maximum absolute 1/6-octave-bin error |
| ---: | ---: | ---: |
| 44.1 kHz | 0.066 dB | 0.212 dB |
| 48 kHz | 0.070 dB | 0.284 dB |
| 96 kHz | 0.085 dB | 0.295 dB |
| 192 kHz | 0.118 dB | 0.350 dB |

The same reference run measured `0.195411 RMS` (`-14.18 dBFS`) and a peak magnitude of `0.916451`.

Regression limits are deliberately wider than the observed values: RMS must remain between `0.185` and `0.205`, peak magnitude below `1.0`, RMS spectral error no greater than `0.15 dB`, and maximum 1/6-octave-bin error no greater than `0.40 dB`. These are regression limits, not claims that one finite stochastic record constitutes an analytical proof.

The finite reference record has a mean of approximately `+0.0499`. With the 20-source low-frequency form, extremely slow components evolve over timescales longer than the reference capture, so a finite record is not required to average close to zero. A true deterministic DC component would require a different test.

### 3.3.2 Pink-noise algorithm credit

The pink-noise algorithm is based on work by **Stefan Stenzel**, who directly suggested its use in Signal Bench. His *A New Shade of Pink* / *Not so new shade of pink* work describes the multirate first-order-hold method, LFSR-based one-bit noise sources and FIR lookup-table correction. Signal Bench's C++17/JUCE implementation is an adaptation rather than a verbatim copy of the reference source.

The project documentation and source repository retain the detailed references and reproducible offline validation tools.

## 3.4 White noise

White noise is generated directly from internal xorshift64* pseudorandom-number generators. The two output channels use different deterministic seeds and independent states.

Unlike Pink noise, White noise is not passed through the pinking stage. The optional Low Cut and High Cut filters remain available.

## 3.5 Broadband bandwidth controls

Pink and White modes provide independent bandwidth controls:

| Control | Range / behavior |
| --- | --- |
| **Low Cut** | 10 Hz to 2 kHz |
| **High Cut** | 500 Hz to 24 kHz |
| **Slope** | 6, 12 or 24 dB/octave |
| **Default** | both filters Off; 12 dB/oct selected |

The 6 dB/oct setting uses a first-order section, 12 dB/oct uses a second-order Butterworth section, and 24 dB/oct uses two cascaded second-order sections forming a fourth-order Butterworth alignment. High Cut is clamped internally below Nyquist when necessary for the current sample rate.

These filters are disabled in Dual Sine mode.

## 3.6 Dual Sine

Dual Sine generates two independently adjustable sinusoidal components.

| Parameter | Range | Default |
| --- | ---: | ---: |
| F1 | 10 Hz to 24 kHz | 110.00 Hz |
| F2 | 10 Hz to 24 kHz | 164.81378 Hz |
| Tone 1 Level | -60 to 0 dB | -6.0 dB |
| Tone 2 Level | -60 to 0 dB | -6.0 dB |

The default frequencies are A2 and E3 in 12-tone equal temperament.

Each oscillator uses a phase accumulator. For frequency `f`, sample rate `Fs` and phase `phi`:

```text
x = sin(phi)
phi_next = phi + 2*pi*f/Fs
```

with phase wrapping at `2*pi`.

Frequency changes are smoothed over approximately 20 ms. The oscillator phase itself is not reset, so a manual frequency change does not create an artificial hard phase restart. The resulting Dual Sine sample is copied coherently to every active output channel.

## 3.7 Single-tone, two-tone and IMD presets

A nonlinear DUT produces components that were not present in the original two-tone input. Depending on the nonlinearity, products can include:

```text
f2 - f1
f1 + f2
2f1 - f2
2f2 - f1
2f1 + f2
2f2 + f1
```

Signal Bench supplies the known stimulus; analysis of the DUT output belongs to Spectral Bench or another analyzer.

For fast, repeatable analyzer testing, Signal Bench includes one-action presets matched to Spectral Bench measurement modes:

- 100 Hz single tone;
- 1 kHz single tone;
- 10 kHz single tone;
- SMPTE-style 60 Hz + 7 kHz, with the 7 kHz component 12.0412 dB below the 60 Hz component, corresponding to a 4:1 amplitude ratio;
- CCIF 19 kHz + 20 kHz, equal amplitudes.

Loading one of these presets selects Dual Sine, establishes the required frequencies and relative tone levels, and disables Low Cut, High Cut, Slicer, added harmonics and Pick Attack shaping. Single-tone presets disable Tone 2.

The preset deliberately preserves **Output Level** and **Mute**. A preset can therefore establish the spectral relationship without unexpectedly changing the user's overall test level or unmuting the generator.

<!-- FIGURE PLACEHOLDER: Figure 3.2
Application: Signal Bench
Subject: Measurement stimulus presets
Show: Dual Sine controls with the measurement preset selector/menu visible, including the single-tone, SMPTE-style and CCIF choices.
Crop: Application window or relevant control area only.
Suggested size: approximately 70% text width
Caption: Signal Bench measurement presets provide deterministic stimuli matched to common Spectral Bench analyses.
-->

**Figure 3.2.** Signal Bench measurement presets provide deterministic stimuli matched to common Spectral Bench analyses.

## 3.8 Guitar-oriented interval presets

Dual Sine can also load two-note stimuli based on guitar-oriented roots from E2 through E5. Available intervals are minor 3rd, major 3rd, 5th and octave.

The preset system supports both 12-tone equal temperament and simple Just ratios.

For 12-TET:

```text
f2 = f1 * 2^(n/12)
```

where `n` is 3, 4, 7 or 12 semitones for the available intervals.

The Just ratios are:

| Interval | Ratio |
| --- | ---: |
| minor 3rd | `6/5` |
| major 3rd | `5/4` |
| 5th | `3/2` |
| octave | `2/1` |

Loading a guitar interval preset writes the calculated values into the normal F1 and F2 parameters and enables Tone 2. The frequencies remain freely adjustable afterward.

These presets are useful for comparing nonlinear behavior with equal-tempered and pure-ratio input tones. They are measurement conveniences, not guitar-string models.

## 3.9 Harmonic enrichment

The optional **HARMONICS** function adds H2 through H5 to each Dual Sine tone. It is Off by default.

Harmonic amplitude follows:

```text
amplitude(n) = 1 / n^2
```

relative to that tone's fundamental.

| Harmonic | Relative level |
| --- | ---: |
| H2 | -12.04 dB |
| H3 | -19.08 dB |
| H4 | -24.08 dB |
| H5 | -27.96 dB |

A harmonic is omitted when its frequency reaches or exceeds `0.48 * sample_rate`, leaving a guard below Nyquist.

This is a deterministic way to create a spectrally richer known stimulus. It is not intended to model the harmonic structure of a real guitar string.

## 3.10 Slicer

The Slicer is available in Dual Sine mode and is Off by default. Its rate is adjustable from 0.2 to 5.0 Hz, with a default of 2.0 Hz. Two shapes are available: **Gate** and **Guitar**.

### Gate

Gate is a deterministic 50% duty-cycle amplitude gate with 12 ms raised-cosine rise and fall edges. The finite edges reduce discontinuities compared with an instantaneous rectangular gate.

### Guitar

Guitar shape provides a deterministic picked-chord-style amplitude envelope with:

- a fixed 5 ms raised-cosine onset;
- 35% fast-decay component;
- 65% slow-decay component;
- fixed fast time constant of 120 ms;
- adjustable slow decay from 0.2 to 5.0 s, default 2.0 s.

Conceptually:

```text
body(t) =
    0.35 * exp(-t / 0.120)
  + 0.65 * exp(-t / slow_decay)
```

The beginning of each cycle is made continuous with the mathematically calculated end level of the previous cycle rather than being forcibly reset to zero. The selected Slicer Rate determines the retrigger period.

## 3.11 Pick Attack

Pick Attack is an optional deterministic excitation available only when Dual Sine, Slicer, Guitar shape and Pick Attack are all enabled. It is Off by default.

The excitation begins with a deterministic xorshift32 sequence. The PRNG and filter states are reset identically on every Slicer retrigger, so each Pick Attack event is repeatable.

The source passes through an adjustable first-order low-pass and a fixed high-pass-style emphasis. **PICK LPF** ranges from 500 Hz to 12 kHz, default 1800 Hz. The low-pass coefficient is sample-rate aware:

```text
a = exp(-2*pi*fc/Fs)
```

The event lasts 5 ms, with a 3 ms raised-cosine attack, an approximately 1.7 ms exponential decay time constant and a final 1.5 ms cosine tail that returns the event smoothly to zero.

**PICK LEVEL** ranges from -20.0 to 0.0 dB, default -4.0 dB. It is not additionally multiplied by the Tone 1 or Tone 2 level controls. The Pick Attack is, however, multiplied by the same Guitar amplitude envelope as the tonal signal, tying it to the retriggered event rather than adding an unrelated click.

## 3.12 Signal flow

The normal Dual Sine path is:

```text
F1 -> frequency smoothing -> oscillator -> optional H2...H5 -> Tone 1 Level --\
                                                                               +-> Slicer/Guitar envelope
F2 -> frequency smoothing -> oscillator -> optional H2...H5 -> Tone 2 Level --/   -> Output Level
                                                                                   -> Mute
                                                                                   -> output
                                                                                   -> meter peak capture
```

With Guitar Pick Attack enabled, its deterministic noise/filter/time-envelope path joins the two tonal paths before master Output Level.

Pink and White use the simpler path:

```text
independent channel PRNG
  -> Pink algorithm, if Pink mode
  -> optional Low Cut
  -> optional High Cut
  -> Output Level
  -> Mute
  -> output
  -> channel meter peak capture
```

## 3.13 Output Level, Mute and metering

Master **Output Level** ranges from -60.0 to 0.0 dB and defaults to -18.0 dB. It follows the bandwidth filters in Pink/White mode and follows all tonal, harmonic, envelope and Pick Attack components in Dual Sine mode.

The 0 dB maximum is intentional. Pink noise has relatively modest RMS level because of its broadband statistical waveform and crest factor, but the validated generator still produces instantaneous peaks close to full scale. Increasing broadband level through hidden limiting, compression, clipping or peak normalization would alter the stimulus.

**MUTE** zeros the final output after generation and gain processing. Metering follows that final value, so the meters fall toward their floor while muted.

Signal Bench 2.0.0 presents independent left/right peak meters with engineering dBFS markings at 0, -6, -12, -18, -24, -36, -48 and -60 dBFS. The DSP peak comes from the same final sample written to the output buffer.

The visible meter may react before the corresponding sound emerges from the physical output because the UI sees the generated buffer before downstream host, driver and hardware buffering reaches the DAC. No fixed artificial meter delay is added because the required compensation would depend on the system. GUI-only meter smoothing uses fast attack and approximately 0.5 s release and does not alter the audio.

The meters are useful output indicators, not precision analyzer channels.

## 3.14 State persistence

Signal Bench uses JUCE `AudioProcessorValueTreeState`. Host-visible persistent state includes the signal type, master level, bandwidth-filter state and settings, Mute, F1/F2, tone levels, Slicer settings, Guitar decay, Pick Attack settings and Harmonics state.

The Root, Interval and Tuning selectors are convenience controls. Loading a preset calculates and writes the resulting values into the ordinary persistent parameters.

## 3.15 macOS formats and installation

Signal Bench 2.0.0 is provided on macOS as:

- Standalone;
- Audio Unit;
- VST3.

The Audio Unit is a Music Device, allowing Logic Pro to expose Signal Bench as a Software Instrument.

The current identities are:

```text
Bundle identifier: works.60n.signalbench
AU identity:       aumu / SgB1 / Sn60
Vendor:            60°N Signal Works
```

The individual macOS package installs:

```text
/Applications/60°N Signal Works Audio Bench Suite/Signal Bench.app
/Library/Audio/Plug-Ins/Components/Signal Bench.component
/Library/Audio/Plug-Ins/VST3/Signal Bench.vst3
```

At the documented 2.0.0 release checkpoint, the package is unsigned. macOS may therefore require explicit approval in **System Settings > Privacy & Security** when the package is obtained from a trusted source. Signing and notarization are distribution concerns and do not change the signal-generation algorithms described in this chapter.

## 3.16 Validation status

The macOS 2.0.0 release retains the established signal-generation/DSP baseline while updating the macOS UI, meter presentation and ballistics, artwork and packaging.

The qualified macOS validation includes:

- clean native Release build;
- Standalone installation and functional testing;
- Audio Unit installation, `auval` validation and Logic Pro testing;
- VST3 build and installation, including vendor metadata verification;
- installer payload and installer-only clean-install validation;
- final installed Standalone smoke test and UI/function validation;
- functional testing of measurement stimulus presets;
- Pink-noise regression validation at 44.1, 48, 96 and 192 kHz.

The pink-noise figures in Section 3.3.1 are the published quantitative reference values for that generator validation.

## 3.17 Practical workflows

### Generate a known single tone

1. Select the appropriate 100 Hz, 1 kHz or 10 kHz measurement preset.
2. Confirm Output Level and Mute.
3. Verify the physical output level at the DUT when analog calibration matters.
4. Use Spectral Bench or another analyzer to inspect the DUT output.

### Run an IMD measurement

Select the SMPTE-style or CCIF preset corresponding to the intended Spectral Bench analysis. The preset establishes the required frequency and amplitude relationship while preserving master Output Level and Mute.

### Exercise a nonlinear guitar-oriented device

Load a Root + Interval preset, choose 12-TET or Just tuning as required, and first measure with Harmonics, Slicer and Pick Attack disabled. Add those deterministic components one at a time when the experiment specifically requires a richer or time-varying stimulus. This keeps the cause of any observed change identifiable.

### Generate bandwidth-limited noise

Select Pink or White, enable Low Cut and/or High Cut, choose the required slope, and verify that the selected cutoff remains meaningful at the current sample rate. Remember that the Output Level control is a gain control, not a calibrated broadband RMS-output setting.

## 3.18 Interpretation and cautions

Signal Bench is deliberately transparent about what it does not do:

- it does not calibrate dBFS to analog volts;
- it does not automatically prevent clipping with a limiter;
- it does not calculate the distortion products produced by a DUT;
- its Guitar envelope and Pick Attack are deterministic measurement stimuli, not physical instrument models;
- its output meters are indicators, not calibrated analysis channels;
- a low broadband RMS value does not imply unused peak headroom.

For measurements that depend on exact spectral interpretation, use Signal Bench as the known source and let Spectral Bench perform the calibrated analysis.

# 4. Spectral Bench

Spectral Bench 2.1.0 for macOS is the suite's real-time spectrum and audio-measurement analyzer. Its spectrum display is the primary instrument, with calibrated level, tone, harmonic, distortion, intermodulation, sweep and phase measurements layered on the same analysis foundation.

The application is designed around explicit measurement definitions. Display zoom and trace presentation are kept separate from authoritative measurement math, and measurements that require a reference, bandwidth or phase convention expose that convention rather than hiding it.

<!-- FIGURE PLACEHOLDER: Figure 4.1
Application: Spectral Bench
Subject: Main analyzer window
Show: Spectrum display, input selection, FFT/window/averaging controls, viewport controls and measurement readouts.
Crop: Application window only.
Suggested size: full text width
Caption: Spectral Bench 2.1.0 configured for live spectrum inspection.
-->

**Figure 4.1.** Spectral Bench 2.1.0 configured for live spectrum inspection.

## 4.1 General setup

Select the input channel that actually carries the signal under test. Start with **Input Gain = 0 dB** and keep enough headroom that neither the DUT nor the interface clips. For generated sweeps, `-12 dBFS` is a useful general starting level.

The normal overview is 20 Hz to 20 kHz, but the viewport can be narrowed substantially without changing the underlying calibrated measurement. Frequency view and dB Top/Floor/Span are display controls. **Input Gain is different:** it changes the samples presented to the analyzer and therefore changes measured dBFS values.

A practical live-spectrum starting point is FFT 16384, Blackman-Harris 4-term, Averaging Off for immediate response or Medium for a steadier trace, Peak Off, Raw trace and Input Gain 0 dB.

`Save Result…` (`⌘S`) writes PNG, CSV and TXT companions. The PNG preserves the visual state, while CSV/TXT preserve the numeric and provenance information.

## 4.2 Spectrum analyzer

The real-time analyzer provides:

- logarithmic frequency display;
- calibrated dBFS magnitude;
- FFT sizes 4096, 8192, 16384, 32768 and 65536;
- Hann, 4-term Blackman-Harris and Flat Top windows;
- Off/Fast/Medium/Slow averaging;
- Off/Hold/Decay peak behavior with explicit reset;
- Raw and Noise Smooth trace presentation;
- adjustable frequency and dB viewports;
- a free crosshair with fixed Trace/Cursor readouts.

The default FFT size is 16384.

### 4.2.1 Frequency viewport

macOS 2.1.0 includes logarithmic presets covering useful low-, mid- and high-frequency regions, plus a Custom minimum/maximum view with adaptive 1-2-5 engineering grid generation. The frequency axis remains logarithmic.

Changing the visible frequency range does not change analyzer calibration or measurement bandwidth. It changes what part of the spectrum is shown.

### 4.2.2 dB viewport and Input Gain

The dB viewport can range from a 120 dB overview down to a 10 dB span. dB Top, Floor and Span are coupled: selecting Top or Floor establishes the zoom anchor, and later Span changes preserve that boundary while moving the other.

**Input Gain**, adjustable from -20 to +40 dB, is not a display control. It modifies the samples entering the analyzer. Use it deliberately and record it when absolute dBFS results matter.

### 4.2.3 Cursor and trace readout

The crosshair reports mouse frequency and dBFS position, the trace level at the same frequency and their signed dB difference. The readout remains in a fixed top-right location so it does not chase the pointer.

When a result is saved, the active cursor/trace measurement is included in the PNG, CSV and TXT report.

<!-- FIGURE PLACEHOLDER: Figure 4.2
Application: Spectral Bench
Subject: Zoomed spectrum with cursor measurement
Show: Narrow frequency and dB view, crosshair, fixed Trace/Cursor readout and Input Gain control.
Crop: Application window or spectrum/viewport area only.
Suggested size: full text width
Caption: Spectral Bench viewport and cursor controls can inspect detail without changing calibrated measurement math; Input Gain is the exception and acts on analyzer input samples.
-->

**Figure 4.2.** Viewport zoom and cursor measurement in Spectral Bench.

## 4.3 FFT calibration and level semantics

Spectral Bench distinguishes time-domain level from spectral tone amplitude.

**Sample Peak** is the maximum absolute input sample over the relevant analysis interval. **RMS** is calculated from the time-domain samples. Neither depends on FFT size, FFT window, overlap or averaging.

Spectral tone amplitude comes from the calibrated FFT/fit path. Window coherent gain is explicitly accounted for so that a bin-centered coherent sine reports its intended amplitude. Window equivalent noise bandwidth (ENBW) is also an explicit property because broadband noise and a discrete tone cannot be interpreted with the same per-bin assumptions.

The application does not claim a dBFS/Hz power-spectral-density representation. Broadband noise therefore needs to be interpreted using the analyzer's documented spectrum semantics rather than as if each displayed value were automatically a density measurement.

## 4.4 FFT windows

The supported windows are Hann, 4-term Blackman-Harris and Flat Top.

Use Blackman-Harris as a strong general-purpose choice when spectral leakage rejection matters. Flat Top is useful when amplitude accuracy for isolated tones is more important than narrow main-lobe width. Hann is a conventional compromise with a relatively narrow lobe and moderate leakage suppression.

The important engineering point is that changing the window changes leakage, main-lobe width, coherent gain and ENBW. Spectral Bench calibrates the supported windows, but no window removes the underlying time/frequency-resolution tradeoff.

## 4.5 Averaging, Peak Hold and trace presentation

Averaging operates in **linear power** and is converted to dB afterward:

```text
Pavg_new = alpha * Pavg_old + (1 - alpha) * Pnew
alpha = exp(-hopSeconds / tau)
```

The implemented time constants are:

| Mode | Time constant |
| --- | ---: |
| Fast | 0.25 s |
| Medium | 1.00 s |
| Slow | 4.00 s |

Peak behavior is Off, Hold or Decay. Decay uses 20 dB/s, and Reset clears stored peak state.

**Noise Smooth** is display-only. It is useful for visually stabilizing broadband Pink or White noise, especially at high frequencies. It does not modify the calibrated measurement snapshot, cursor source data, harmonic analysis, THD, THD+N, IM products or authoritative numeric export.

`Hold`, which freezes the displayed graph, is also distinct from Peak Hold/Decay.

## 4.6 Single-tone measurements

Spectral Bench provides defined 100 Hz, 1 kHz and 10 kHz modes plus Manual Tone.

For an applicable single-tone measurement, the panel can report:

- input RMS and sample peak;
- nominal frequency where defined;
- measured fundamental frequency;
- fitted fundamental amplitude;
- H2 through H10 where valid below Nyquist;
- each harmonic relative to the fundamental in dBc;
- THD;
- THD+N;
- actual THD+N bandwidth.

Defined-frequency modes search around the expected tone rather than simply choosing any dominant spectral component. Manual Tone performs dominant-tone detection across the normal analysis range. A tone-confidence requirement prevents an arbitrary weak spectral maximum from being promoted to a valid measurement.

Signal Bench provides matching deterministic 100 Hz, 1 kHz and 10 kHz stimulus presets.

## 4.7 Harmonics and THD

Harmonic analysis fits the fundamental and valid harmonics H2 through H10. Harmonic levels are reported in dBc relative to the fitted fundamental.

THD is conceptually:

```text
THD = sqrt(V2^2 + V3^2 + ... + Vn^2) / V1
```

where only valid harmonics within the supported analysis range contribute.

THD describes harmonic products only. It does not include unrelated broadband noise and must not be used interchangeably with THD+N.

## 4.8 THD+N

THD+N removes the fitted fundamental and integrates the remaining residual power over an explicit measurement bandwidth. The measurement therefore includes harmonic distortion, noise and any other residual energy inside that bandwidth.

The available bandwidth semantics include 20 Hz to 20 kHz where the sample rate permits it and 20 Hz to Nyquist. No A-weighting, AES weighting or other weighting filter is part of the documented measurement.

Always report the THD+N bandwidth with the result. A percentage without its measurement bandwidth is incomplete.

## 4.9 Fifteen-second single-tone statistics

Manual Tone and the three defined single-tone modes can accumulate a 15-second measurement window using new accepted analysis frames. SMPTE-style and CCIF modes do not use this helper because they report selective products rather than a normative aggregate measurement.

The statistics function is useful when a single live value is too volatile to describe a DUT. It does not turn an unstable or invalid stimulus into a valid one; the same stimulus/confidence rules still apply to accepted frames.

## 4.10 CCIF / DFD-style 19 + 20 kHz measurement

The defined stimulus is:

```text
f1 = 19 kHz
f2 = 20 kHz
equal amplitudes
```

The difference frequency is 1 kHz. Spectral Bench explicitly inspects:

```text
f2 - f1        = 1 kHz
2*f1 - f2      = 18 kHz
2*f2 - f1      = 21 kHz
```

The 21 kHz product is valid only when it is below Nyquist and inside the usable analyzer range. Numerical analysis may report it even though the normal live spectrum view is capped at 20 kHz; display range and analysis range are different concepts.

Available products are reported in dBc.

The wording **CCIF / DFD-style** is intentional. Spectral Bench does not claim a normative aggregate CCIF/ITU-R percentage because the exact standard normalization has not been established from the normative source.

## 4.11 SMPTE-style 60 Hz + 7 kHz measurement

The defined stimulus is:

```text
fL = 60 Hz
fH = 7 kHz
low/high amplitude ratio = 4:1
```

A 4:1 amplitude ratio is approximately 12.041 dB.

The analyzer explicitly inspects the second-order sideband pair at 6940 and 7060 Hz and the third-order pair at 6880 and 7120 Hz. Products are reported numerically in dBc.

Again, **SMPTE-style** is deliberate terminology. The selective sideband measurements are fully defined, but Spectral Bench does not present them as a normative aggregate SMPTE IMD percentage.

Signal Bench includes matching SMPTE-style and CCIF presets, reducing the chance that generator and analyzer settings are accidentally mismatched.

## 4.12 Referenced frequency-response sweep

macOS 2.1.0 adds automated sweep measurement with a DUT path and an optional reference path.

For a referenced transfer measurement, wire the generator to both the DUT and reference paths so that the analyzer captures the DUT response and the reference response during the same measurement. The reported transfer magnitude is based on the relationship between those paths rather than on the absolute DUT capture alone.

A direct dual-channel loopback is the best first qualification step. It exposes channel mismatch and confirms that the reference path is wired and selected correctly before a DUT is introduced.

Use **Transfer** when the question is the DUT response relative to a reference. Use **Actual** when the absolute captured response is the quantity of interest.

<!-- FIGURE PLACEHOLDER: Figure 4.3
Application: Spectral Bench
Subject: Referenced sweep setup
Show: Sweep controls, DUT input/output selections, Reference input/path, Transfer result and phase controls.
Crop: Application window only.
Suggested size: full text width
Caption: Spectral Bench configured for a referenced DUT transfer sweep.
-->

**Figure 4.3.** Referenced DUT transfer sweep.

## 4.13 Transfer versus Actual response

**Transfer** answers the relative question: what did the DUT path do compared with the simultaneously measured reference path?

**Actual** shows the captured DUT response itself. It is useful when an absolute system response is wanted or when a suitable reference path is not available.

Do not interpret an unreferenced Actual trace as if interface, cable and channel response had automatically been divided out. Conversely, a referenced Transfer measurement is only as meaningful as the reference path and channel matching used to create it.

## 4.14 Phase modes

Phase is inherently reference-dependent. Spectral Bench 2.1.0 therefore exposes four distinct modes rather than pretending there is one universally correct phase trace.

### Raw

Raw preserves the measured phase relationship, including transport delay. A constant delay appears as a frequency-dependent phase slope and repeated wraps.

Use Raw when that complete measured relationship is the quantity of interest.

### Auto

Auto estimates and removes a response-dependent constant-delay component to make the remaining phase easier to inspect. This is a presentation/reference choice, not an independent latency measurement.

The delay/linear-phase ambiguity means that a frequency-response measurement alone cannot always separate pure transport delay from linear phase belonging to the DUT response. Auto can therefore produce a useful phase view without equalling the physical latency measured by Latency Bench.

### Manual

Manual applies a user-specified delay compensation. This is the correct mode when the transport latency is known independently and the goal is to inspect phase after removing that known constant-delay component.

For example, a physical qualification path measured by Latency Bench at 48 kHz produced 89.15 samples / 1.857 ms. Entering that independently measured value in Spectral Bench Manual phase removed the expected constant-delay component and produced an essentially flat LPF-off response through the useful band.

### Baseline A/B

Baseline uses a stored reference measurement and shows subsequent phase relative to it. The guided A/B workflow is particularly useful for measurements such as filter Off versus filter On, where the common transport delay should disappear and the phase change caused by the DUT state is the desired result.

In qualification, LPF Off as baseline followed by a 1 kHz LPF On measurement produced the expected filter phase without transport-delay wraps. Off followed by Off produced an essentially 0-degree null across the displayed band.

<!-- FIGURE PLACEHOLDER: Figure 4.4
Application: Spectral Bench
Subject: Phase reference modes
Show: Phase mode control with Raw, Auto, Manual and Baseline choices, plus Manual delay or Baseline status where applicable.
Crop: Relevant sweep/phase control area and enough graph to show the phase trace.
Suggested size: full text width
Caption: Raw, Auto, Manual and Baseline are explicit phase-reference choices, not interchangeable latency estimators.
-->

**Figure 4.4.** Spectral Bench phase-reference modes.

## 4.15 Why phase and latency must not be confused

A measured transfer function cannot in general distinguish an arbitrary constant transport delay from an equivalent linear phase term solely from the frequency-domain response. This is why Spectral Bench Auto compensation and Latency Bench can legitimately report different delay values for the same physical DUT path.

During physical qualification with a Neural DSP Quad Cortex, Latency Bench measured 89.15 samples / 1.857 ms at 48 kHz while Spectral Bench Auto estimated about 1.42 ms for the tested response. Manual compensation with the independently measured 1.857 ms behaved as expected.

Use Latency Bench when the quantity required is physical-path latency. Use Spectral Bench phase modes when the quantity required is phase referenced according to Raw, Auto, known-delay Manual or A/B Baseline semantics.

## 4.16 Saving a result

`Save Result…` (`⌘S`) creates three companion files:

- PNG, preserving the visual graph and active cursor/trace annotation;
- CSV, for structured numeric data;
- TXT, for a human-readable report and provenance.

The export terminology distinguishes live analyzer state from completed sweep state. CSV uses `analyzer_mode` for the analyzer selector and `sweep_type` for the appended sweep. TXT uses `Analyzer mode:` and `Sweep type:`. Phase exports record the selected phase mode and, for Auto or Manual, the applied compensation in milliseconds.

This distinction matters when a report contains both a live analyzer mode such as Manual Tone and a completed referenced sweep.

## 4.17 macOS formats and installation

Spectral Bench 2.1.0 for macOS is qualified as Standalone, Audio Unit and VST3. The final package clean-installed all three at their intended system locations. The Audio Unit passed full `auval` validation, VST3 version/bundle/vendor metadata were verified, and the installed Standalone passed sweep, Transfer, Actual and Phase smoke tests.

The handbook focuses on the qualified macOS release. Older cross-platform release history belongs in project/release documentation rather than the operating flow of this chapter.

## 4.18 Validation and qualification

The released macOS 2.1.0 build passes the full 20-test automated suite.

Physical sweep qualification used direct dual-channel loopback and a Neural DSP Quad Cortex DUT. Swapping direct-loopback channels produced equal-and-opposite small high-frequency phase slope, showing that the residual slope was physical channel/path mismatch rather than an estimator artifact.

Repeated direct-loopback sweeps showed approximately `0.000023 dB` worst-case magnitude variation over 30 Hz to 18 kHz. Known 1 kHz 12 dB/oct and 24 dB/oct low-pass responses behaved as expected. Level-dependence checks at -6, -12, -24 and -48 dBFS passed.

Physical sweep checks covered 44.1, 48 and 96 kHz and representative 16, 64 and 512 sample buffers. Qualification also covered Raw, Auto, Manual and Baseline phase semantics, guided Baseline A/B, viewport behavior, Input Gain independence from display zoom, cursor/readout behavior, `⌘S` export and final installed-artifact smoke tests.

These tests establish the behavior of the qualified implementation under the tested conditions. They do not remove the need to validate the user's own interface, channels, reference path and DUT setup.

## 4.19 Practical measurement workflows

### Live spectrum or noise inspection

Use Raw trace for detailed spectral structure. Medium averaging is a useful starting point for a steadier broadband display; Noise Smooth can make a Pink/White noise trace visually easier to read without changing numeric measurements. Use cursor/trace delta for local inspection.

### Single-tone distortion

Use a matching Signal Bench 100 Hz, 1 kHz or 10 kHz preset when possible. Confirm a valid fundamental, then read H2-H10, THD and THD+N. Record the THD+N bandwidth.

### Intermodulation products

Use the matching Signal Bench SMPTE-style or CCIF preset. Interpret the explicitly reported sidebands/products in dBc. Do not relabel them as normative aggregate SMPTE or CCIF percentages.

### DUT frequency response

First run a direct referenced loopback to qualify the two channels. Then insert the DUT in the DUT path and run Transfer. Use Actual only when the absolute captured response is what you intend to report.

### Filter phase

If transport delay should remain part of the result, use Raw. If the transport latency is known independently, use Manual and enter that value. For an A/B change such as filter Off versus On, Baseline is usually the clearest reference. Treat Auto as a useful response-dependent compensation, not as a substitute for Latency Bench.

## 4.20 Common interpretation errors

The most important traps are conceptual rather than numerical.

A narrower display range does not create a narrower measurement bandwidth. Input Gain is not merely a visual zoom. THD and THD+N are not interchangeable. A selective IM product is not automatically a normative aggregate IMD percentage. An Actual response is not automatically a referenced transfer function. Auto phase compensation is not a latency measurement. And a very stable result can still be wrong if the reference channel, DUT path or physical wiring is wrong.

When the result matters, save it together with enough setup information to reconstruct what was actually measured.

# 5. Latency Bench

Latency Bench 1.1.1 for macOS measures **physical-path latency** through an audio device or DUT by comparing a direct reference path with a second path through the DUT. It is designed for measurements where cable, converter, analog, digital and processing delays are part of the real signal path.

The application generates its own deterministic broadband probe, captures the reference and DUT responses, estimates their relative timing by normalized cross-correlation and reports the DUT path relative to a stored baseline.

<!-- FIGURE PLACEHOLDER: Figure 5.1
Application: Latency Bench
Subject: Main application window
Show: selected audio device, Reference OUT/IN, DUT OUT/IN, baseline status, probe level and measurement controls.
Crop: Application window only.
Suggested size: full text width
Caption: Latency Bench 1.1.1 configured for a physical-path DUT measurement.
-->

**Figure 5.1.** Latency Bench 1.1.1 configured for a physical-path DUT measurement.

## 5.1 What Latency Bench measures

Latency Bench measures the timing difference between two simultaneously defined physical paths:

```text
Reference OUT A -> direct reference path -> Reference IN A

DUT OUT B       -> device under test      -> DUT IN B
```

The baseline characterizes the difference between the two measurement loops without the DUT contribution. A later DUT measurement subtracts that baseline from the measured reference-to-DUT offset.

This makes the result a physical-path measurement rather than a calculation from driver buffer settings.

Depending on the DUT, the reported timing can include:

- interface output and input conversion;
- analog circuitry;
- DSP transport;
- internal buffering;
- effects-loop paths;
- sample-rate conversion;
- filter phase/group delay;
- any other delay that changes the captured response relative to the reference.

That last point is important. Latency Bench measures the timing of the **captured response**. With a strongly bandwidth-limited or phase-shifting DUT, that is not necessarily identical to bare digital transport latency.

## 5.2 Wiring

For the baseline, make both paths as equivalent as practical:

```text
OUT A -> cable -> IN A
OUT B -> cable -> IN B
```

For the DUT measurement, leave the reference path intact and insert the DUT into path B:

```text
OUT A -> cable -> IN A
OUT B -> DUT   -> IN B
```

Use the same interface, sample rate, channel assignments and physical reference path for baseline and DUT measurement.

<!-- FIGURE PLACEHOLDER: Figure 5.2
Application: Latency Bench
Subject: Baseline and DUT physical wiring
Show: two manually prepared signal-flow drawings or photographs, one for direct dual-loop baseline and one with the DUT inserted in path B.
Crop: Only the relevant interface, cables and DUT or a clean manually drawn diagram.
Suggested size: full text width
Caption: The baseline measures the two physical loops directly; the DUT measurement inserts the DUT only into path B.
-->

**Figure 5.2.** Baseline and DUT physical-path wiring.

## 5.3 Measurement workflow

A reliable workflow is:

1. Select the audio device and the Reference OUT/IN and DUT OUT/IN channels.
2. Set a conservative probe level. The default is `-30 dBFS`.
3. Wire both paths directly and run **Measure Baseline**.
4. Confirm that the baseline is accepted and stable.
5. Insert the DUT into path B without changing the reference path.
6. Put the DUT into the exact state to be measured.
7. Run the DUT measurement.
8. Interpret the reported median, run spread, correlation/evidence and any competing timing candidate.
9. Save or record the result together with the physical setup and DUT state.

The DUT measurement performs ten automatic runs. The **median** is the primary reported result because it is robust against an occasional outlying run. Mean, minimum, maximum and standard deviation provide additional repeatability evidence.

## 5.4 Probe signal

Latency Bench uses a deterministic pseudo-random bipolar broadband probe. The same known sequence is sent through the reference and DUT output paths.

The normal analysis configuration uses:

```text
probe length:        2048 samples
capture length:     32768 samples
prime:               2048 samples
tail:               12288 samples
maximum lag:        +/-16384 samples
correlation window: 4096 samples
```

The deterministic probe gives the estimator a known broadband signature rather than relying on an arbitrary program signal or a single periodic tone.

A periodic sine alone is a poor general-purpose latency probe because many delays separated by an integer number of periods can appear equally plausible. Broadband structure greatly reduces that ambiguity for ordinary paths.

## 5.5 Normalized cross-correlation

For each candidate lag, the estimator compares overlapping reference and DUT samples using normalized cross-correlation. Conceptually:

```text
r(k) =
    sum x[n] y[n+k]
    -----------------------------------------
    sqrt(sum x[n]^2 * sum y[n+k]^2)
```

Normalization makes the timing comparison substantially insensitive to simple gain differences.

Latency Bench searches both positive and negative lags. It uses the **magnitude** of correlation for timing selection, so a polarity-inverted but otherwise valid path can still be timed correctly. The sign of raw correlation remains useful evidence about the relationship between the captured signals.

The correlation peak is refined with parabolic interpolation, allowing fractional-sample timing estimates.

## 5.6 Correlation evidence and overlap weighting

A raw normalized-correlation value can become misleading near the edges of a search, where only a small number of samples overlap. Version 1.1.1 therefore keeps raw correlation separate from the evidence used to select the winning lag.

The selection evidence is:

```text
evidence =
    abs(correlation)
    * sqrt(actual_overlap / nominal_window)
```

This penalizes candidates supported by unusually short overlap without adding a preferred latency direction, expected-latency bias or polarity bias.

Internally the estimator carries both quantities as `CorrelationEvidence { correlation, sampleCount }`.

## 5.7 Confidence and ambiguity rejection

Latency Bench is intentionally allowed to say that a measurement is ambiguous.

The primary timing candidate must have evidence of at least `0.10`. After selecting it, the estimator searches for a sufficiently separate competing candidate. If the strongest separate candidate reaches at least **90% of the primary evidence**, the measurement is rejected rather than reporting an arbitrary winner.

This is especially important for narrow-band or strongly resonant responses, where the correlation function can contain several plausible lobes.

A rejected measurement is useful information. It means the captured response did not provide enough unique timing evidence under the current conditions to support one interpretation confidently.

## 5.8 Automatic extended analysis

Normal analysis is deliberately lightweight. When a DUT run has weak or competing timing evidence, version 1.1.1 automatically retries that run with extended analysis.

The extended configuration uses:

```text
probe length:        8192 samples
correlation window: 12288 samples
```

The longer probe provides more information for strongly filtered paths.

The UI identifies this behavior as:

`Physical path latency | extended analysis when needed`

A normal broadband DUT should not pay the cost of extended analysis. Qualification confirmed that an ordinary bypass/cable measurement remained on normal analysis for all ten runs.

## 5.9 Magnitude-matched extended probe

A strongly filtered DUT may remove so much of the broadband probe that the raw reference and DUT no longer resemble each other sufficiently for unambiguous correlation.

During extended analysis, Latency Bench therefore estimates the DUT's captured magnitude spectrum and applies that magnitude shape to the reference probe in the frequency domain before correlation.

The important constraint is that **DUT phase is not copied or corrected**. Only spectral magnitude is matched. The DUT's timing and phase behavior remain in the captured DUT response and are therefore still available to the estimator.

This approach improves timing evidence for legitimate narrow-band and subwoofer-style outputs without defining an arbitrary minimum bandwidth.

The signed lag range, confidence threshold and 90% competing-candidate ambiguity rule remain unchanged.

## 5.10 No arbitrary bandwidth limit

Latency Bench does not impose a rule such as "the DUT must pass at least N octaves" or "the response must extend above frequency X."

Qualification demonstrated accepted measurements for very strongly bandwidth-limited low-frequency paths, including a 20-160 Hz band with 48 dB/oct filtering.

Whether a particular path is measurable depends on the timing information present in the captured response, not on a fixed published bandwidth threshold.

The opposite is equally important: some wider-looking responses can still be ambiguous if their correlation structure produces competing candidates. The estimator decides from evidence rather than from a hard-coded audio-band label.

## 5.11 Polarity reversal

Because timing selection uses correlation magnitude, a simple polarity inversion does not inherently invalidate a latency measurement. An otherwise unchanged inverted response produces a correlation peak of opposite sign at the same timing.

This does **not** mean that arbitrary phase manipulation is irrelevant. Frequency-dependent phase shift, filtering and resonant behavior can alter the waveform and the shape of the correlation function. Polarity inversion is the special case of multiplying the whole waveform by `-1`.

## 5.12 Baseline semantics

The baseline is setup-bound. It represents the direct timing difference between the selected physical loops under the current measurement configuration.

If the audio device, sample rate, channel assignments or physical cabling changes, establish a new baseline. Reusing an old baseline after changing the setup can produce a very repeatable but systematically wrong DUT result.

The baseline subtraction can be written conceptually as:

```text
DUT latency =
    measured DUT-vs-reference offset
    - stored direct-loop baseline offset
```

The baseline is not intended to remove the DUT's own filter phase, converter delay or internal transport. Those are part of the DUT path being measured.

## 5.13 Complete-response timing versus transport latency

A filtered DUT deserves special care in interpretation.

Suppose a bypass path measures approximately 1.86 ms. A steep low-pass or band-pass path through the same device may measure many milliseconds later even if the device's basic DSP transport has not changed. The additional timing can arise from the phase/group-delay behavior of the filter itself.

Latency Bench therefore reports **complete-response timing** for the captured path.

If the engineering question is specifically "what is the device's bare transport latency independent of this filter?", measure an appropriate broadband/bypass state or use another method capable of isolating that quantity.

If the engineering question is "when does this filtered output actually arrive relative to the reference?", the complete-response result is exactly the relevant quantity.

## 5.14 Reference physical measurements

The final 1.1.1 qualification included a physical loopback/bypass reference at 48 kHz:

```text
89.15 samples
1.857 ms
standard deviation: 0.000 ms
analysis: normal, 10/10 runs
```

This provides the comparison point for the filtered-path examples below.

### 5.14.1 Representative filtered paths

| DUT condition | Result | Interpretation |
| --- | ---: | --- |
| bypass/cable | 89.15 samples / 1.857 ms | normal analysis |
| LPF qualification case | 110.71 / 2.306 ms | accepted |
| 300-3400 Hz, 24 dB/oct | 95.17 / 1.983 ms | accepted |
| 1 kHz HPF, 48 dB/oct | 133.60 / 2.783 ms | accepted |
| 2 kHz HPF, 48 dB/oct | 90.91 / 1.894 ms | accepted |
| 2-4 kHz, 48+48 dB/oct | 114.05 / 2.376 ms | accepted |
| 20-160 Hz, 24 dB/oct | 383.20 / 7.983 ms | extended, accepted |
| 20-160 Hz, 48+48 dB/oct | 493.18 / 10.275 ms | extended, accepted |

The 20-160 Hz, 48 dB/oct case had approximately `0.006 ms` run-to-run standard deviation and used extended analysis for all ten runs. The 24 dB/oct version had approximately `0.005 ms` standard deviation and likewise used extended analysis for all ten runs.

Relative to the bypass reference, the 20-160 Hz 48 dB/oct response arrives about `404.03 samples / 8.417 ms` later, while the 24 dB/oct response arrives about `294.05 samples / 6.126 ms` later. These differences are consistent with measuring the complete filtered response, including filter phase/group delay, rather than merely a fixed DSP transport delay.

## 5.15 Examples of correctly rejected measurements

Qualification also deliberately exercised cases where one timing interpretation was not sufficiently dominant.

A 2-3 kHz narrow-band case was rejected with a primary candidate around 127.59 samples and a competing candidate around 118.87 samples whose evidence was about 91.6% of the primary.

A 100-500 Hz case was likewise rejected when the competing candidate reached about 92.4% of the primary.

These are successful estimator outcomes. The application refused to convert ambiguous evidence into false precision.

Before magnitude-matched extended analysis was added, a 20-160 Hz 48 dB/oct case could also select a spurious large negative edge candidate. The 1.1.1 overlap-weighted evidence and magnitude-matched extended path were introduced specifically to make such edge/strong-filter cases robust without adding an expected-positive-latency bias.

## 5.16 Reading the result

A strong result combines several kinds of evidence:

- median DUT latency;
- low run-to-run standard deviation;
- sensible minimum and maximum;
- adequate primary correlation/evidence;
- no competing candidate near the 90% rejection threshold;
- a physical result consistent with the DUT state and measurement definition.

Do not use correlation as a generic audio-quality score. A lower correlation can be perfectly legitimate when a DUT intentionally changes spectral magnitude or phase. Its role here is timing evidence.

Likewise, a standard deviation of zero does not prove absolute accuracy. It proves excellent repeatability under the tested conditions.

## 5.17 Troubleshooting an ambiguous or weak measurement

If a measurement is rejected or has weak evidence:

1. verify that Reference and DUT channels are not swapped;
2. verify signal level and make sure neither path clips;
3. confirm that the DUT is actually passing the intended signal;
4. check for feedback, parallel paths or unexpected dry signal;
5. repeat the baseline if the physical setup has changed;
6. allow the automatic extended analysis to complete;
7. inspect whether the DUT response is extremely narrow-band or resonant;
8. consider whether the desired quantity is actually complete-response timing or bare transport latency.

Do not solve ambiguity by simply choosing the numerically convenient peak. The rejection rule exists to prevent exactly that.

## 5.18 Practical examples

### Effects-loop latency

Measure the device in a bypass state, then compare the relevant effects-loop configurations while leaving the measurement interface and reference path unchanged. This can reveal latency contributed by analog send/return conversion and routing even when the inserted loop processing itself is bypassed.

### Modeler or digital processor

Measure a broadband/bypass state first to establish the device's practical transport/reference timing. Then enable individual DSP blocks or signal paths and compare the resulting complete-response timing.

For filters, remember that the difference can include filter group delay rather than only added block scheduling or transport.

### Subwoofer or crossover output

A subwoofer output is a legitimate Latency Bench target. Let automatic extended analysis handle the strongly low-pass response. If the estimator accepts the result with good repeatability and no near-equal competitor, there is no requirement to artificially widen the DUT bandwidth.

Interpret the result as the arrival timing of that filtered output.

## 5.19 Validation scope

Version 1.1.1 qualification included:

- deterministic estimator tests;
- normal and extended analysis;
- overlap-weighted evidence behavior;
- fractional-sample interpolation;
- polarity-insensitive timing selection;
- competing-candidate rejection;
- strongly filtered HPF, LPF and band-pass paths;
- subwoofer-style 20-160 Hz responses;
- repeated physical loopback measurements;
- regression checks confirming ordinary broadband paths remain on normal analysis;
- documentation of accepted and intentionally rejected cases.

The reference measurements demonstrate the estimator on the tested physical setup. They are not universal latency specifications for the devices used in qualification.

## 5.20 Measurement record

For a result worth publishing or comparing later, record:

```text
Latency Bench version
audio interface/device
sample rate
Reference OUT / IN
DUT OUT / IN
probe level
baseline result
DUT identity
DUT state / enabled processing
median latency in samples and ms
mean / min / max / standard deviation
normal or extended-analysis run count
correlation/evidence and competing candidate if relevant
physical wiring notes
```

A latency number without its signal-path definition is rarely enough to reproduce the measurement.

# 6. Matrix Bench

Matrix Bench 2.1.1 for macOS is the suite's low-latency routing, mixing and monitoring environment. It combines physical audio devices, an 8-in/8-out virtual Core Audio device, per-input processing, a crosspoint matrix, independent Main and Aux destinations, snapshots, MIDI control and an always-running headless engine.

Unlike a conventional DAW mixer, Matrix Bench is organized around explicit source-to-destination crosspoints. Main and Aux are first-class destinations in the same matrix rather than fixed copies of a single mix.

<!-- FIGURE PLACEHOLDER: Figure 6.1
Application: Matrix Bench
Subject: Main application window
Show: input strips, crosspoint matrix, Main and Aux destinations, meters, snapshot controls and device selectors.
Crop: Application window only.
Suggested size: full text width
Caption: Matrix Bench 2.1.1 main routing and processing window.
-->

**Figure 6.1.** Matrix Bench 2.1.1 main routing and processing window.

## 6.1 Architecture

Matrix Bench is split into three cooperating parts:

```text
Matrix Bench GUI
      |
      | local control / state
      v
MatrixBenchEngine
      |
      +---- physical Core Audio devices
      |
      +---- Matrix Bench virtual HAL device
```

`MatrixBenchEngine` is the persistent audio engine. It runs independently of the GUI under `launchd`, so audio routing does not depend on keeping the application window open.

The GUI is a controller and status surface for that engine. Closing the GUI does not intentionally stop audio.

The virtual HAL device provides eight input and eight output channels to Core Audio clients and participates in the same routing architecture.

## 6.2 Signal flow

For each physical or virtual input, the signal path is conceptually:

```text
input
  -> raw input meter
  -> polarity inversion
  -> HPF / LPF
  -> matrix crosspoints
       -> Main destination gain / mute -> Main compressor -> Main output
       -> Aux destination gain / mute  -> Aux compressor  -> Aux output
```

Input meters are intentionally taken before the per-input processing. They therefore show the incoming signal rather than the level after INV or filtering.

Each matrix crosspoint has its own gain. Main and Aux also have destination-level gain and mute controls.

## 6.3 Inputs

Each input channel provides:

- input metering;
- polarity inversion (**INV**);
- high-pass filter;
- low-pass filter;
- independent routing/gain to each matrix destination.

The input filters support 6, 12 and 24 dB/octave slopes. Processing occurs before the matrix so all destinations fed from an input receive the same selected input polarity/filter state.

This architecture avoids duplicating input conditioning independently for Main and Aux.

## 6.4 The crosspoint matrix

A crosspoint answers a simple question: **how much of this input is sent to this destination?**

That makes Matrix Bench suitable for both conventional routing and less conventional test/monitor arrangements. A source can feed Main, Aux, both, or neither, and the gain of each path can differ.

The matrix should be treated as the authoritative routing surface. Do not assume that selecting a device automatically creates a useful signal path; the required crosspoints must also be active.

<!-- FIGURE PLACEHOLDER: Figure 6.2
Application: Matrix Bench
Subject: Crosspoint routing
Show: several inputs with different Main/Aux crosspoint gains, including at least one source routed to both destinations and one routed to only one destination.
Crop: Matrix and adjacent input/destination labels only.
Suggested size: full text width
Caption: Each Matrix Bench crosspoint independently controls one input-to-destination path.
-->

**Figure 6.2.** Independent input-to-destination crosspoints.

## 6.5 Main and Aux destinations

Main and Aux are independent first-class destinations. Each has:

- its own matrix crosspoint gains;
- destination gain;
- mute;
- output device/channel configuration;
- output metering;
- independent master compressor.

Aux is an all-channel endpoint rather than a hidden copy of Main.

This makes it possible, for example, to build one monitor mix on Main and a separate measurement, recording or alternate monitoring path on Aux without changing the input processing.

## 6.6 Output devices and channels

Main and Aux can target physical outputs or the Matrix virtual device, subject to feedback-prevention rules.

When changing physical devices, Matrix Bench preserves the selected channel identity where that channel exists on both devices. The purpose is to keep routing stable across device changes rather than silently reinterpreting an old channel number as a different logical destination.

If a device becomes unavailable, the engine is designed to survive the loss and recover when the device returns. Device availability is therefore a runtime condition, not a reason for the entire routing state to be discarded.

## 6.7 Independent output clocks and sample-rate conversion

Main and Aux may involve devices that do not share a hardware clock. Matrix Bench handles independent output clock domains rather than assuming that two selected devices remain sample-synchronous forever.

Where required, the engine performs sample-rate conversion and clock-domain adaptation between the internal routing stream and the destination device.

This matters with combinations such as a professional interface, a fixed-rate modeler and Bluetooth audio. A nominal sample-rate label alone does not establish a common physical clock.

For measurement work, prefer a single known clock domain when possible. Independent-device routing is useful, but asynchronous conversion and device buffering become part of the real system behavior.

## 6.8 The Matrix virtual audio device

The Matrix Bench Core Audio HAL device exposes:

```text
8 inputs
8 outputs
```

to multichannel-aware macOS applications.

All eight channels are available to clients. Conventional stereo pairs 1-2, 3-4, 5-6 and 7-8 can be used by software that supports explicit multichannel selection.

The virtual device is useful for routing audio between Matrix Bench and applications without an external loopback cable.

<!-- FIGURE PLACEHOLDER: Figure 6.3
Application: macOS Audio MIDI Setup
Subject: Matrix Bench virtual audio device
Show: Matrix virtual device selected with its eight input and eight output channels visible.
Crop: Audio MIDI Setup device/channel area only.
Suggested size: approximately 75% text width
Caption: The Matrix Bench virtual Core Audio device exposes eight input and eight output channels.
-->

**Figure 6.3.** Matrix Bench 8×8 virtual Core Audio device.

## 6.9 macOS channel selection

The virtual device is intended to remain usable when the Matrix Bench GUI is not open. Channel configuration therefore cannot depend solely on application-local controls.

macOS-side channel selection, including non-adjacent output assignments available through Audio MIDI Setup speaker configuration, participates in the headless architecture. A configuration such as channels 4 and 8 can be selected where Core Audio exposes that mapping.

The GUI should reflect the effective OS-side configuration when it is open rather than creating a second contradictory routing truth.

For applications that are explicitly multichannel-aware, direct selection of all eight virtual channels remains preferable to relying on a stereo speaker mapping.

## 6.10 Feedback prevention

Virtual routing makes accidental feedback easy. Matrix Bench therefore prevents configurations in which the Matrix virtual device would be used simultaneously as both Main and Aux in a way that creates an unsafe/undefined routing loop.

A rejected device selection is intentional protection, not a hot-plug failure.

When designing a more complicated inter-application route, trace the complete signal path from source to destination before enabling crosspoints. A virtual cable is still a cable from a feedback point of view.

## 6.11 Headless engine

`MatrixBenchEngine` is installed as an always-running user service with launchd label:

```text
works.60n.matrixbench.engine
```

The GUI communicates with the engine through its local control channel. The runtime socket lives under `/tmp` while the service is running.

The important user-visible consequence is simple: **routing can continue without the GUI**.

This is particularly important for the virtual device. Core Audio clients and physical routing should not require a visible Matrix Bench application window merely to keep passing audio.

## 6.12 Persistence

Matrix Bench persists the routing and processing state needed to restore the working system, including:

- selected input/output devices and channels;
- matrix crosspoint gains;
- destination gains and mutes;
- input INV state;
- HPF/LPF state and settings;
- compressor state/settings;
- snapshot definitions and names;
- MIDI assignments where applicable.

Restoration is designed to preserve logical routing identity across device availability changes rather than collapsing the configuration when a device is temporarily absent.

## 6.13 Snapshots

Four snapshots, **SS1–SS4**, provide fast recall of routing and processing state.

Snapshot names are editable. Right-click renames a snapshot, and the UI indicates when a snapshot is being applied.

Snapshot recall is designed to be atomic from the user's perspective. Earlier development exposed multiple audible intermediate transitions while device, routing, mixer and DSP state were restored separately. The qualified implementation applies the state as one coordinated transition so the listener does not hear a sequence of temporary configurations.

A snapshot can include routing, gains, mutes, INV, filters and other persisted processing state rather than being merely a matrix preset.

<!-- FIGURE PLACEHOLDER: Figure 6.4
Application: Matrix Bench
Subject: Snapshot controls
Show: SS1-SS4 with user-edited names and enough surrounding UI to establish their location.
Crop: Snapshot/control area only.
Suggested size: approximately 65% text width
Caption: Four named snapshots provide coordinated recall of routing and processing state.
-->

**Figure 6.4.** Matrix Bench snapshot controls.

## 6.14 MIDI control

Matrix Bench supports MIDI control and MIDI Learn for relevant routing/mixer actions.

The MIDI menu groups learn/clear operations and controllable parameter types such as Gain, Polarity and Mute. A global **Forget all** action clears learned assignments, and MIDI channel selection limits the control source where required.

Snapshot recall can also be learned. Option-click is used for snapshot MIDI Learn.

MIDI control changes the same engine state as GUI control; it is not a separate parallel mixer.

For diagnosing controller traffic before assigning it, MIDI Bench is the companion tool in the suite.

## 6.15 Main and Aux compressors

Main and Aux each have an independent studio-style master compressor. Compression is destination-specific and occurs after the matrix/destination mix.

Each compressor provides:

- bypass;
- threshold;
- attack;
- release;
- makeup gain;
- gain-reduction metering.

Detailed controls are kept behind the compressor/options interface so the main matrix remains readable.

The compressors are intended as practical output dynamics controls for music, speech and monitoring, not as hidden safety limiters. Bypass them when a measurement requires an unmodified amplitude path.

## 6.16 Gain-reduction metering

Each destination compressor has a gain-reduction meter distinct from the normal signal-level meter.

Gain reduction uses a negative-dB convention and is displayed top-down, making increasing compression visually different from increasing signal level. The meter is UI-smoothed independently of the audio processing.

As with the other meters, the display is a monitoring aid. The DSP state and signal path, not the meter animation, define the actual processing.

## 6.17 Metering

Matrix Bench provides input and destination meters with subtle engineering scales.

Input meters are pre-input-DSP. Main/Aux meters represent their destination signal path. Gain-reduction meters show compressor action.

Meter ballistics are intentionally smoothed enough to remain readable rather than reacting as raw sample-peak oscilloscopes. Meter smoothing does not alter the audio.

## 6.18 Buffer size

The supported buffer-size choices are:

```text
16
32
64
128
256
512 samples
```

The requested buffer size and the actual callback behavior must not be confused with an arbitrary fixed HAL property.

During HAL development, the virtual device initially exposed a fixed 512-frame `gBufferFrameSize` even when clients requested much smaller buffers. Qualification work established that the relevant I/O operation uses the actual `ioBufferFrameSize`, and the production architecture/tests were brought into agreement with the supported variable-size behavior.

A buffer-size control is therefore meaningful, but it still does not by itself equal end-to-end latency.

## 6.19 Buffer size versus physical latency

Physical latency includes more than one callback block:

```text
application / engine buffering
+ driver / safety buffering
+ D/A conversion
+ external physical path
+ A/D conversion
+ any SRC / clock-domain adaptation
```

A 16-sample request at 48 kHz is only about 0.333 ms of sample time. It does not imply a 0.333 ms physical round trip.

Matrix Bench's virtual routing can also introduce different behavior from a direct physical path because Core Audio clients, the HAL driver and the engine participate in the route.

Use Latency Bench or the documented physical loopback procedure when the engineering question is actual path latency.

## 6.20 Physical loopback latency qualification

Matrix Bench includes documented physical round-trip testing using a persistent Core Audio client. The same client requests a buffer size, starts its IOProc, verifies callback size, measures the physical loopback and is then destroyed.

The qualified buffer set is:

```text
16 / 32 / 64 / 128 / 256 / 512
```

Physical qualification used the RME Babyface Pro at 48 kHz with a direct analog loopback from an output to an input.

The purpose of the test is not merely to prove that `SetBufferFrameSize` returns success. It verifies the behavior while a real client remains alive and processing audio.

## 6.21 HAL callback qualification

The virtual driver has dedicated HAL callback tests in addition to physical loopback tests. These exercise client callback behavior and buffer-size handling independently of the GUI.

This distinction is important:

- a HAL unit/callback test validates driver/client mechanics;
- a physical loopback test validates real end-to-end timing through hardware;
- a subjective listening test can expose practical problems but is not a replacement for either.

The production qualification requires the relevant automated HAL tests and the documented physical validation to pass.

## 6.22 Hot-plug and unavailable devices

The engine is designed for devices to disappear and return without requiring the routing configuration to be rebuilt from scratch.

When an input or Main/Aux output disappears, its logical identity is retained so that it can recover when the same device becomes available again.

For a headless system this behavior is essential. A temporary USB or Bluetooth disconnect must not require opening the GUI and manually reconstructing the entire matrix.

## 6.23 Device-specific considerations

The qualification environment has included:

- RME Babyface Pro;
- Neural DSP Quad Cortex;
- JBL Tune 530BT;
- Mac internal audio;
- Matrix Bench virtual 8×8 device.

These devices deliberately exercise different constraints. The Quad Cortex operates at 48 kHz. The tested JBL Bluetooth path operates at 44.1 kHz and brings Bluetooth buffering into the system. The Babyface supports flexible professional-interface operation and was used for physical loopback qualification.

These are validation examples, not an exclusive compatibility list.

## 6.24 CLI control

The development/install architecture includes `matrixbenchctl` for command-line interaction with the engine.

It is primarily an engineering/service interface rather than the normal end-user control surface. Most users should configure routing through Matrix Bench itself or through learned MIDI control.

The handbook therefore documents the existence and architectural role of `matrixbenchctl` without making direct CLI operation a prerequisite for using the installed suite.

## 6.25 Installation

The intended macOS suite location is:

```text
/Applications/60°N Signal Works Audio Bench Suite
```

Matrix Bench installation also supplies the components required by the headless engine and virtual Core Audio device.

Because the engine and HAL component outlive the GUI process, installation and removal must be treated as system integration rather than simply copying or deleting one `.app` bundle.

The current individual Matrix package is version 2.1.1. Suite-level installer consolidation is a separate distribution task and does not change the architecture described here.

## 6.26 Practical routing workflows

### Independent monitor and measurement outputs

Route the required sources to Main for monitoring and create a different set of Aux crosspoints for the measurement or recording path. Keep the input DSP common unless the experiment specifically requires a different source treatment.

### Feed another macOS application

Route the desired matrix destination to the Matrix virtual device and select the corresponding virtual channels in the receiving application. Verify the direction carefully and avoid routing the receiving application's return back into the same virtual path unless feedback is explicitly intended and controlled.

### Recall a test configuration

Build the complete device, channel, matrix, mute, gain and processing state, save it to SS1–SS4 and give the snapshot a descriptive name. Recall should then restore the coordinated state rather than requiring a sequence of manual changes.

### MIDI-controlled comparison

Use MIDI Learn for the required gains, mutes, polarity or snapshot recalls. Validate the controller messages in MIDI Bench first when the source device or channel is uncertain.

### Headless always-on route

Configure and verify the route in the GUI, close Matrix Bench and confirm that audio continues through `MatrixBenchEngine`. Reopen the GUI to verify that it reflects the current engine state rather than starting a second independent routing session.

## 6.27 Troubleshooting

### No audio although the device is selected

Check the matrix crosspoints as well as the device/channel selectors. A selected destination does not imply that any input is routed to it.

### Device selection is rejected

Check whether the Matrix virtual device would be used in an unsafe simultaneous Main/Aux configuration. A rejection can be deliberate feedback prevention.

### A device disappeared

Leave the logical configuration intact if the disconnect is temporary. The engine is designed to recover the device when it returns.

### Bluetooth path feels late

Bluetooth adds its own buffering and may also force a different sample-rate/clock-domain path. A small Matrix buffer does not remove downstream Bluetooth latency.

### Virtual route has more latency than expected

Verify actual client callback/buffer behavior and distinguish virtual-driver latency from physical-device round-trip latency. Use the appropriate HAL tests or Latency Bench rather than estimating from the selected buffer size alone.

### Routing changes after swapping devices

Confirm that the intended channel exists on both devices and inspect the effective channel identity. Matrix Bench preserves valid channel identity rather than intentionally remapping every device to a generic first stereo pair.

## 6.28 Validation scope

Matrix Bench 2.1.1 qualification covers the application, persistent engine, physical-device routing and virtual HAL architecture together.

Relevant validation includes:

- GUI-to-engine operation and persistence;
- audio continuing without the GUI;
- launchd engine startup;
- physical-device hot-plug and return;
- Main/Aux routing and feedback prevention;
- virtual-device 8×8 operation;
- multichannel and stereo-pair use;
- OS-side non-adjacent speaker/channel selection;
- snapshot persistence and coordinated recall;
- MIDI Learn and snapshot recall;
- Main/Aux compressor operation and gain-reduction metering;
- supported buffer-size handling;
- HAL callback tests;
- persistent-client physical loopback latency tests;
- representative fixed- and variable-rate physical devices.

The validation demonstrates the qualified implementation under the tested configurations. It does not imply that every third-party Core Audio application, aggregate device or Bluetooth stack has identical buffering behavior.

## 6.29 Measurement and routing record

For a Matrix Bench configuration that needs to be reproduced, record:

```text
Matrix Bench version
engine / virtual-device version where relevant
input device and channels
Main device and channels
Aux device and channels
sample rate
buffer size
matrix crosspoint gains
input INV / HPF / LPF settings
Main/Aux gain and mute
compressor settings/bypass
snapshot name if used
MIDI assignments if relevant
virtual-channel mapping
physical wiring
```

For latency-sensitive work, add the measured physical or virtual path latency rather than assuming it from the selected buffer size.

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
