module Reg_File_tb;
    localparam N = 32;
    localparam W = 5;

    logic clk, reset, w_RegWrite;
    logic [W-1:0] address_1, address_2, address_data;
    logic [N-1:0] write_data;
    logic [N-1:0] read_address_1, read_address_2;

    Reg_File dut(
        .w_RegWrite(w_RegWrite),
        .clk(clk),
        .reset(reset),
        .address_1(address_1),
        .address_2(address_2),
        .address_data(address_data),
        .write_data(write_data),
        .read_address_1(read_address_1),
        .read_address_2(read_address_2)
    );

    integer i;

    task check_write(input logic [W-1:0] addr, input logic [N-1:0] data);
        begin
            w_RegWrite = 1;
            address_data = addr;
            write_data = data;
            @(posedge clk);
            @(negedge clk);
            #1;
        end
    endtask

    task check_read(input logic [W-1:0] addr1, input logic [W-1:0] addr2, input logic [N-1:0] expect1, input logic [N-1:0] expect2);
        begin
            address_1 = addr1;
            address_2 = addr2;
            #1;
            if (read_address_1 === expect1 && read_address_2 === expect2)
                $display("[PASSED] Read | addr1: %0d addr2: %0d | got %0d, %0d", addr1, addr2, read_address_1, read_address_2);
            else
                $display("[FAILED] Read | addr1: %0d addr2: %0d | Expected: %0d, %0d | Got: %0d, %0d",
                         addr1, addr2, expect1, expect2, read_address_1, read_address_2);
        end
    endtask

    task check_reset_read(input logic [W-1:0] addr1, input logic [W-1:0] addr2);
        begin
            address_1 = addr1;
            address_2 = addr2;
            #1;
            if (read_address_1 === {N{1'b0}} && read_address_2 === {N{1'b0}})
                $display("[PASSED] Reset Read | addr1: %0d addr2: %0d | 0, 0", addr1, addr2);
            else
                $display("[FAILED] Reset Read | addr1: %0d addr2: %0d | Expected: 0, 0 | Got: %0d, %0d",
                         addr1, addr2, read_address_1, read_address_2);
        end
    endtask

    initial begin
        $monitor("Time: %0t | Reset: %b RegWrite: %b | addr1: %0d addr2: %0d waddr: %0d | r1: %0d r2: %0d",
                 $time, reset, w_RegWrite, address_1, address_2, address_data, read_address_1, read_address_2);

        clk = 0;
        reset = 1;
        w_RegWrite = 0;
        address_1 = 0;
        address_2 = 0;
        address_data = 0;
        write_data = 0;

        #1;
        check_reset_read(1, 2);

        repeat(2) @(posedge clk);
        reset = 0;
        #1;

        for (i = 1; i < 6; i = i + 1)
            check_write(i[W-1:0], i * 10);

        w_RegWrite = 0;
        check_read(1, 2, 10, 20);
        check_read(3, 4, 30, 40);
        check_read(0, 0, 0, 0);

        check_write(0, {N{1'b1}});
        check_read(0, 1, 0, 10);

        w_RegWrite = 0;
        address_data = 1;
        write_data = 99;
        @(posedge clk);
        @(negedge clk);
        #1;
        check_read(1, 2, 10, 20);

        $finish;
    end

    always #5 clk = ~clk;

endmodule
