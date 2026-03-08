module ALU #(parameter N = 32)
(
  input logic [N-1:0] A, B,
  input logic [4:0] e_ALUCon,
  output logic zero,
  output logic [N-1:0] e_ALU_Result
);
  
logic signed [N-1:0] signed_A, signed_B;

assign signed_A = A;
assign signed_B = B;

always @(*) begin
  case(e_ALUCon)
    5'b00000: e_ALU_Result = signed_A + signed_B;                        // ADD
    5'b00001: e_ALU_Result = signed_A - signed_B;                        // SUB
    5'b00010: e_ALU_Result = A & B;                                      // AND
    5'b00011: e_ALU_Result = A | B;                                      // OR
    5'b00100: e_ALU_Result = A ^ B;                                      // XOR
    5'b00101: e_ALU_Result = (signed_A < signed_B) ? 32'h1 : 32'h0;     // SLT
    5'b00110: e_ALU_Result = B;                                          // LUI (Pass B)
    5'b00111: e_ALU_Result = A << B[4:0];                                // SLL
    5'b01000: e_ALU_Result = A >> B[4:0];                                // SRL
    5'b01001: e_ALU_Result = signed_A >>> B[4:0];                        // SRA
    5'b01010: e_ALU_Result = (A < B) ? 32'h1 : 32'h0;                   // SLTU
    default:  e_ALU_Result = 32'h0;
  endcase

    zero = (e_ALU_Result == 32'h0) ? 1 : 0;
end
endmodule