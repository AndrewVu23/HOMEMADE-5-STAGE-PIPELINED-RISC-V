module ALU_tb;
    localparam N = 32;

    logic [N-1:0] A, B;
    logic [4:0] e_ALUCon;
    logic [N-1:0] e_ALU_Result;

    ALU dut(
        .A(A),
        .B(B),
        .e_ALUCon(e_ALUCon),
        .e_ALU_Result(e_ALU_Result)
    );

    task check(input logic [4:0] alucon, input logic [N-1:0] a, input logic [N-1:0] b,
               input logic [N-1:0] expect_result);
        begin
            e_ALUCon = alucon;
            A = a;
            B = b;
            #1;
            if (e_ALU_Result === expect_result)
                $display("[PASSED] ALUCon=%b A=%0d B=%0d | Result=%0d", alucon, $signed(a), $signed(b), $signed(e_ALU_Result));
            else
                $display("[FAILED] ALUCon=%b A=%0d B=%0d | Expected %0d | Got %0d",
                         alucon, $signed(a), $signed(b), $signed(expect_result), $signed(e_ALU_Result));
        end
    endtask

    initial begin
        $dumpfile("ALU.vcd");
        $dumpvars(0, ALU_tb);
        
        $monitor("Time: %0t | ALUCon: %b | A: %h B: %h | Result: %h", $time, e_ALUCon, A, B, e_ALU_Result);

        // ADD (00000)
        check(5'b00000, 32'd10, 32'd25, 32'd35); // 10 + 25 = 35
        check(5'b00000, 32'hFFFFFFFF, 32'd1, 32'd0); // -1 + 1 = 0 (overflow wrap)
        check(5'b00000, 32'd0, 32'd0, 32'd0); // 0 + 0 = 0
        check(5'b00000, 32'd100, 32'd200, 32'd300); // 100 + 200 = 300

        // SUB (00001)
        check(5'b00001, 32'd35, 32'd10, 32'd25); // 35 - 10 = 25
        check(5'b00001, 32'd0, 32'd1, 32'hFFFFFFFF); // 0 - 1 = -1
        check(5'b00001, 32'd5, 32'd5, 32'd0); // 5 - 5 = 0 (zero flag)
        check(5'b00001, 32'd10, 32'd100, 32'hFFFFFFA6); // 10 - 100 = -90

        // AND (00010)
        check(5'b00010, 32'h0000FFFF, 32'h0000FF00, 32'h0000FF00); // overlapping masks
        check(5'b00010, 32'hFFFF0000, 32'h0000FFFF, 32'd0); // disjoint masks -> 0
        check(5'b00010, 32'd0, 32'd0, 32'd0); // 0 & 0 = 0

        // OR (00011)
        check(5'b00011, 32'h0000FF00, 32'h000000FF, 32'h0000FFFF); // adjacent bytes merge
        check(5'b00011, 32'd0, 32'd0, 32'd0); // 0 | 0 = 0
        check(5'b00011, 32'h12345678, 32'h87654321, 32'h97755779); // mixed bit pattern

        // XOR (00100)
        check(5'b00100, 32'hFF00FF00, 32'h0F0F0F0F, 32'hF00FF00F); // alternating nibbles
        check(5'b00100, 32'hAAAAAAAA, 32'h55555555, 32'hFFFFFFFF); // all bits flip
        check(5'b00100, 32'hDEADBEEF, 32'hDEADBEEF, 32'd0); // x ^ x = 0
        check(5'b00100, 32'd5, 32'd10, 32'd15); // 0101 ^ 1010 = 1111

        // SLT signed (00101)
        check(5'b00101, 32'd1, 32'd5, 32'd1); // 1 < 5 = true
        check(5'b00101, 32'd5, 32'd1, 32'd0); // 5 < 1 = false
        check(5'b00101, 32'hFFFFFFFF, 32'd0, 32'd1); // -1 < 0 = true (signed)
        check(5'b00101, 32'd0, 32'hFFFFFFFF, 32'd0); // 0 < -1 = false (signed)
        check(5'b00101, 32'd0, 32'd0, 32'd0); // 0 < 0 = false (equal)

        // LUI Pass B (00110)
        check(5'b00110, 32'd999, 32'hABCDE000, 32'hABCDE000); // ignores A, passes B
        check(5'b00110, 32'd0, 32'd0, 32'd0); // pass zero

        // SLL (00111)
        check(5'b00111, 32'd1, 32'd0, 32'd1); // 1 << 0 = 1
        check(5'b00111, 32'd1, 32'd4, 32'd16); // 1 << 4 = 16
        check(5'b00111, 32'd5, 32'd10, 32'd5120); // 5 << 10 = 5120
        check(5'b00111, 32'd5, 32'd2, 32'd20); // 5 << 2 = 20
        check(5'b00111, 32'hFFFFFFFF, 32'd16, 32'hFFFF0000); // shift out low bits

        // SRL (01000)
        check(5'b01000, 32'd16, 32'd4, 32'd1); // 16 >> 4 = 1
        check(5'b01000, 32'd240, 32'd4, 32'd15); // 0xF0 >> 4 = 15
        check(5'b01000, 32'd15, 32'd5, 32'd0); // 15 >> 5 = 0
        check(5'b01000, 32'hFFFFFFFF, 32'd16, 32'h0000FFFF); // logical: fills with 0s

        // SRA (01001)
        check(5'b01001, 32'hFFFFFFF0, 32'd2, 32'hFFFFFFFC); // -16 >>> 2 = -4
        check(5'b01001, 32'hFFFFFFF0, 32'd5, 32'hFFFFFFFF); // -16 >>> 5 = -1
        check(5'b01001, 32'd240, 32'd4, 32'd15); // positive: same as SRL
        check(5'b01001, 32'h80000000, 32'd31, 32'hFFFFFFFF); // MSB fills with 1
        
        // SLTU unsigned (01010)
        check(5'b01010, 32'd5, 32'hFFFFFFF0, 32'd1); // 5 < 0xFFFFFFF0 = true (unsigned)
        check(5'b01010, 32'hFFFFFFF0, 32'd5, 32'd0); // 0xFFFFFFF0 < 5 = false (unsigned)
        check(5'b01010, 32'hFFFFFFFF, 32'd0, 32'd0); // MAX < 0 = false
        check(5'b01010, 32'd0, 32'hFFFFFFFF, 32'd1); // 0 < MAX = true
        check(5'b01010, 32'd0, 32'd0, 32'd0); // 0 < 0 = false

        $finish;
    end

endmodule
