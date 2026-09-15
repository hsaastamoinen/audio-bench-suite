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
