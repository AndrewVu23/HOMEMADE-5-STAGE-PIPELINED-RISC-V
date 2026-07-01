`timescale 1ns/1ps

module ALU import signals_pkg::*; #(parameter N = 32)
(
  input  logic [N-1:0] A,
  input  logic [N-1:0] B,
  input  logic [N-1:0] e_PC,
  input  alucon_t      e_ALUCon,
  output logic [N-1:0] e_ALU_Result
);

  logic signed [N-1:0] signed_A, signed_B;

  assign signed_A = A;
  assign signed_B = B;

  always_comb begin
    case (e_ALUCon)
      ALU_ADD:   e_ALU_Result = signed_A + signed_B;
      ALU_SUB:   e_ALU_Result = signed_A - signed_B;
      ALU_AND:   e_ALU_Result = A & B;
      ALU_OR:    e_ALU_Result = A | B;
      ALU_XOR:   e_ALU_Result = A ^ B;
      ALU_SLT:   e_ALU_Result = (signed_A < signed_B) ? 32'h1 : 32'h0;
      ALU_LUI:   e_ALU_Result = B;              // pass the upper immediate straight through
      ALU_SLL:   e_ALU_Result = A << B[4:0];
      ALU_SRL:   e_ALU_Result = A >> B[4:0];
      ALU_SRA:   e_ALU_Result = signed_A >>> B[4:0];
      ALU_SLTU:  e_ALU_Result = (A < B) ? 32'h1 : 32'h0;
      ALU_AUIPC: e_ALU_Result = e_PC + B;
      default:   e_ALU_Result = 32'h0;
    endcase
  end
endmodule
