module Sign_Ext #(parameter N = 32)
(
  input logic [2:0] d_ImmSrc,
  input logic [N-1:0] d_instruction,
  output logic [N-1:0] d_ImmExt
);
  always @(*) begin
    case(d_ImmSrc)
      3'b000: d_ImmExt = {{20{d_instruction[N-1]}}, d_instruction[31:20]};
      3'b001: d_ImmExt = {{20{d_instruction[N-1]}}, d_instruction[31:25], d_instruction[11:7]};
      3'b010: d_ImmExt = {{20{d_instruction[N-1]}}, d_instruction[7], d_instruction[30:25], d_instruction[11:8], 1'b0};
      3'b011: d_ImmExt = {{12{d_instruction[N-1]}}, d_instruction[19:12], d_instruction[20], d_instruction[30:21], 1'b0};
      3'b100: d_ImmExt = {d_instruction[31:12], 12'b0};
      default: d_ImmExt = 32'b0;
    endcase
  end
endmodule