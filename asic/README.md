# ASIC Synthesis with LibreLane

This directory contains everything needed to synthesize the RV32I processor
into a physical GDSII layout targeting **sky130A** (Skywater 130nm) using
[LibreLane](https://github.com/librelane/librelane).

## Quick Start

### Prerequisites

Install LibreLane via Nix. Follow the official
[LibreLane installation guide](https://librelane.readthedocs.io/en/latest/getting_started/common/nix_installation/index.html).
Once installed, you should have a `shell.nix` at `~/librelane/shell.nix`.

### Running the Flow

```bash
# Enter the LibreLane Nix shell
nix-shell --pure ~/librelane/shell.nix

# Go to the asic directory
cd path/to/HOMEMADE-5-STAGE-PIPELINED-RISC-V/asic

# Option A: High Density library (sky130_fd_sc_hd) — default, 58.8 MHz
librelane config.yaml

# Option B: High Speed library (sky130_fd_sc_hs) — fastest, 95.2 MHz
librelane --scl sky130_fd_sc_hs config_hs.yaml
```

Each run creates a new timestamped directory under `runs/`. The final GDSII
ends up at `runs/<RUN_NAME>/final/gds/Processor.gds`, along with the netlist,
timing reports, metrics, and LVS results.

### Viewing the GDS

The easiest way to view the layout is through the browser — no local tools
needed. Drag and drop `Processor.gds` onto:

**https://gds-viewer.tinytapeout.com/**

You can also open it in KLayout if you have it installed locally.

## What Gets Synthesized

The full processor - pipeline, ALU, hazard unit, register file, control logic,
**and** instruction/data memories (64 words each). This is the complete
`Processor` module, not just the core.

### ASIC Adaptations

The original `src/` files are untouched - simulation and RISCOF testing still
work as before. The `asic/src/` directory contains modified copies of three
files:

| File | Change | Why |
|------|--------|-----|
| `Processor.sv` | Added `probe` output | Original has no outputs - the synthesizer would optimize away the entire design since nothing is observable |
| `Instr_Mem.sv` | 64 words + `$readmemh` | 524K words is too large for standard cells; `$readmemh` initializes from `instructions.hex` |
| `Data_Mem.sv` | 64 words + `$readmemh` | Same as above |

**Why 64 words?** Standard cell synthesis builds memory from flip-flops (~30 um^2
per bit on sky130). 64 words x 32 bits = 2,048 FFs per memory, which is large
but feasible. The original 524K words would need ~16.7 million FFs - physically
impossible. Real chips use SRAM macros (~1 um^2/bit) but integrating them with
open-source tools has known issues (Magic DRC failures on OpenRAM layers).

**Why `$readmemh`?** Without it, the memories synthesize as all zeros. Yosys
(the synthesizer) then proves that an empty processor executing NOPs forever
produces constant-zero outputs, and removes the entire design. Loading
`instructions.hex` prevents this constant-folding.

### Files Excluded

- `Mux_WB_to_Reg.sv` - unused duplicate module
- `signals_pkg.sv` - enum package, no module imports it
- `tb/*.sv` - testbenches (simulation only)

## Directory Structure

```
asic/
  config.yaml              # LibreLane configuration
  pin_order.cfg            # Pin placement
  instructions.hex         # Program loaded into memories at synthesis
  README.md                # This file
  src/
    Processor.sv           # ASIC copy (added probe output)
    Instr_Mem.sv           # 64-word instruction memory
    Data_Mem.sv            # 64-word data memory
  runs/                    # Output (git-ignored)
    RUN_.../final/
      gds/Processor.gds    # GDSII layout (47 MB)
      nl/Processor.nl.v    # Gate-level netlist
      lef/                 # LEF macro interface
      lib/                 # Timing libraries per corner
      metrics.json         # All design metrics
```

## Results

Multiple synthesis runs were performed, progressively optimizing for frequency.
Starting at 40 MHz and reaching **95.2 MHz** through tool tuning, one RTL change,
and switching to the High Speed standard cell library — a **138% frequency improvement**.

### Run Comparison

| | Run 1 | Run 2 | Run 3 | Run 4 | Run 5 |
|--|-------|-------|-------|-------|-------|
| Clock | 25 ns | 20 ns | 18 ns | 18 ns | **17 ns** |
| Frequency | 40 MHz | 50 MHz | 55.6 MHz | 59.3 MHz | **58.8 MHz** |
| Strategy | AREA 0 | AREA 0 | DELAY 0 | DELAY 0 | DELAY 0 |
| RTL change | - | - | - | Posedge reg | Posedge reg |
| Util target | 25% | 25% | 45% | 45% | 45% |
| Cells | 29,278 | 29,265 | 26,182 | 25,661 | **25,674** |
| Die area | 0.723 mm^2 | 0.723 mm^2 | 0.429 mm^2 | 0.427 mm^2 | **0.427 mm^2** |
| Core util | 33.9% | 33.8% | 59.1% | 58.8% | **58.7%** |
| Setup slack | +4.43 ns | +0.69 ns | +0.10 ns | +1.14 ns | **+0.75 ns** |
| Hold slack | +0.11 ns | +0.11 ns | +0.11 ns | +0.11 ns | +0.11 ns |
| Power | 16.49 mW | 20.48 mW | 26.22 mW | 19.90 mW | **21.01 mW** |
| LVS | Clean | Clean | Clean | Clean | Clean |
| Status | Pass | Pass | Pass | Pass | **Pass** |

Also tested 19 ns / AREA 0 (failed, -0.43 ns) and 16 ns / DELAY 0 + posedge
(failed, -0.72 ns), confirming the limits at each stage.

### Phase 2: High Speed Library (sky130_fd_sc_hs)

Switched from `sky130_fd_sc_hd` (High Density) to `sky130_fd_sc_hs` (High Speed)
standard cells. HS cells are physically larger but significantly faster, trading
area for performance.

**Note:** The HS library triggers ~10,000 false-positive Magic DRC errors (known
open-source tooling issue with HS cell layouts). KLayout DRC is clean. Antenna
repair was disabled (`RUN_ANTENNA_REPAIR: false`) because the HS library crashes
OpenROAD's DiodeInsertion step. This chip is not intended for tapeout.

| | HS Run 1 | HS Run 2 | HS Run 3 | HS Run 4 | HS Run 5 |
|--|----------|----------|----------|----------|----------|
| Clock | 15 ns | 12 ns | 11 ns | **10.5 ns** | 10 ns |
| Frequency | 66.7 MHz | 83.3 MHz | 90.9 MHz | **95.2 MHz** | 100 MHz |
| Library | HS | HS | HS | HS | HS |
| Strategy | DELAY 0 | DELAY 0 | DELAY 0 | DELAY 0 | DELAY 0 |
| Cells | 12,960 | ~13,000 | ~13,000 | 12,960 | ~13,000 |
| Die area | 0.551 mm^2 | 0.551 mm^2 | 0.551 mm^2 | 0.551 mm^2 | 0.551 mm^2 |
| Core util | 45.1% | ~45% | ~45% | 45.1% | ~45% |
| Setup slack | +2.34 ns | +1.70 ns | +0.54 ns | **+0.05 ns** | -0.59 ns |
| Hold slack | +0.10 ns | +0.10 ns | +0.10 ns | +0.09 ns | +0.10 ns |
| LVS | Clean | Clean | Clean | Clean | Clean |
| Status | Pass | Pass | Pass | **Pass** | **Fail** |

### Optimization Journey

**Runs 1-2: Baseline with AREA 0**v

Started with a conservative 40 MHz (25 ns). Tightened to 50 MHz (passed with
+0.69 ns slack). AREA 0 strategy uses the smallest standard cells, which
minimize die area but are slower.

**Run 3: Switching to DELAY 0 + tighter floorplan**

`DELAY 0` tells the synthesizer to use faster (but larger) standard cells.
Combined with 45% utilization target (tighter placement = shorter wires), this
reached 55.6 MHz. Die area also shrank from 0.723 to 0.429 mm^2 because
shorter wires compensated for larger cells.

**Runs 4-5: Removing negedge register file write**

STA revealed the critical path went from `w_ResultSrc` (posedge FF) through
MuxWB to the register file write port (negedge FF). Writing on negedge means
the data must arrive within **half** a clock period, not the full period.

The fix in `Reg_File.sv`:
- Changed `always @(negedge clk)` to `always @(posedge clk)` for writes
- Added a bypass mux: if WB is writing the same register that ID is reading
  in the same cycle, forward the write data directly to the read output

This gives the WB result the full clock period to arrive. Results:
- Slack improved from +0.10 ns to +1.14 ns at 18 ns
- Power dropped 25% (no more clock inverter tree for negedge domain)
- Fewer cells (25,674 vs 26,182)
- Pushed clock to 17 ns (58.8 MHz) with +0.75 ns slack remaining

All 32 unit tests and 38/38 RISCOF compliance tests pass with this change.

**Runs 6-10: Switching to sky130_fd_sc_hs (High Speed library)**

The HD library hit its wall at ~59 MHz. Switching to HS cells — which use larger
transistors optimized for speed — immediately unlocked much higher frequencies.
The first HS run at 15 ns had +2.34 ns of slack, suggesting the design could run
far faster. Progressive tightening reached 10.5 ns (95.2 MHz) with just +0.05 ns
slack remaining. At 10 ns the worst corner failed with -0.59 ns.

The HS library produces ~10K false-positive Magic DRC errors (known tooling issue)
and crashes during antenna repair, so both were disabled. KLayout DRC and LVS
remain clean. Cell count dropped from ~25,000 (HD) to ~13,000 (HS) because HS
cells pack more logic per gate.

### Best Run: 10.5 ns (95.2 MHz) — sky130_fd_sc_hs

| Metric | Value |
|--------|-------|
| Library | sky130_fd_sc_hs (High Speed) |
| Standard cells | 12,960 |
| Die area | 0.551 mm^2 (742 x 742 um) |
| Core utilization | 45.1% |
| Max achievable freq | ~95.7 MHz (from slack) |
| LVS | Clean |

**Timing (all 9 IPVT corners):**

| Corner | Setup Slack | Hold Slack | Violations |
|--------|------------|------------|-----------|
| Typical (25C, 1.8V) | +1.78 ns | +0.26 ns | 0 |
| Slow-Slow (100C, 1.6V) | +0.39 ns | +0.62 ns | 0 |
| Max-SS (worst case) | +0.05 ns | +0.62 ns | 0 |
| Min-FF (fastest) | +2.19 ns | +0.09 ns | 0 |

**Signoff:** LVS clean (Netgen), KLayout DRC clean, STA clean (all corners).
Magic DRC reports ~10K errors (false positives from HS library cells — known issue).

### Previous Best (HD library): 17 ns (58.8 MHz)

| Metric | Value |
|--------|-------|
| Library | sky130_fd_sc_hd (High Density) |
| Standard cells | 25,674 |
| Die area | 0.427 mm^2 (653 x 653 um) |
| Core utilization | 58.7% |
| Max achievable freq | 61.5 MHz |
| LVS | Clean |

**Signoff:** All checks pass - DRC (Magic + KLayout), LVS (Netgen), STA (all corners).
Power: 21.01 mW (nominal corner).
