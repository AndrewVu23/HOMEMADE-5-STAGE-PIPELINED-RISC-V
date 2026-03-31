`timescale 1ns/1ps

package signals_pkg;

  // Opcodes (instruction[6:0])
  typedef enum logic [6:0] {
    OPCODE_LOAD   = 7'b0000011,
    OPCODE_STORE  = 7'b0100011,
    OPCODE_R_TYPE = 7'b0110011,
    OPCODE_I_TYPE = 7'b0010011,
    OPCODE_B_TYPE = 7'b1100011,
    OPCODE_JAL    = 7'b1101111,
    OPCODE_JALR   = 7'b1100111,
    OPCODE_LUI    = 7'b0110111,
    OPCODE_AUIPC  = 7'b0010111
  } opcode_t;

  // ALUOp (Control_Unit -> ALU_Decoder)
  typedef enum logic [1:0] {
    ALUOP_LOAD_STORE = 2'b00,
    ALUOP_BRANCH     = 2'b01,
    ALUOP_R_I_TYPE   = 2'b10,
    ALUOP_U_TYPE     = 2'b11
  } aluop_t;

  // ALUCon (ALU_Decoder -> ALU)
  typedef enum logic [4:0] {
    ALU_ADD   = 5'b00000,
    ALU_SUB   = 5'b00001,
    ALU_AND   = 5'b00010,
    ALU_OR    = 5'b00011,
    ALU_XOR   = 5'b00100,
    ALU_SLT   = 5'b00101,
    ALU_LUI   = 5'b00110,
    ALU_SLL   = 5'b00111,
    ALU_SRL   = 5'b01000,
    ALU_SRA   = 5'b01001,
    ALU_SLTU  = 5'b01010,
    ALU_AUIPC = 5'b01011
  } alucon_t;

  // ImmSrc (Control_Unit -> Sign_Ext)
  typedef enum logic [2:0] {
    IMM_I_TYPE = 3'b000,
    IMM_S_TYPE = 3'b001,
    IMM_B_TYPE = 3'b010,
    IMM_J_TYPE = 3'b011,
    IMM_U_TYPE = 3'b100
  } immsrc_t;

  // ResultSrc (MuxWB select)
  typedef enum logic [1:0] {
    RESULT_ALU      = 2'b00,
    RESULT_MEM      = 2'b01,
    RESULT_PC_PLUS4 = 2'b10
  } resultsrc_t;

  // funct3 — R/I-type ALU operations
  typedef enum logic [2:0] {
    F3_ADD_SUB = 3'b000,
    F3_SLL     = 3'b001,
    F3_SLT     = 3'b010,
    F3_SLTU    = 3'b011,
    F3_XOR     = 3'b100,
    F3_SRL_SRA = 3'b101,
    F3_OR      = 3'b110,
    F3_AND     = 3'b111
  } funct3_alu_t;

  // funct3 — Branch conditions
  typedef enum logic [2:0] {
    F3_BEQ  = 3'b000,
    F3_BNE  = 3'b001,
    F3_BLT  = 3'b100,
    F3_BGE  = 3'b101,
    F3_BLTU = 3'b110,
    F3_BGEU = 3'b111
  } funct3_branch_t;

  // funct3 — Load/Store width
  typedef enum logic [2:0] {
    F3_BYTE   = 3'b000,
    F3_HALF   = 3'b001,
    F3_WORD   = 3'b010,
    F3_BYTE_U = 3'b100,
    F3_HALF_U = 3'b101
  } funct3_mem_t;

  // funct7 — R-type differentiator
  typedef enum logic [6:0] {
    F7_ADD_SRL_SLL = 7'b0000000,
    F7_SUB_SRA     = 7'b0100000
  } funct7_t;

  // Forwarding mux selects (Hazard_Unit)
  typedef enum logic [1:0] {
    FWD_NONE = 2'b00,
    FWD_WB   = 2'b01,
    FWD_MEM  = 2'b10
  } forward_t;

endpackage
