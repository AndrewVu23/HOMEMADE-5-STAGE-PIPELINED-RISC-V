PKG    = pkg/signals_pkg.sv
SRC    = src/*.sv
TB     = tb/Processor_tb.sv
TB_RC  = tb/Riscof_tb.sv
REPORT = riscof/riscof_work/report.html

.PHONY: test riscof report clean

# Run unit testbench (32 hand-written tests)
test:
	iverilog -g2012 -I pkg -o sim.vvp $(PKG) $(SRC) $(TB)
	vvp sim.vvp

# Run RISCOF compliance suite (38 official RV32I tests)
riscof:
	cd riscof && ./run.sh

# Open the RISCOF report in the browser
report:
	@if [ -f $(REPORT) ]; then \
		open $(REPORT) 2>/dev/null || xdg-open $(REPORT) 2>/dev/null || echo "Open $(REPORT) in your browser"; \
	else \
		echo "No report found. Run 'make riscof' first."; \
	fi

# Clean build artifacts (keeps riscv-arch-test since it's a 1.5GB download)
clean:
	rm -f sim.vvp *.vcd
	rm -rf riscof/riscof_work
