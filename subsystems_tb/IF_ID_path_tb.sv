module IF_ID_path_tb;
    localparam N = 32;

    logic clk, rst, stall;
    logic w_RegWrite;
    logic [4:0] address_data;
    logic [N-1:0] w_Result;
    logic [N-1:0] captured_pc;

    IF_ID_path #(.N(N)) dut(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .w_RegWrite(w_RegWrite),
        .address_data(address_data),
        .w_Result(w_Result)
    );

    task check_pc_not_stuck;
        begin
            repeat(3) @(posedge clk);
            #1;
            if (dut.f_PC !== {N{1'b0}})
                $display("[PASSED] PC incrementing | f_PC=%h", dut.f_PC);
            else
                $display("[FAILED] PC stuck at 0");
        end
    endtask

    task check_regfile_write(input logic [4:0] rd, input logic [N-1:0] data);
        begin
            @(negedge clk);
            address_data = rd;
            w_Result = data;
            w_RegWrite = 1;
            @(negedge clk);
            w_RegWrite = 0;
            #1;
            if (dut.Reg_File_module.Registers[rd] === data)
                $display("[PASSED] RegFile write | x%0d=%h", rd, data);
            else
                $display("[FAILED] RegFile write | x%0d: Expected %h | Got %h", rd, data, dut.Reg_File_module.Registers[rd]);
        end
    endtask

    task check_stall_holds_pc;
        begin
            @(negedge clk);
            stall = 1;
            repeat(2) @(posedge clk);
            captured_pc = dut.f_PC;
            @(posedge clk);
            #1;
            if (dut.f_PC == captured_pc)
                $display("[PASSED] Stall | PC held at %h", dut.f_PC);
            else
                $display("[FAILED] Stall | PC moved from %h to %h", captured_pc, dut.f_PC);
            stall = 0;
        end
    endtask

    initial begin
        $monitor("Time: %0t | Reset: %b Stall: %b | f_PC: %h", $time, rst, stall, dut.f_PC);

        clk = 0;
        rst = 1;
        stall = 0;
        w_RegWrite = 0;
        address_data = 0;
        w_Result = 0;

        #10 rst = 0;

        check_pc_not_stuck;

        check_regfile_write(5'd1, 32'hDEADBEEF);

        check_stall_holds_pc;

        repeat(2) @(posedge clk);

        $finish;
    end

    always #5 clk = ~clk;

endmodule
