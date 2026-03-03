`timescale 1ns / 1ps

module Processor_tb;
    localparam N = 32;
    localparam W = 5;

    logic clk, rst, stall;

    integer i;

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
                $display("[PASSED] | x%0d | Expected: %0d | Got: %0d", 
                        reg_num, expected_val, actual_val);
            end else begin
                $display("[FAILED] | x%0d | Expected: %0d | Got: %0d", 
                        reg_num, expected_val, actual_val);
            end
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        $dumpfile("Processor.vcd");
        $dumpvars(0, Processor_tb);

        clk = 0; rst = 1; stall = 0; 

        for (i = 0; i < 32; i = i + 1) begin
            dut.Reg_File_module.Registers[i] = 32'b0;
        end


        $readmemh("instructions.hex", dut.Instr_Mem_module.ROM);

        repeat(2) @(posedge clk);
        #1 rst = 0;

        $display("Time: %0t | Reset Released", $time);

        repeat(75) @(posedge clk);

        $display("Simulation Complet. Checking Registers: ");

        //Phase 1: Basic Math & EX-EX Forwarding
        check_register(5'd1, 32'd5);
        check_register(5'd2, 32'd10);
        check_register(5'd3, 32'd15);
        check_register(5'd4, 32'd10);

        //Phase 2: MEM-EX Forwarding;
        check_register(5'd5, 32'd15);
        check_register(5'd0, 32'd0);
        check_register(5'd6, 32'd5);
        
        //Phase 3: lw/sw STall
        check_register(5'd7, 32'd5);
        check_register(5'd8, 32'd10);

        //Phase 4: Control Hazards & Flushing
        check_register(5'd9, 32'd0);
        check_register(5'd10, 32'd0);

        // Phase 5: Branch Not Taken & Logic
        check_register(5'd11, 32'd0);   
        check_register(5'd12, 32'd15); 

        // Phase 6: Jal & U-Type
        check_register(5'd13, 32'd68);  
        check_register(5'd14, 32'd0);   
        check_register(5'd15, 32'd16384); 

        #1000;
        $finish;
    end
endmodule