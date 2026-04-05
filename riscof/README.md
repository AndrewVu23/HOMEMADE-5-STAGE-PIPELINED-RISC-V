# RISCOF Compliance Testing

This directory contains everything needed to run the official RISC-V architectural
compliance tests against the processor using [RISCOF](https://github.com/riscv-software-src/riscof).

## How It Works

RISCOF runs each test on two targets and compares their memory signatures:

1. **DUT (Device Under Test)** - our processor, simulated via Icarus Verilog
2. **Reference** - Spike, the golden RISC-V ISA simulator

For each of the 38 RV32I tests, the flow is:

```
test.S  -->  gcc compile  -->  ELF  -->  objcopy to binary  -->  python to word-hex
                                 |
                                 +--> nm extracts begin_signature, end_signature, tohost
                                 |
                                 v
                          iverilog compile + vvp simulate
                                 |
                                 v
                          DUT.signature  <-->  Reference.signature  -->  PASS/FAIL
```

## Directory Structure

```
riscof/
├── config.ini                          # RISCOF config, points to both plugins
├── run.sh                              # Test runner script
├── README.md                           # This file
├── .gitignore                          # Excludes riscv-arch-test/ and riscof_work/
│
├── homemade_rv32i/                     # DUT plugin
│   ├── riscof_homemade_rv32i.py        # Compiles tests, converts ELF->hex, runs iverilog
│   ├── homemade_rv32i_isa.yaml         # ISA spec: RV32I, 32-bit
│   ├── homemade_rv32i_platform.yaml    # Platform: reset at 0x0, no timers
│   └── env/
│       ├── link.ld                     # Linker script: base at 0x00000000 (not 0x80000000)
│       └── model_test.h                # RVMODEL macros (halt writes to tohost, etc.)
│
├── spike/                              # Reference plugin
│   ├── riscof_spike.py                 # Compiles tests, runs on spike
│   └── env/
│       ├── link.ld                     # Linker script: base at 0x80000000 (spike default)
│       └── model_test.h                # RVMODEL macros for spike
│
├── riscv-arch-test/                    # [git-ignored] Cloned on first run (~1.5GB)
└── riscof_work/                        # [git-ignored] Test artifacts and report
```

## Usage

```bash
# From repo root:
make riscof          # run all 38 tests
make report          # open report.html in browser

# Or directly:
cd riscof/
riscof arch-test --clone  # one-time setup (~1.5GB)
./run.sh                  # run all 38 tests
./run.sh clean            # wipe previous results and re-run
```

## Key Implementation Details

### ELF to Hex Conversion

We can't use `objcopy -O verilog` because it produces byte-level hex, but our memories
are 32-bit word arrays. Instead, the plugin does:

```bash
objcopy -O binary my.elf firmware.bin           # ELF -> flat binary
python3 -c "..."                                # binary -> word-level hex (little-endian)
```

### Makefile Dollar-Sign Escaping

The plugin generates shell commands inside a Makefile. Shell variables like `$(...)` and
`${var}` must be escaped as `$$()` and `$${var}` so Make doesn't eat them. This is handled
in `riscof_homemade_rv32i.py`.

### Dynamic tohost Address

The `tohost` address (where the test writes to signal "I'm done") varies per test depending
on the size of `.text.init`. It's extracted from the ELF symbol table at runtime via
`riscv64-unknown-elf-nm` and passed to the testbench as a `+tohost_addr=` plusarg.
