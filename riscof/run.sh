#!/bin/bash
# RISCOF Compliance Test Runner
# Runs the official RISC-V architectural tests against this processor
#
# Prerequisites:
#   - riscof:    brew install pipx && pipx install riscof
#   - iverilog:  brew install icarus-verilog  (or apt install iverilog)
#   - spike:     brew install riscv-isa-sim   (or build from source)
#   - toolchain: brew install riscv-gnu-toolchain (need riscv64-unknown-elf-gcc)
#
# Setup (one-time, ~1.5GB download):
#   cd riscof/
#   riscof arch-test --clone
#
# Usage:
#   ./run.sh          # run all 38 RV32I tests
#   ./run.sh clean    # wipe previous results and re-run

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Check prerequisites
for cmd in riscof iverilog vvp spike riscv64-unknown-elf-gcc; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "ERROR: '$cmd' not found. Please install it first."
        exit 1
    fi
done

# Check arch-test suite is cloned
if [ ! -d "riscv-arch-test" ]; then
    echo "ERROR: riscv-arch-test not found."
    echo "Please clone it first (one-time, ~1.5GB):"
    echo ""
    echo "  cd riscof/"
    echo "  riscof arch-test --clone"
    echo ""
    exit 1
fi

# Clean previous results if requested
if [ "$1" = "clean" ]; then
    echo "Cleaning previous results..."
    rm -rf riscof_work
fi

# Run the full RV32I compliance suite
echo "Running RISCOF compliance tests..."
echo "This may take a few minutes."
echo ""

riscof run \
    --config config.ini \
    --suite riscv-arch-test/riscv-test-suite/rv32i_m/I \
    --env riscv-arch-test/riscv-test-suite/env \
    --no-browser

echo ""
echo "Results: riscof/riscof_work/report.html"
