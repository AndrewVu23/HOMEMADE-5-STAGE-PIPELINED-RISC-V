module Instr_Mem_tb;
    localparam N = 32;
    logic reset, clk;
    logic [N-1:0] address, instruction_out;

    Instr_Mem dut(
        .clk(clk),
        .reset(reset),
        .address(address),
        .instruction_out(instruction_out)
    );

    integer i;

    task check(input logic [31:0] addr_to_test, input logic expect_reset);
        begin
            address = addr_to_test;
            @(posedge clk); #1;

            if (expect_reset) begin
                if (instruction_out === 32'b0)
                    $display("[PASSED] Reset Test | Addr: %h", addr_to_test, instruction_out);
            end else begin
                if (instruction_out === (addr_to_test[11:2] * 10))
                    $display("[PASSED] Read Test  | Addr: %h | Data: %d", addr_to_test, instruction_out);
                else
                    $display("[FAILED] Read Test  | Addr: %h | Expected: %d | Got: %h", 
                             addr_to_test, (addr_to_test[11:2]*10), instruction_out);
            end
        end
    endtask

    initial begin
        $monitor("Time: %0t | Reset: %b | Addr: %h | Instr: %d", $time, reset, address, instruction_out);

        for (i = 0; i < 1024; i = i + 1) begin
            dut.ROM[i] = i * 10;
        end

        reset = 1; clk = 0; address = 32'b00000000;
        
        check(32'h0000_0000, 1);
        check(32'h0000_03FC, 1);

        repeat(2) @(posedge clk); reset = 0;
        check(32'h0000_0000, 0);
        check(32'h0000_03FC, 0);
       
        check(32'h0000_0004, 0);
        check(32'h0000_0005, 0);
        check(32'h0000_0007, 0);
        
        reset = 1;
        check(32'h0000_0010, 1);
        reset = 0;
        check(32'h0000_0010, 0); 

        $finish;
    end

    always #5 clk = ~clk;

endmodule
