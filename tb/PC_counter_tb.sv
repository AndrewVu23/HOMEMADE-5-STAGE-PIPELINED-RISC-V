module PC_counter_tb;
    localparam N = 32;

    logic clk, reset, stall;
    logic [N-1:0] f_PC_next, f_PC;

    PC_counter #(.N(N)) dut(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .f_PC_next(f_PC_next),
        .f_PC(f_PC)
    );

    task check(input logic [N-1:0] next_val, input logic do_stall, input logic [N-1:0] expect_pc);
        begin
            f_PC_next = next_val;
            stall = do_stall;
            @(posedge clk);
            #1;
            if (f_PC === expect_pc)
                $display("[PASSED] f_PC_next=%h stall=%b | f_PC=%h", next_val, do_stall, f_PC);
            else
                $display("[FAILED] f_PC_next=%h stall=%b | Expected f_PC=%h | Got %h", next_val, do_stall, expect_pc, f_PC);
        end
    endtask

    initial begin
        $monitor("Time: %0t | Reset: %b Stall: %b | f_PC_next: %h f_PC: %h", $time, reset, stall, f_PC_next, f_PC);

        clk = 0;
        reset = 1;
        stall = 0;
        f_PC_next = 32'h0000_0010;
        @(posedge clk);
        #1;
        if (f_PC !== {N{1'b0}})
            $display("[FAILED] Reset | Expected 0 | Got %h", f_PC);
        else
            $display("[PASSED] Reset | f_PC=0");

        reset = 0;
        check(32'h0000_0004, 1'b0, 32'h0000_0004);
        check(32'h0000_0008, 1'b0, 32'h0000_0008);
        check(32'h0000_0010, 1'b1, 32'h0000_0008);
        check(32'h0000_0020, 1'b1, 32'h0000_0008);
        check(32'h0000_0030, 1'b0, 32'h0000_0030);

        reset = 1;
        f_PC_next = 32'hDEAD_BEEF;
        stall = 0;
        @(posedge clk);
        #1;
        if (f_PC !== {N{1'b0}})
            $display("[FAILED] Reset again | Expected 0 | Got %h", f_PC);
        else
            $display("[PASSED] Reset again | f_PC=0");

        $finish;
    end

    always #5 clk = ~clk;

endmodule
