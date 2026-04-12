# HOMEMADE 5-STAGE-PIPELINE RISC-V

<p align="center">
  <img src="https://github.com/user-attachments/assets/334058cc-4280-4ac5-83b5-097ff429da1a" alt="RV32-1" width="900">
  <br>
  <em>5-Stage Pipelined RV32I Datapath (outdated: this was when I only supported 14 instructions)</em>
</p>

<p align="center">
  <img width="900" alt="image" src="https://github.com/user-attachments/assets/980ce243-aa93-44c1-9561-1b24999a63e3" />
  <br>
  <em>RISCOF Testing Report</em>
</p>

<p align="center">
  <img width="730" height="749" alt="image" src="https://github.com/user-attachments/assets/d22ba8d0-5ca2-4c73-824c-8bf1c8aa378c" />
  <br>
  <em>Synthesized Using High Speed Standard Cells (95.2MHz)</em>
</p>

## Quick Start

```bash
make test       # Run the unit testbench (32 hand-written tests)
make riscof     # Run RISCOF compliance suite (38 official RISC-V architectural tests)
make report     # Open the RISCOF HTML report in the browser
make clean      # Clean build artifacts
```

### Prerequisites

| Tool | Install (macOS) | Install (Linux) |
|------|----------------|-----------------|
| Icarus Verilog | `brew install icarus-verilog` | `apt install iverilog` |
| RISC-V Toolchain | `brew install riscv-gnu-toolchain` | `apt install gcc-riscv64-unknown-elf` |
| Spike | `brew install riscv-isa-sim` | Build from [source](https://github.com/riscv-software-src/riscv-isa-sim) |
| RISCOF | `brew install pipx && pipx install riscof` | `pip install pipx && pipx install riscof` |

> Spike and RISCOF are only needed for `make riscof`. The unit testbench only requires Icarus Verilog.
> Spike is the unmodified golden reference model - we don't change it. It runs each test independently
> and produces the reference signature that our processor's output is compared against.

## RISCOF Compliance: 38/38 RV32I Tests Passed

This processor passes all 38 tests in the official RISC-V architectural test suite (`rv32i_m/I`),
verified against the Spike reference model using [RISCOF](https://github.com/riscv-software-src/riscof).
```
add, addi, sub, and, andi, or, ori, xor, xori,
sll, slli, srl, srli, sra, srai,
slt, slti, sltu, sltiu,
beq, bne, blt, bge, bltu, bgeu,
jal, jalr, lui, auipc,
lw, lb, lbu, lh, lhu, sw, sb, sh, fence
```

To run the compliance suite yourself:

```bash
# One-time setup: clone the test suite (~1.5GB)
cd riscof/ && riscof arch-test --clone && cd ..

# Run
make riscof            # runs all 38 tests
make report            # open the HTML report in the browser
```

For the full RISCOF setup walkthrough, see [riscof/RISCOF.md](riscof/RISCOF.md).

## Documentation

| Document | Description |
|----------|-------------|
| [riscof/RISCOF.md](riscof/RISCOF.md) | Full RISCOF setup, design decisions, debugging journey |
| [docs/FPGA_GUIDE.md](docs/FPGA_GUIDE.md) | Running the processor on a DE2-115 FPGA |

## RV32I Instruction Coverage Matrix

| # | Instruction | Type | Opcode | funct3 | funct7 | ALUOp | ALUCon |
|---|-------------|------|--------|--------|--------|-------|--------|
| 1 | `ADD`  | R | 0110011 | 000 | 0000000 | 10 | 00000 |
| 2 | `SUB`  | R | 0110011 | 000 | 0100000 | 10 | 00001 |
| 3 | `SLL`  | R | 0110011 | 001 | 0000000 | 10 | 00111 |
| 4 | `SLT`  | R | 0110011 | 010 | 0000000 | 10 | 00101 |
| 5 | `SLTU` | R | 0110011 | 011 | 0000000 | 10 | 01010 |
| 6 | `XOR`  | R | 0110011 | 100 | 0000000 | 10 | 00100 |
| 7 | `SRL`  | R | 0110011 | 101 | 0000000 | 10 | 01000 |
| 8 | `SRA`  | R | 0110011 | 101 | 0100000 | 10 | 01001 |
| 9 | `OR`   | R | 0110011 | 110 | 0000000 | 10 | 00011 |
| 10| `AND`  | R | 0110011 | 111 | 0000000 | 10 | 00010 |
| 11| `ADDI` | I | 0010011 | 000 | — | 10 | 00000 |
| 12| `SLTI` | I | 0010011 | 010 | — | 10 | 00101 |
| 13| `SLTIU`| I | 0010011 | 011 | — | 10 | 01010 |
| 14| `XORI` | I | 0010011 | 100 | — | 10 | 00100 |
| 15| `ORI`  | I | 0010011 | 110 | — | 10 | 00011 |
| 16| `ANDI` | I | 0010011 | 111 | — | 10 | 00010 |
| 17| `SLLI` | I | 0010011 | 001 | 0000000 | 10 | 00111 |
| 18| `SRLI` | I | 0010011 | 101 | 0000000 | 10 | 01000 |
| 19| `SRAI` | I | 0010011 | 101 | 0100000 | 10 | 01001 |
| 20| `LB`   | L | 0000011 | 000 | — | 00 | 00000 |
| 21| `LH`   | L | 0000011 | 001 | — | 00 | 00000 |
| 22| `LW`   | L | 0000011 | 010 | — | 00 | 00000 |
| 23| `LBU`  | L | 0000011 | 100 | — | 00 | 00000 |
| 24| `LHU`  | L | 0000011 | 101 | — | 00 | 00000 |
| 25| `SB`   | S | 0100011 | 000 | — | 00 | 00000 |
| 26| `SH`   | S | 0100011 | 001 | — | 00 | 00000 |
| 27| `SW`   | S | 0100011 | 010 | — | 00 | 00000 |
| 28| `BEQ`  | B | 1100011 | 000 | — | 01 | 00001 |
| 29| `BNE`  | B | 1100011 | 001 | — | 01 | 00001 |
| 30| `BLT`  | B | 1100011 | 100 | — | 01 | 00001 |
| 31| `BGE`  | B | 1100011 | 101 | — | 01 | 00001 |
| 32| `BLTU` | B | 1100011 | 110 | — | 01 | 00001 |
| 33| `BGEU` | B | 1100011 | 111 | — | 01 | 00001 |
| 34| `JAL`  | J | 1101111 | — | — | — | — |
| 35| `JALR` | I | 1100111 | 000 | — | — | — |
| 36| `LUI`  | U | 0110111 | — | — | 11 | 00110 |
| 37| `AUIPC`| U | 0010111 | — | — | 11 | 01011 |
| 38| `FENCE`*| — | 0001111 | — | — | — | — |

> *FENCE falls through to the Control Unit's `default` case (no write, no branch), which is correct for a single-core in-order processor with no cache.

### Phase Legend

| Phase | Focus | Key Instructions |
|-------|-------|------------------|
| P1 | Basic Math & EX-EX Forwarding | `addi`, `add`, `sub` |
| P2 | MEM-EX Forwarding | `add`, NOP, `sub` |
| P3 | Load-Use Stall | `sw`, `lw`, `add` |
| P4 | BEQ Taken + Flush | `beq` (taken) |
| P5 | BNE Taken + Not Taken | `bne` (taken), `bne` (not taken), `and`, `or` |
| P6 | JAL + LUI | `jal`, `lui` |
| P7 | SLT | `slt` (equal), `slt` (less) |
| P8 | SLTI | `slti` (greater), `slti` (less) |
| P9 | ORI | `ori` |
| P10 | ANDI | `andi` |
| P11 | XOR & XORI | `xor`, `xori` |
| P12 | SLL & SLLI | `sll`, `slli` |
| P13 | SRL & SRLI | `addi` (setup), `srl`, `srli` |
| P14 | SRA & SRAI | `addi` (setup -16), `sra`, `srai` |
| P15 | SLTU & SLTIU | `sltu`, `sltiu` (overwrites x16, x17) |
| P16-19 | BLT, BGE, BLTU, BGEU | All taken (x10 canary stays 0) |
| P20 | AUIPC | `auipc` (x10 = PC + 0x1000) |
| P21 | JALR | `jalr` (jump to rs1+imm, save PC+4) |
| P22 | SB (Store Byte) | `sw` (zero out), `sb`, `lw` (verify) |
| P23 | SH (Store Halfword) | `sw` (zero out), `sh`, `lw` (verify) |
| P24 | Setup for LB/LH tests | `sb` (0x80), `sh` (0xFFFF) |
| P25 | LB & LBU | `lb` (sign-extend), `lbu` (zero-extend) |
| P26 | LH & LHU | `lh` (sign-extend), `lhu` (zero-extend) |
