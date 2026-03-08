`timescale 1ns / 1ps

module Processor_tb;
    localparam N = 32;
    localparam W = 5;

    logic clk, rst, stall;

    integer i;
    integer pass_count, fail_count;

    Processor #(.N(N), .W(W)) dut(
        .clk(clk),
        .rst(rst),
        .stall(stall)
    );

    task check_register(input logic [W-1:0] reg_num, input logic [N-1:0] expected_val);
        begin
            logic [N-1:0] actual_val;
            actual_val = dut.Reg_File_module.Registers[reg_num]; 

            if (actual_val === expected_val) begin
                $display("[PASSED] | x%0d | Expected: %0d (0x%08x) | Got: %0d (0x%08x)", 
                        reg_num, expected_val, expected_val, actual_val, actual_val);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAILED] | x%0d | Expected: %0d (0x%08x) | Got: %0d (0x%08x)", 
                        reg_num, expected_val, expected_val, actual_val, actual_val);
                fail_count = fail_count + 1;
            end
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        $dumpfile("Processor.vcd");
        $dumpvars(0, Processor_tb);

        clk = 0; rst = 1; stall = 0; 
        pass_count = 0; fail_count = 0;

        for (i = 0; i < 32; i = i + 1) begin
            dut.Reg_File_module.Registers[i] = 32'b0;
        end

        $readmemh("instructions.hex", dut.Instr_Mem_module.ROM);

        repeat(2) @(posedge clk);
        #1 rst = 0;

        $display("Time: %0t | Reset Released", $time);
        $display("============================================================");

        repeat(120) @(posedge clk);

        $display("Simulation Complete. Checking Registers:");
        $display("============================================================");

        // Phase 1: Basic Math & EX-EX Forwarding
        $display("Phase 1: Basic Math & EX-EX Forwarding");
        check_register(5'd1, 32'd5); // addi x1, x0, 5
        check_register(5'd2, 32'd10); // addi x2, x0, 10
        check_register(5'd3, 32'd15); // add  x3, x1, x2
        check_register(5'd4, 32'd10); // sub  x4, x3, x1

        // Phase 2: MEM-EX Forwarding
        $display("Phase 2: MEM-EX Forwarding");
        check_register(5'd5, 32'd15); // add  x5, x1, x2
        check_register(5'd0, 32'd0); // NOP (x0 always 0)
        check_register(5'd6, 32'd5); // sub  x6, x5, x2
        
        // Phase 3: LW/SW & Load-Use Stall
        $display("Phase 3: LW/SW & Load-Use Stall");
        check_register(5'd7, 32'd5); // lw   x7, 0(x0)
        check_register(5'd8, 32'd10); // add  x8, x7, x1

        // Phase 4: Control Hazards & Flushing (BEQ taken)
        $display("Phase 4: Control Hazards & Flushing");
        check_register(5'd9, 32'd0); // Flushed (should stay 0)
        check_register(5'd10, 32'd0); // Not written (should stay 0)

        // Phase 5: Branch Not Taken & Logic
        $display("Phase 5: Branch Not Taken & ALU Logic");
        check_register(5'd11, 32'd0); // and  x11, x1, x2 = 0
        check_register(5'd12, 32'd15); // or   x12, x1, x2 = 15

        // Phase 6: JAL & LUI
        $display("Phase 6: JAL & LUI");
        check_register(5'd13, 32'd68); // jal  x13, 12 -> saves PC+4 = 0x44 = 68
        check_register(5'd14, 32'd0); // Flushed (should stay 0)
        check_register(5'd15, 32'd16384); // lui  x15, 4  -> 4 << 12 = 16384

        // Phase 7: SLT then SLTU (x16, x17 overwritten by Phase 15)
        $display("Phase 7/15: SLT -> SLTU/SLTIU (final values)");
        check_register(5'd16, 32'd1); // sltu x16, x1, x29 -> unsigned: 5 < 0xFFFFFFF0 = 1
        check_register(5'd17, 32'd1); // sltiu x17, x1, -1 -> unsigned: 5 < 0xFFFFFFFF = 1

        // Phase 8: SLTI
        $display("Phase 8: SLTI");
        check_register(5'd18, 32'd0); // slti x18, x1, 3 -> 5 < 3 = 0
        check_register(5'd19, 32'd1); // slti x19, x1, 10 -> 5 < 10 = 1

        // Phase 9: ORI
        $display("Phase 9: ORI");
        check_register(5'd20, 32'd15); // ori  x20, x1, 0xA -> 0101 | 1010 = 1111 = 15

        // Phase 10: ANDI
        $display("Phase 10: ANDI");
        check_register(5'd21, 32'd1); // andi x21, x1, 0x3 -> 0101 & 0011 = 0001 = 1

        // Phase 11: XOR & XORI
        $display("Phase 11: XOR & XORI");
        check_register(5'd22, 32'd15); // xor  x22, x1, x2 -> 0101 ^ 1010 = 1111 = 15
        check_register(5'd23, 32'd10); // xori x23, x1, 0xF -> 0101 ^ 1111 = 1010 = 10

        // Phase 12: SLL & SLLI
        $display("Phase 12: SLL & SLLI");
        check_register(5'd24, 32'd5120); // sll  x24, x1, x2 -> 5 << 10 = 5120
        check_register(5'd25, 32'd20); // slli x25, x1, 2 -> 5 << 2 = 20

        // Phase 13: SRL & SRLI
        $display("Phase 13: SRL & SRLI");
        check_register(5'd27, 32'd240); // addi x27, x0, 240 -> setup
        check_register(5'd26, 32'd0); // srl  x26, x3, x1 -> 15 >> 5 = 0
        check_register(5'd28, 32'd15); // srli x28, x27, 4 -> 240 >> 4 = 15

        // Phase 14: SRA & SRAI
        $display("Phase 14: SRA & SRAI");
        check_register(5'd29, 32'hFFFFFFF0); // addi x29, x0, -16 -> 0xFFFFFFF0
        check_register(5'd30, 32'hFFFFFFFF); // sra  x30, x29, x1 -> -16 >>> 5 = -1
        check_register(5'd31, 32'hFFFFFFFC); // srai x31, x29, 2 -> -16 >>> 2 = -4

        $display("============================================================");
        $display("RESULTS: %0d PASSED, %0d FAILED out of %0d total", 
                 pass_count, fail_count, pass_count + fail_count);
        $display("============================================================");

        #1000;
        $finish;
    end
endmodule