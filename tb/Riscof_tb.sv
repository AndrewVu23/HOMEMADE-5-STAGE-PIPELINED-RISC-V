`timescale 1ns / 1ps

module Riscof_tb;
    localparam N = 32;
    localparam W = 5;

    logic clk, rst, stall;

    Processor #(.N(N), .W(W)) dut(
        .clk(clk),
        .rst(rst),
        .stall(stall)
    );

    // Plusarg variables
    string firmware_file;
    string signature_file;
    integer begin_signature;
    integer end_signature;
    integer tohost_addr;

    // Timeout: max cycles before we give up
    localparam MAX_CYCLES = 500000;
    integer cycle_count;

    always #5 clk = ~clk;

    initial begin
        // Read plusargs
        if (!$value$plusargs("firmware=%s", firmware_file)) begin
            $display("ERROR: +firmware=<file> plusarg required");
            $finish;
        end
        if (!$value$plusargs("signature_file=%s", signature_file)) begin
            $display("ERROR: +signature_file=<file> plusarg required");
            $finish;
        end
        if (!$value$plusargs("begin_signature=0x%h", begin_signature)) begin
            $display("ERROR: +begin_signature=0x<addr> plusarg required");
            $finish;
        end
        if (!$value$plusargs("end_signature=0x%h", end_signature)) begin
            $display("ERROR: +end_signature=0x<addr> plusarg required");
            $finish;
        end
        if (!$value$plusargs("tohost_addr=0x%h", tohost_addr)) begin
            $display("ERROR: +tohost_addr=0x<addr> plusarg required");
            $finish;
        end

        $display("RISCOF Testbench");
        $display("  Firmware:        %s", firmware_file);
        $display("  Signature file:  %s", signature_file);
        $display("  Begin signature: 0x%08x", begin_signature);
        $display("  End signature:   0x%08x", end_signature);
        $display("  Tohost address:  0x%08x (word index %0d)", tohost_addr, tohost_addr[20:2]);

        // Initialize
        clk = 0;
        rst = 1;
        stall = 0;
        cycle_count = 0;

        // Clear registers
        for (int i = 0; i < 32; i++) begin
            dut.Reg_File_module.Registers[i] = 32'b0;
        end

        // Load firmware hex into both instruction and data memories
        $readmemh(firmware_file, dut.Instr_Mem_module.ROM);
        $readmemh(firmware_file, dut.Data_Mem_module.RAM);

        // Hold reset for 2 cycles
        repeat(2) @(posedge clk);
        #1 rst = 0;

        $display("Reset released at time %0t", $time);

        // Run until tohost is written or timeout
        // Monitor tohost in Data_Mem for halt signal (test writes 1 to tohost when done)
        forever begin
            @(posedge clk);
            cycle_count = cycle_count + 1;

            if (dut.Data_Mem_module.RAM[tohost_addr[20:2]] == 32'd1) begin
                $display("HALT detected (tohost=1) at cycle %0d", cycle_count);
                dump_signature();
                $finish;
            end

            if (cycle_count >= MAX_CYCLES) begin
                $display("TIMEOUT after %0d cycles", MAX_CYCLES);
                dump_signature();
                $finish;
            end
        end
    end

    // Dump signature region from Data_Mem to file
    // RISCOF expects one 32-bit word per line, lowercase hex, no "0x" prefix
    task dump_signature();
        integer sig_fd;
        integer addr;
        integer word_idx;
        logic [31:0] word_val;

        sig_fd = $fopen(signature_file, "w");
        if (sig_fd == 0) begin
            $display("ERROR: Could not open signature file: %s", signature_file);
        end else begin
            $display("Dumping signature from 0x%08x to 0x%08x", begin_signature, end_signature);

            for (addr = begin_signature; addr < end_signature; addr = addr + 4) begin
                word_idx = addr[20:2];
                word_val = dut.Data_Mem_module.RAM[word_idx];
                $fwrite(sig_fd, "%08x\n", word_val);
            end

            $fclose(sig_fd);
            $display("Signature written to %s", signature_file);
        end
    endtask

endmodule
