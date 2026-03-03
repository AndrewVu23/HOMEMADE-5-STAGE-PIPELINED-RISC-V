module PC_plus_4_counter_tb;
    localparam N = 32;

    logic rst;
    logic [N-1:0] f_PC, f_PC_plus_4;

    PC_plus_4_counter #(.N(N)) dut(
        .rst(rst),
        .f_PC(f_PC),
        .f_PC_plus_4(f_PC_plus_4)
    );

    task check(input logic [N-1:0] pc_val, input logic in_reset, input logic [N-1:0] expect);
        begin
            f_PC = pc_val;
            rst = in_rst;
            #1;
            if (f_PC_plus_4 === expect)
                $display("[PASSED] f_PC=%h rst=%b | f_PC_plus_4=%h", pc_val, in_rst, f_PC_plus_4);
            else
                $display("[FAILED] f_PC=%h rst=%b | Expected %h | Got %h", pc_val, in_rst, expect, f_PC_plus_4);
        end
    endtask

    initial begin
        $monitor("Time: %0t | Reset: %b | f_PC: %h f_PC_plus_4: %h", $time, rst, f_PC, f_PC_plus_4);

        rst = 1;
        f_PC = 32'h0000_1000;
        check(32'h0000_1000, 1'b1, {N{1'b0}});

        rst = 0;
        check(32'h0000_0000, 1'b0, 32'd4);
        check(32'h0000_0004, 1'b0, 32'd8);
        check(32'h0000_0010, 1'b0, 32'h0000_0014);
        check(32'hFFFF_FFFC, 1'b0, 32'h0000_0000);

        rst = 1;
        check(32'hDEAD_BEEF, 1'b1, {N{1'b0}});

        $finish;
    end

endmodule
