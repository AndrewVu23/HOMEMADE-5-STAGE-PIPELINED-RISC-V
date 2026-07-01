`timescale 1ns/1ps

// Main decoder: maps an instruction opcode to the pipeline control signals.
module Control_Unit import signals_pkg::*;
(
  input  opcode_t    opcode,
  output logic       d_RegWrite,
  output logic       d_ALUSrc,
  output logic       d_MemWrite,
  output logic       d_Branch,
  output logic       d_Jump,
  output logic       d_JALRSrc,
  output immsrc_t    d_ImmSrc,
  output aluop_t     ALUOp,
  output resultsrc_t d_ResultSrc
);
  always_comb begin
    case (opcode)
      OPCODE_LOAD: begin // lw, lb, lh, lbu, lhu
        d_RegWrite = 1; d_ALUSrc = 1; d_MemWrite = 0; d_ResultSrc = RESULT_MEM;
        d_Branch = 0; d_Jump = 0; d_JALRSrc = 0; d_ImmSrc = IMM_I_TYPE; ALUOp = ALUOP_LOAD_STORE;
      end
      OPCODE_STORE: begin // sw, sb, sh
        d_RegWrite = 0; d_ALUSrc = 1; d_MemWrite = 1; d_ResultSrc = RESULT_ALU;
        d_Branch = 0; d_Jump = 0; d_JALRSrc = 0; d_ImmSrc = IMM_S_TYPE; ALUOp = ALUOP_LOAD_STORE;
      end
      OPCODE_R_TYPE: begin // add, sub, and, or, ...
        d_RegWrite = 1; d_ALUSrc = 0; d_MemWrite = 0; d_ResultSrc = RESULT_ALU;
        d_Branch = 0; d_Jump = 0; d_JALRSrc = 0; d_ImmSrc = IMM_I_TYPE /* unused */; ALUOp = ALUOP_R_I_TYPE;
      end
      OPCODE_B_TYPE: begin // beq, bne, blt, ...
        d_RegWrite = 0; d_ALUSrc = 0; d_MemWrite = 0; d_ResultSrc = RESULT_ALU;
        d_Branch = 1; d_Jump = 0; d_JALRSrc = 0; d_ImmSrc = IMM_B_TYPE; ALUOp = ALUOP_BRANCH;
      end
      OPCODE_I_TYPE: begin // addi, andi, slli, ...
        d_RegWrite = 1; d_ALUSrc = 1; d_MemWrite = 0; d_ResultSrc = RESULT_ALU;
        d_Branch = 0; d_Jump = 0; d_JALRSrc = 0; d_ImmSrc = IMM_I_TYPE; ALUOp = ALUOP_R_I_TYPE;
      end
      OPCODE_JALR: begin // jalr — target = rs1 + imm, writeback = PC+4
        d_RegWrite = 1; d_ALUSrc = 1; d_MemWrite = 0; d_ResultSrc = RESULT_PC_PLUS4;
        d_Branch = 0; d_Jump = 1; d_JALRSrc = 1; d_ImmSrc = IMM_I_TYPE; ALUOp = ALUOP_LOAD_STORE /* unused */;
      end
      OPCODE_JAL: begin // jal — target = PC + imm, writeback = PC+4
        d_RegWrite = 1; d_ALUSrc = 1; d_MemWrite = 0; d_ResultSrc = RESULT_PC_PLUS4;
        d_Branch = 0; d_Jump = 1; d_JALRSrc = 0; d_ImmSrc = IMM_J_TYPE; ALUOp = ALUOP_LOAD_STORE /* unused */;
      end
      OPCODE_LUI, OPCODE_AUIPC: begin // U-type
        d_RegWrite = 1; d_ALUSrc = 1; d_MemWrite = 0; d_ResultSrc = RESULT_ALU;
        d_Branch = 0; d_Jump = 0; d_JALRSrc = 0; d_ImmSrc = IMM_U_TYPE; ALUOp = ALUOP_U_TYPE;
      end
      default: begin // fence and anything else: no side effects
        d_RegWrite = 0; d_ALUSrc = 0; d_MemWrite = 0; d_ResultSrc = RESULT_ALU;
        d_Branch = 0; d_Jump = 0; d_JALRSrc = 0; d_ImmSrc = IMM_I_TYPE; ALUOp = ALUOP_LOAD_STORE;
      end
    endcase
  end
endmodule
