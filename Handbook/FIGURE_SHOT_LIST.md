# Audio Bench Suite Handbook: Figure and Screenshot Production List

**Publication source:** `Audio-Bench-Suite-Handbook.md`  
**Scope:** final real screenshots and manually prepared diagrams for the macOS handbook  
**Required figures:** 17

This is the production checklist for replacing the handbook's figure placeholders. No generated or mock UI should be used. Application figures must be captured from the actual qualified macOS versions documented by the handbook. Diagram figures are to be drawn manually from the stated content rather than generated from an invented UI.

## Capture rules

- Capture the actual qualified macOS application version named by the handbook.
- Use a clean, representative state with no unrelated windows, notifications or personal information visible.
- Preserve readable control labels, values, meters and result text required by the **Show** field.
- Do not crop away context needed to understand the figure.
- Do not upscale a small screenshot merely to fill the page; recapture at a useful native size.
- Keep macOS display scaling consistent across screenshots where practical.
- Use PNG for application screenshots and diagrams unless the final publication workflow has a specific reason to use another lossless format.
- The final DOCX should replace each placeholder with the corresponding numbered figure and retain the final caption below it.

## Production checklist

### Figure 1.1: Installed Bench applications

- **Bench/application:** Audio Bench Suite
- **Asset type:** Real application screenshot
- **Exact screen/state:** Installed Bench applications
- **Must show:** The five current macOS Bench applications together in Finder in the suite installation folder.
- **Crop:** Finder window or suite folder contents only; exclude unrelated desktop items.
- **Suggested relative size:** full text width
- **Final caption:** The five Audio Bench Suite applications installed on macOS.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 3.1: Main application window

- **Bench/application:** Signal Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Main application window
- **Must show:** Signal type, primary generator controls, Output Level, Mute and stereo meters.
- **Crop:** Application window only.
- **Suggested relative size:** full text width
- **Final caption:** Signal Bench 2.0.0 main window and primary signal-generation controls.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 3.2: Measurement stimulus presets

- **Bench/application:** Signal Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Measurement stimulus presets
- **Must show:** Dual Sine controls with the measurement preset selector/menu visible, including the single-tone, SMPTE-style and CCIF choices.
- **Crop:** Application window or relevant control area only.
- **Suggested relative size:** approximately 70% text width
- **Final caption:** Signal Bench measurement presets provide deterministic stimuli matched to common Spectral Bench analyses.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 4.1: Main analyzer window

- **Bench/application:** Spectral Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Main analyzer window
- **Must show:** Spectrum display, input selection, FFT/window/averaging controls, viewport controls and measurement readouts.
- **Crop:** Application window only.
- **Suggested relative size:** full text width
- **Final caption:** Spectral Bench 2.1.0 configured for live spectrum inspection.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 4.2: Zoomed spectrum with cursor measurement

- **Bench/application:** Spectral Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Zoomed spectrum with cursor measurement
- **Must show:** Narrow frequency and dB view, crosshair, fixed Trace/Cursor readout and Input Gain control.
- **Crop:** Application window or spectrum/viewport area only.
- **Suggested relative size:** full text width
- **Final caption:** Spectral Bench viewport and cursor controls can inspect detail without changing calibrated measurement math; Input Gain is the exception and acts on analyzer input samples.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 4.3: Referenced sweep setup

- **Bench/application:** Spectral Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Referenced sweep setup
- **Must show:** Sweep controls, DUT ch selector, two-channel DUT/reference wiring state, Transfer result and phase controls.
- **Crop:** Application window only.
- **Suggested relative size:** full text width
- **Final caption:** Spectral Bench configured for a referenced DUT transfer sweep.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 4.4: Phase reference modes

- **Bench/application:** Spectral Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Phase reference modes
- **Must show:** Phase mode control with Raw, Auto, Manual and Baseline choices, plus Manual delay or Baseline status where applicable.
- **Crop:** Relevant sweep/phase control area and enough graph to show the phase trace.
- **Suggested relative size:** full text width
- **Final caption:** Raw, Auto, Manual and Baseline are explicit phase-reference choices, not interchangeable latency estimators.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 5.1: Main application window

- **Bench/application:** Latency Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Main application window
- **Must show:** selected audio device, Reference OUT/IN, DUT OUT/IN, baseline status, probe level and measurement controls.
- **Crop:** Application window only.
- **Suggested relative size:** full text width
- **Final caption:** Latency Bench 1.1.1 configured for a physical-path DUT measurement.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 5.2: Baseline and DUT physical wiring

- **Bench/application:** Latency Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Baseline and DUT physical wiring
- **Must show:** two manually prepared signal-flow drawings or photographs, one for direct dual-loop baseline and one with the DUT inserted in path B.
- **Crop:** Only the relevant interface, cables and DUT or a clean manually drawn diagram.
- **Suggested relative size:** full text width
- **Final caption:** The baseline measures the two physical loops directly; the DUT measurement inserts the DUT only into path B.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 6.1: Main application window

- **Bench/application:** Matrix Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Main application window
- **Must show:** input strips, crosspoint matrix, Main and Aux destinations, meters, snapshot controls and device selectors.
- **Crop:** Application window only.
- **Suggested relative size:** full text width
- **Final caption:** Matrix Bench 2.1.1 main routing and processing window.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 6.2: Crosspoint routing

- **Bench/application:** Matrix Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Crosspoint routing
- **Must show:** several inputs with different Main/Aux crosspoint gains, including at least one source routed to both destinations and one routed to only one destination.
- **Crop:** Matrix and adjacent input/destination labels only.
- **Suggested relative size:** full text width
- **Final caption:** Each Matrix Bench crosspoint independently controls one input-to-destination path.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 6.3: Matrix Bench virtual audio device

- **Bench/application:** macOS Audio MIDI Setup
- **Asset type:** Real application screenshot
- **Exact screen/state:** Matrix Bench virtual audio device
- **Must show:** Matrix virtual device selected with its eight input and eight output channels visible.
- **Crop:** Audio MIDI Setup device/channel area only.
- **Suggested relative size:** approximately 75% text width
- **Final caption:** The Matrix Bench virtual Core Audio device exposes eight input and eight output channels.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 6.4: Snapshot controls

- **Bench/application:** Matrix Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Snapshot controls
- **Must show:** SS1-SS4 with user-edited names and enough surrounding UI to establish their location.
- **Crop:** Snapshot/control area only.
- **Suggested relative size:** approximately 65% text width
- **Final caption:** Four named snapshots provide coordinated recall of routing and processing state.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 7.1: Main application window

- **Bench/application:** MIDI Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Main application window
- **Must show:** MIDI IN and OUT device selectors, channel controls, Incoming and Outgoing monitors, Pause, Auto-scroll, Raw bytes, Clear and Send controls.
- **Crop:** Application window only.
- **Suggested relative size:** full text width
- **Final caption:** MIDI Bench 2.0.0 combines timestamped MIDI monitoring and manual message transmission.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 7.2: Incoming and Outgoing monitors

- **Bench/application:** MIDI Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Incoming and Outgoing monitors
- **Must show:** timestamped messages in both panes with Raw bytes enabled.
- **Crop:** Monitor panes and their immediate controls only.
- **Suggested relative size:** full text width
- **Final caption:** Separate Incoming and Outgoing monitors provide comparable timestamps and optional raw MIDI bytes.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 7.3: Run from file controls

- **Bench/application:** MIDI Bench
- **Asset type:** Real application screenshot
- **Exact screen/state:** Run from file controls
- **Must show:** selected `.mbmidi` command file plus Browse, Edit, Run, Stop and Syntax controls.
- **Crop:** Command-file section only.
- **Suggested relative size:** approximately 70% text width
- **Final caption:** MIDI Bench command files provide deterministic MIDI sequences with explicit WAIT delays and an optional final LOOP command.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

### Figure 8.1: General cross-Bench DUT workflow

- **Bench/application:** Audio Bench Suite
- **Asset type:** Manually prepared diagram
- **Exact screen/state:** General cross-Bench DUT workflow
- **Must show:** A manually prepared routing diagram with Signal Bench as stimulus source, optional Matrix Bench routing, physical DUT, Spectral Bench and/or Latency Bench measurement path, plus optional MIDI Bench control.
- **Crop:** Diagram only.
- **Suggested relative size:** full text width
- **Final caption:** General Audio Bench Suite workflow separating stimulus, routing, DUT, measurement and optional MIDI control.
- **Status:** [ ] captured/prepared  [ ] checked  [ ] placed

## Final placement check

Before DOCX generation or final screenshot placement, verify that all 17 figures are present, their numbers match the canonical Markdown, captions are unchanged unless the handbook text is edited at the same time, and every screenshot still represents the documented qualified macOS release.
