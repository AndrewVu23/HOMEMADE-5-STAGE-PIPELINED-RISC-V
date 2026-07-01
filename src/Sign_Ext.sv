`timescale 1ns/1ps

// Builds the 32-bit sign-extended immediate for each instruction format.
module Sign_Ext import signals_pkg::*; #(parameter N = 32)
(
  input  immsrc_t      d_ImmSrc,
  input  logic [N-1:0] d_instruction,
  output logic [N-1:0] d_ImmExt
);
  always_comb begin
    case (d_ImmSrc)
      IMM_I_TYPE: d_ImmExt = {{20{d_instruction[N-1]}}, d_instruction[31:20]};
      IMM_S_TYPE: d_ImmExt = {{20{d_instruction[N-1]}}, d_instruction[31:25], d_instruction[11:7]};
      IMM_B_TYPE: d_ImmExt = {{20{d_instruction[N-1]}}, d_instruction[7], d_instruction[30:25], d_instruction[11:8], 1'b0};
      IMM_J_TYPE: d_ImmExt = {{12{d_instruction[N-1]}}, d_instruction[19:12], d_instruction[20], d_instruction[30:21], 1'b0};
      IMM_U_TYPE: d_ImmExt = {d_instruction[31:12], 12'b0};
      default:    d_ImmExt = 32'b0;
    endcase
  end
endmodule
