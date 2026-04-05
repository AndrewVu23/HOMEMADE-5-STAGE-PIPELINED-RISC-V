# RISCOF

This document covers everything about how I set up and ran the RISC-V architectural
compliance tests (RISCOF) for this 5-stage pipelined RV32I processor.

---

## Table of Contents

1. [What is RISCOF?](#1-what-is-riscof)
2. [How RISCOF Works](#2-how-riscof-works)
3. [The Challenge: Our Processor vs What RISCOF Expects](#3-the-challenge-our-processor-vs-what-riscof-expects)
4. [Design Decisions](#4-design-decisions)
5. [Files We Created](#5-files-we-created)
6. [The Testbench: Riscof_tb.sv](#6-the-testbench-riscof_tbsv)
7. [The DUT Plugin: riscof_homemade_rv32i.py](#7-the-dut-plugin-riscof_homemade_rv32ipy)
8. [The Per-Test Pipeline](#8-the-per-test-pipeline)
9. [Why FENCE Passes Without Implementation](#9-why-fence-passes-without-implementation)
10. [Running the Tests](#10-running-the-tests)

---

## 1. What is RISCOF?

RISCOF (RISC-V Compatibility Framework) is the official tool for verifying that a RISC-V
processor correctly implements the ISA specification. It doesn't test timing, performance,
or pipeline behavior. It only tests **functional correctness**: does each instruction
produce the right result?

It works by **signature comparison**:

1. Run an official test program on the DUT (our own design)
2. Run the same test on a reference (in this case is spike: the golden RISC-V ISA simulator)
3. Both write results to a **signature**, a region of memory filled with computed values
4. If the signatures match byte-for-byte, the test passes

The test suite (`riscv-arch-test`) is maintained by RISC-V International. For our RV32I, there
are 38 tests, one per instruction (add, sub, beq, jal, etc.) plus fence.

---

## 2. How RISCOF Works

<p align="center"> <img width="800" height="474" alt="image" src="https://github.com/user-attachments/assets/8f9be28d-c9d5-4425-a225-4096195a97d7" > </p>

While the process looks complicated (cause it is), we are going to focus only on the execution:

<p align="center"> <img width="400" height="1500" alt="image" src="https://github.com/user-attachments/assets/6cd21fb5-e31c-4f73-8604-4122791b8cd7" > </p>

RISCOF is essentially a test orchestrator. It:

1. Reads `config.ini` to find the DUT and reference plugins
2. Reads the ISA YAML to know which tests to run 
3. Calls each plugin's `runTests()` method, which generates a Makefile
4. Runs both Makefiles (DUT and reference in parallel)
5. Compares the resulting `.signature` files
6. Generates `report.html`

**The plugins are where all the work happens.** Each plugin is a Python class that knows
how to compile a test, run it on its target, and produce a signature file. The DUT plugin
compiles for iverilog, the spike plugin compiles for spike, and they use different linker
scripts, different base addresses, different everything. RISCOF doesn't care, it just
compares the signatures.

---

## 3. The Challenge: Our Processor vs What RISCOF Expects

The arch tests assume a pretty standard environment. Our processor differs in several ways:

| What RISCOF expects | What our processor has | Gap |
|---------------------|----------------------|-----|
| Von Neumann (unified memory) | Harvard (separate Instr_Mem + Data_Mem) | Tests put code and data in one address space |
| Base address `0x80000000` | PC resets to `0x00000000` | Tests are linked for the wrong address |
| Large memory (some tests are 1.7MB) | Originally 1024 words (4KB) | Tests won't fit |
| Halt mechanism (write to `tohost`) | No halt - just loops forever | No way to know when a test is done |
| Signature dumping | No file I/O | Need testbench to extract results |

Every one of these gaps required a design decision.

---

## 4. Design Decisions

### 4a. Harvard Architecture Workaround

**Problem**: Our processor has separate instruction and data memories. The arch tests
assume a single address space, where the same addresses hold both code and data.

**Options considered**:
- **Unified memory**: Replace Instr_Mem and Data_Mem with a single memory module,
  restructure the processor ports. Correct, but invasive, which changes the actual processor.
- **Load into both**: Keep the processor unchanged, have the testbench load the same hex
  file into both Instr_Mem and Data_Mem.

**Decision**: Load into both. The processor fetches instructions from Instr_Mem and
reads/writes data from Data_Mem. Both start with identical contents. Stores only modify
Data_Mem (which is where the signature lives). Instructions in Instr_Mem are never
modified, but that is fine cause the tests don't do self-modifying code.

```systemverilog
// In Riscof_tb.sv:
$readmemh(firmware_file, dut.Instr_Mem_module.ROM);  // instructions
$readmemh(firmware_file, dut.Data_Mem_module.RAM);   // data + signature
```

**Why this works**: The test program writes results to memory addresses in the signature
region. Those writes go to Data_Mem (through the store pipeline). When the testbench dumps
the signature, it reads from Data_Mem. The Instr_Mem is read-only during execution, which
only serves instruction fetches.

### 4b. Base Address: 0x00000000 Instead of 0x80000000

**Problem**: Spike and the standard RISC-V test environment use `0x80000000` as the base
address. Our processor's PC resets to `0x00000000`.

**Options considered**:
- **Option A**: Change the DUT linker script to `0x00000000`
- **Option B**: Modify the processor to start at `0x80000000` or add address translation

**Decision**: Option A - change the linker script. This means:

- **DUT linker script** (`homemade_rv32i/env/link.ld`): base at `0x00000000`
- **Spike linker script** (`spike/env/link.ld`): base at `0x80000000` (unchanged)

Each plugin compiles tests with its own linker script. The instructions execute the same
operations, just at different absolute addresses. The signature values are the same because
they are computed results (additions, comparisons, etc.), not addresses.

```
# DUT link.ld                    # Spike link.ld
. = 0x00000000;                  . = 0x80000000;
.text.init : { ... }             .text.init : { ... }
```

**Why each plugin needs its own linker script**: Spike is hardwired to boot at `0x80000000`.
This processor is hardwired to boot at `0x00000000`. They each need code placed at their
own starting address. The tests produce the same signature regardless of where they run, and
the computed values don't depend on absolute code addresses (with one exception: AUIPC
and JAL store `PC+4` values, but the tests account for this).

### 4c. Memory Expansion

**Problem**: Our memories were originally `[0:1023]` - 1024 words = 4KB. The arch tests
are much larger.

**Test sizes**:

| Test | Binary Size | Words Needed |
|------|------------|--------------|
| add-01.S | 27 KB | 6,804 |
| beq-01.S | 240 KB | 60,048 |
| jal-01.S | 1.7 MB | 441,448 |

The branch and jump tests are huge because they test maximum offset ranges. To test a JAL
jumping +512KB forward, the test literally inserts **hundreds of thousands of NOPs** to
create that distance. This is a [known property](https://github.com/riscv-non-isa/riscv-arch-test/issues/157)
of the arch-test suite. There is no way around it.

**Decision**: Expand both memories to `[0:524287]`. Address indexing
changed from `[11:2]` (10-bit, selects from 1024 words) to `[20:2]` (19-bit, selects from
524,288 words).

This only affects simulation. In synthesis, you'd size the memory for your
actual target (FPGA block RAM, etc.)

### 4d. Halt Mechanism: Monitoring `tohost`

**Problem**: The arch tests signal "I'm done" by writing `1` to a memory address called
`tohost`. Our processor has no concept of halting.

**Solution**: The RISCOF testbench monitors the `tohost` address in Data_Mem every clock
cycle. When it sees the value `1`, it knows the test has finished and dumps the signature.

**Complication**: The `tohost` address isn't fixed. It depends on the test size. The
linker places `.tohost` after `.text.init` with `ALIGN(0x1000)`, so its address varies:

| Test | .text.init size | tohost address |
|------|----------------|----------------|
| add-01.S | 0x3340 | 0x4000 |
| beq-01.S | 0x372E0 | 0x38000 |
| jal-01.S | 0x1ACC60 | 0x1AD000 |

We extract `tohost` from the ELF at runtime using `riscv64-unknown-elf-nm` and pass it to
the testbench as a `+tohost_addr=` plusarg:

```bash
# In the plugin:
tohost_addr=$(riscv64-unknown-elf-nm my.elf | grep ' tohost$' | awk '{print $1}')
vvp sim.vvp +tohost_addr=0x${tohost_addr} ...
```

```systemverilog
// In the testbench:
$value$plusargs("tohost_addr=0x%h", tohost_addr);
// ...
if (dut.Data_Mem_module.RAM[tohost_addr[20:2]] == 32'd1) begin
    dump_signature();
    $finish;
end
```

### 4e. ELF to Hex Conversion

**Problem**: `$readmemh` in Verilog needs a hex file with one word per line. The standard
`objcopy -O verilog` produces **byte-level** hex (one byte per address), which doesn't
match our 32-bit word arrays.

**Solution**: Two-step conversion:

```bash
# Step 1: ELF -> flat binary
riscv64-unknown-elf-objcopy -O binary my.elf firmware.bin

# Step 2: binary -> word-level hex (little-endian 32-bit words)
python3 -c "
data = open('firmware.bin','rb').read()
f = open('firmware.hex','w')
for i in range(0, len(data), 4):
    word = int.from_bytes(data[i:i+4], 'little')
    f.write('%08x\n' % word)
f.close()
"
```

The result is one 8-character hex word per line - exactly what `$readmemh` expects for a
`logic [31:0] array[]`.

### 4f. The -mno-relax Flag

**Problem**: Even when compiling with `-march=rv32i` (no C extension), the RISC-V linker
may insert 16-bit compressed instructions as alignment padding through a process called
"linker relaxation." Our processor only handles 32-bit instructions.

**What happens without it**: The linker inserts `c.nop` (`0x0001`, a 2-byte compressed
NOP) as padding. When our processor fetches the 32-bit word at that address, it gets
`0x00130001` which is the 2-byte `c.nop` mashed together with half of the next instruction. From
that point on, every instruction fetch is misaligned and the processor executes garbage.

**Solution**: `-mno-relax` disables linker relaxation entirely. All padding uses 32-bit
`nop` (`0x00000013`).

This flag is needed in **both** the DUT and spike plugins. Without it, spike traps on the
compressed instruction (`trap_illegal_instruction` because `--isa=rv32i` doesn't include
the C extension), and our DUT silently corrupts execution.

---

## 5. Files We Created

### Directory Structure

```
riscof/
├── config.ini                          # RISCOF configuration
├── run.sh                              # One-click test runner
├── RISCOF.md                           # This file
├── README.md                           # Quick reference
├── .gitignore                          # Excludes cloned test suite + work dir
│
├── homemade_rv32i/                     # DUT plugin
│   ├── riscof_homemade_rv32i.py        # Python automation
│   ├── homemade_rv32i_isa.yaml         # ISA spec (RV32I)
│   ├── homemade_rv32i_platform.yaml    # Platform spec (reset at 0x0)
│   └── env/
│       ├── link.ld                     # Linker script (base 0x00000000)
│       └── model_test.h                # RVMODEL macros
│
├── spike/                              # Reference plugin
│   ├── riscof_spike.py                 # Python automation
│   └── env/
│       ├── link.ld                     # Linker script (base 0x80000000)
│       └── model_test.h                # RVMODEL macros
│
├── riscv-arch-test/                    # [git-ignored] Cloned on first run
└── riscof_work/                        # [git-ignored] Test artifacts + report

tb/
├── Riscof_tb.sv                        # RISCOF specific testbench
```

### 5a. config.ini

Tells RISCOF which plugins to use and where to find them:

```ini
[RISCOF]
ReferencePlugin=spike
ReferencePluginPath=spike
DUTPlugin=homemade_rv32i
DUTPluginPath=homemade_rv32i

[homemade_rv32i]
pluginpath=homemade_rv32i
ispec=homemade_rv32i/homemade_rv32i_isa.yaml
pspec=homemade_rv32i/homemade_rv32i_platform.yaml
target_run=1

[spike]
pluginpath=spike
ispec=homemade_rv32i/homemade_rv32i_isa.yaml    # spike uses OUR ISA spec
pspec=homemade_rv32i/homemade_rv32i_platform.yaml
target_run=1
```

Note: both plugins point to the **same** ISA YAML. This ensures RISCOF selects the same
tests for both. Spike is the unmodified golden reference. We only provide a thin plugin
wrapper that tells RISCOF how to invoke it.

### 5b. ISA YAML (homemade_rv32i_isa.yaml)

```yaml
hart_ids: [0]
hart0:
  ISA: RV32I
  physical_addr_sz: 32
  User_Spec_Version: '2.3'
  supported_xlen: [32]
```

 ISCOF uses this to filter the test suite. It only runs tests for extensions we
claim to support.

### 5c. Platform YAML (homemade_rv32i_platform.yaml)

```yaml
mtime:
  implemented: false
mtimecmp:
  implemented: false
nmi:
  label: nmi_vector
reset:
  address: 0x00000000
```

Declares: no timer peripherals, reset at address 0.

### 5d. Linker Script (homemade_rv32i/env/link.ld)

```
OUTPUT_ARCH( "riscv" )
ENTRY(rvtest_entry_point)

SECTIONS
{
  . = 0x00000000;                 <-- our base address (not 0x80000000)
  .text.init : { *(.text.init) }  <-- test code
  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }        <-- halt signal lives here
  . = ALIGN(0x1000);
  .text : { *(.text) }
  . = ALIGN(0x1000);
  .data : { *(.data) }            <-- signature region is in .data
  .data.string : { *(.data.string)}
  .bss : { *(.bss) }
  _end = .;
}
```

The `ALIGN(0x1000)` between sections means `.tohost` always starts on a 4KB boundary.
Since `.text.init` varies in size per test, `tohost` ends up at different addresses.

### 5e. Model Test Header (homemade_rv32i/env/model_test.h)

This is the most important file. The arch tests use these macros to interact with the
test environment:

```c
// HALT: test writes 1 to tohost, then spins forever.
// The testbench detects the write and calls $finish.
#define RVMODEL_HALT                       \
  li x1, 1;                                \
  write_tohost:                            \
    sw x1, tohost, t5;                     \
    j write_tohost;

// BOOT: empty. processor boots from reset, no setup needed.
#define RVMODEL_BOOT

// DATA_BEGIN / DATA_END: mark the signature region.
// RISCOF extracts this region and compares it between DUT and reference.
#define RVMODEL_DATA_BEGIN                  \
  RVMODEL_DATA_SECTION                      \
  .align 4;                                 \
  .global begin_signature; begin_signature:

#define RVMODEL_DATA_END                    \
  .align 4;                                 \
  .global end_signature; end_signature:
```

The `RVMODEL_DATA_SECTION` macro creates the `tohost`/`fromhost` symbols in the `.tohost`
section, and `begin_regstate`/`end_regstate` for register state.

All `RVMODEL_IO_*` macros are empty. Our processor has no debug output.

---

## 6. The Testbench: Riscof_tb.sv

The RISCOF testbench (`tb/Riscof_tb.sv`) is separate from the unit testbench. It:

1. Reads plusargs firmware path, signature addresses, tohost address, output file
2. Loads the hex file into both memories
3. Runs the processor with a 500K cycle timeout
4. Monitors tohost every cycle for the halt signal
5. Dumps the signature to a file

We use 500k cycles timeout. The largest test (jal-01) has ~441K instructions plus pipeline
overhead. 500K cycles gives enough headroom.

---

## 7. The DUT Plugin: riscof_homemade_rv32i.py

The DUT plugin is a Python class that RISCOF calls to compile and run tests. It extends
`pluginTemplate` and implements three methods:

### `__init__`: Setup

```python
# RTL directory is two levels up from this file:
# riscof/homemade_rv32i/riscof_homemade_rv32i.py -> ../../ -> repo root
self.rtl_dir = os.path.abspath(
    os.path.join(os.path.dirname(__file__), '../..'))
```

### `initialise`: Compile command template

```python
self.compile_cmd = (
    'riscv64-unknown-elf-gcc -march={0} -mno-relax '
    '-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g '
    '-T ' + self.pluginpath + '/env/link.ld '
    '-I ' + self.pluginpath + '/env/ '
    '-I ' + archtest_env + ' {1} -o {2} {3}'
)
```

Note: we always use `riscv64-unknown-elf-gcc` even for 32-bit targets. The `-march=rv32i`
flag handles the ISA selection. Some systems only have the `riscv64-` prefix toolchain.

### `runTests`: The main loop

For each test, generates a 6-step shell command (all chained with `;`):

1. `gcc` compile the test `.S` file into an ELF
2. `objcopy` convert ELF to flat binary
3. `python3` convert binary to word-level hex
4. `nm` extract symbol addresses from ELF
5. `iverilog` compile the RTL + testbench
6. `vvp` run the simulation

All commands are written into a Makefile, then executed with `make -k`.

---

## 8. The Per-Test Pipeline

For each of the 38 tests, here's what happens end-to-end:

### Step 1: Compile

```bash
riscv64-unknown-elf-gcc -march=rv32i -mno-relax -mabi=ilp32 \
    -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g \
    -T homemade_rv32i/env/link.ld \
    -I homemade_rv32i/env/ \
    -I riscv-arch-test/riscv-test-suite/env \
    add-01.S -o my.elf \
    -DTEST_CASE_1=True -DXLEN=32
```

This compiles the test assembly into an ELF binary linked at `0x00000000`.

### Step 2: ELF to Binary

```bash
riscv64-unknown-elf-objcopy -O binary my.elf firmware.bin
```

Strips all ELF headers, produces a flat binary image.

### Step 3: Binary to Word Hex

```bash
python3 -c "
data=open('firmware.bin','rb').read()
f=open('firmware.hex','w')
[f.write('%08x\n'%int.from_bytes(data[i:i+4],'little'))for i in range(0,len(data),4)]
f.close()
"
```

Converts to one 32-bit hex word per line (little-endian). Example output:

```
7d5c0837      <-- lui a6, 0x7d5c0
ddb80813      <-- addi a6, a6, -549
00785893      <-- srli a7, a6, 7
...
```

### Step 4: Extract Addresses

```bash
begin_sig=$(riscv64-unknown-elf-nm my.elf | grep 'begin_signature' | awk '{print $1}')
end_sig=$(riscv64-unknown-elf-nm my.elf | grep 'end_signature' | awk '{print $1}')
tohost_addr=$(riscv64-unknown-elf-nm my.elf | grep ' tohost$' | awk '{print $1}')
```

`nm` lists all symbols in the ELF. We extract three addresses:
- `begin_signature` / `end_signature` - the memory region to dump
- `tohost` - where the test writes `1` to signal completion

### Step 5: Compile RTL

```bash
iverilog -g2012 -I pkg -o sim.vvp \
    pkg/signals_pkg.sv src/*.sv tb/Riscof_tb.sv
```

Compiles the entire processor + RISCOF testbench into an iverilog simulation.

### Step 6: Simulate

```bash
vvp sim.vvp \
    +firmware=firmware.hex \
    +begin_signature=0x00006110 \
    +end_signature=0x00006a50 \
    +tohost_addr=0x00004000 \
    +signature_file=DUT-homemade_rv32i.signature
```

Runs the simulation. Output looks like:

```
RISCOF Testbench
  Firmware:        firmware.hex
  Signature file:  DUT-homemade_rv32i.signature
  Begin signature: 0x00006110
  End signature:   0x00006a50
  Tohost address:  0x00004000 (word index 4096)
Reset released at time 16000
HALT detected (tohost=1) at cycle 3273
Dumping signature from 0x00006110 to 0x00006a50
Signature written to DUT-homemade_rv32i.signature
```

The signature file contains one hex word per line:

```
6f5ca309
80000000
00040000
fdfffffe
...
```

RISCOF then diffs this against the reference signature from Spike.

---

## 9. Why FENCE Passes Without Implementation

FENCE (opcode `0001111`) is included in the 38 tests but we never explicitly implemented
it. Here's why it passes:

Our Control Unit has a `default` case for unknown opcodes:

```systemverilog
default: begin
    d_RegWrite = 0; d_ALUSrc = 0; d_MemWrite = 0;
    d_ResultSrc = 0; d_Branch = 0; d_Jump = 0; d_JALRSrc = 0;
    d_ImmSrc = 3'b000; ALUOp = 2'b00;
end
```

FENCE hits this default: no register write, no memory write, no branch, no jump. It flows
through the pipeline as a harmless bubble - it does nothing.

For a single-core, in-order processor with no cache, this is architecturally correct.
In our processor, memory operations already execute in order (the pipeline stalls on hazards),
so the ordering guarantee is trivially satisfied.

---

## 10. Running the Tests

### From the repo root:

```bash
make riscof       # run all 38 compliance tests
make report       # open report.html in the browser
make clean        # wipe everything (test suite + results)
```

### From the riscof directory:

```bash
cd riscof/
riscof arch-test --clone  # one-time setup (~1.5GB)
./run.sh                  # run all 38 tests
./run.sh clean            # wipe results and re-run
```

### Prerequisites:

```bash
# macOS
brew install icarus-verilog riscv-gnu-toolchain riscv-isa-sim pipx
pipx install riscof

# Linux
apt install iverilog gcc-riscv64-unknown-elf
pip install pipx && pipx install riscof
# spike: build from source (https://github.com/riscv-software-src/riscv-isa-sim)
```
