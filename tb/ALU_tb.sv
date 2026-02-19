module ALU_tb;
    localparam N = 32;

    logic [N-1:0] A, B;
    logic [2:0] e_ALUCon;
    logic zero;
    logic [N-1:0] e_ALUResult;

    ALU dut(
        .A(A),
        .B(B),
        .e_ALUCon(e_ALUCon),
        .zero(zero),
        .e_ALUResult(e_ALUResult)
    );

    task check(input logic [2:0] alucon, input logic [N-1:0] a, input logic [N-1:0] b,
               input logic [N-1:0] expect_result, input logic expect_zero);
        begin
            e_ALUCon = alucon;
            A = a;
            B = b;
            #1;
            if (e_ALUResult === expect_result && zero === expect_zero)
                $display("[PASSED] ALUCon=%b A=%0d B=%0d | Result=%0d zero=%b", alucon, $signed(a), $signed(b), $signed(e_ALUResult), zero);
            else
                $display("[FAILED] ALUCon=%b A=%0d B=%0d | Expected %0d zero=%b | Got %0d zero=%b",
                         alucon, $signed(a), $signed(b), $signed(expect_result), expect_zero, $signed(e_ALUResult), zero);
        end
    endtask

    initial begin
        $monitor("Time: %0t | ALUCon: %b | A: %h B: %h | Result: %h zero: %b", $time, e_ALUCon, A, B, e_ALUResult, zero);

        // ADD: 10 + 25 = 35
        check(3'b000, 32'd10, 32'd25, 32'd35, 1'b0);
        // ADD: -1 + 1 = 0 (signed wrap)
        check(3'b000, 32'hFFFFFFFF, 32'd1, 32'd0, 1'b1);
        // ADD: 0 + 0 = 0
        check(3'b000, 32'd0, 32'd0, 32'd0, 1'b1);
        // ADD: 100 + 200 = 300
        check(3'b000, 32'd100, 32'd200, 32'd300, 1'b0);
        // SUB: 35 - 10 = 25
        check(3'b001, 32'd35, 32'd10, 32'd25, 1'b0);
        // SUB: 0 - 1 = -1
        check(3'b001, 32'd0, 32'd1, 32'hFFFFFFFF, 1'b0);
        // SUB: 5 - 5 = 0
        check(3'b001, 32'd5, 32'd5, 32'd0, 1'b1);
        // SUB: 10 - 100 = -90
        check(3'b001, 32'd10, 32'd100, 32'hFFFFFFA6, 1'b0);
        // SLT signed: 1 < 5 -> 1
        check(3'b101, 32'd1, 32'd5, 32'd1, 1'b0);
        // SLT: 5 < 1 -> 0
        check(3'b101, 32'd5, 32'd1, 32'd0, 1'b1);
        // SLT: -1 < 0 -> 1 (signed)
        check(3'b101, 32'hFFFFFFFF, 32'd0, 32'd1, 1'b0);
        // SLT: 0 < -1 -> 0 (signed, 0 greater than -1)
        check(3'b101, 32'd0, 32'hFFFFFFFF, 32'd0, 1'b1);
        // SLT: 0 < 0 -> 0
        check(3'b101, 32'd0, 32'd0, 32'd0, 1'b1);
        // OR: 0xFF00 | 0x00FF = 0xFFFF
        check(3'b011, 32'h0000FF00, 32'h000000FF, 32'h0000FFFF, 1'b0);
        // OR: 0 | 0 = 0
        check(3'b011, 32'd0, 32'd0, 32'd0, 1'b1);
        // OR: mixed bit pattern
        check(3'b011, 32'h12345678, 32'h87654321, 32'h97755779, 1'b0);
        // AND: 0xFFFF & 0xFF00 = 0xFF00
        check(3'b010, 32'h0000FFFF, 32'h0000FF00, 32'h0000FF00, 1'b0);
        // AND: disjoint masks -> 0
        check(3'b010, 32'hFFFF0000, 32'h0000FFFF, 32'd0, 1'b1);
        // AND: 0 & 0 = 0
        check(3'b010, 32'd0, 32'd0, 32'd0, 1'b1);
        
        // default/unsupported ALUCon -> 0
        check(3'b111, 32'd10, 32'd5, 32'd0, 1'b1);
        // default ALUCon 3'b100 -> 0
        check(3'b100, 32'd99, 32'd99, 32'd0, 1'b1);

        $finish;
    end

endmodule
