module ALU #(parameter N = 32)
(
  input logic [N-1:0] A, B,
  input logic [2:0] e_ALUCon,
  output logic zero,
  output logic [N-1:0] e_ALU_Result
);
  
logic signed [N-1:0] signed_A, signed_B;

assign signed_A = A;
assign signed_B = B;

always @(*) begin
  case(e_ALUCon)
    3'b000: e_ALU_Result = signed_A + signed_B;
    3'b001: e_ALU_Result = signed_A - signed_B;
    3'b101: e_ALU_Result = (signed_A < signed_B) ? 32'h1 : 32'h0; 
    3'b011: e_ALU_Result = A | B; 
    3'b010: e_ALU_Result = A & B; 
    3'b110: e_ALU_Result = B;
    default: e_ALU_Result = 32'h0;
  endcase

    zero = (e_ALU_Result == 32'h0) ? 1 : 0;
end
endmodule