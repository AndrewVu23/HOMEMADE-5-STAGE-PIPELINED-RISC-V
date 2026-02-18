module ALU(
  input logic [31:0] A, B,
  input logic [2:0] e_ALUCon,
  output logic zero,
  output logic [31:0] e_ALUResult
);
  
logic [31:0] signed_A, signed_B;

assign signed_A = $signed(A);
assign signed_B = $signed(B);

always @(*) begin
  case(e_ALUCon)
    3'b000: e_ALUResult = signed_A + signed_B;
    3'b001: e_ALUResult = signed_A - signed_B;
    3'b101: e_ALUResult = (signed_A < signed_B) ? 32'h1 : 32'h0; 
    3'b011: e_ALUResult = A | B; 
    3'b010: e_ALUResult = A & B; 
    default: e_ALUResult = 32'h0;
  endcase

    zero = (e_ALUResult == 32'h0) ? 1 : 0;
end
endmodule