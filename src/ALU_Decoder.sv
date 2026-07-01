`timescale 1ns/1ps

// Secondary decoder: refines ALUOp (from the Control_Unit) plus funct3/funct7
// into the concrete ALU operation.
module ALU_Decoder import signals_pkg::*;
(
  input  logic [2:0] funct3,
  input  aluop_t     ALUOp,
  input  logic       funct7_5, // instruction[30]
  input  logic       op5,      // instruction[5] — distinguishes R-type from I-type
  output alucon_t    d_ALUCon
);
  always_comb begin
    case (ALUOp)
      ALUOP_LOAD_STORE: d_ALUCon = ALU_ADD;                        // address = base + imm
      ALUOP_BRANCH:     d_ALUCon = ALU_SUB;                        // compare via subtract
      ALUOP_U_TYPE:     d_ALUCon = alucon_t'(op5 ? ALU_LUI : ALU_AUIPC);      // lui passes imm, auipc adds PC
      ALUOP_R_I_TYPE: begin
        case (funct3)
          F3_ADD_SUB: d_ALUCon = alucon_t'((op5 & funct7_5) ? ALU_SUB : ALU_ADD); // sub only for R-type add/sub with funct7[5]
          F3_SLL:     d_ALUCon = ALU_SLL;
          F3_SLT:     d_ALUCon = ALU_SLT;
          F3_SLTU:    d_ALUCon = ALU_SLTU;
          F3_XOR:     d_ALUCon = ALU_XOR;
          F3_SRL_SRA: d_ALUCon = alucon_t'(funct7_5 ? ALU_SRA : ALU_SRL);     // srai/sra vs srli/srl
          F3_OR:      d_ALUCon = ALU_OR;
          F3_AND:     d_ALUCon = ALU_AND;
          default:    d_ALUCon = ALU_ADD;
        endcase
      end
      default: d_ALUCon = ALU_ADD;
    endcase
  end
endmodule
