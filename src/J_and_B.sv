`timescale 1ns/1ps

// Resolves branches/jumps in EX: evaluates the branch condition and asserts
// e_PCSrc when the PC should be redirected to the computed target.
module J_and_B import signals_pkg::*; #(parameter N = 32)
(
    input  logic [N-1:0] A,
    input  logic [N-1:0] B,
    input  logic [2:0]   e_funct3,
    input  logic         e_Jump,
    input  logic         e_Branch,
    output logic         e_PCSrc
);
  logic branch_taken, eq, lt, ltu;

  assign eq  = (A == B);
  assign lt  = ($signed(A) < $signed(B));
  assign ltu = (A < B);

  always_comb begin
    case (e_funct3)
      F3_BEQ:  branch_taken =  eq;
      F3_BNE:  branch_taken = !eq;
      F3_BLT:  branch_taken =  lt;
      F3_BGE:  branch_taken = !lt;
      F3_BLTU: branch_taken =  ltu;
      F3_BGEU: branch_taken = !ltu;
      default: branch_taken = 1'b0;
    endcase
  end

  assign e_PCSrc = (e_Branch & branch_taken) | e_Jump;
endmodule
