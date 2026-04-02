`timescale 1ns/1ps

module Processor #(parameter N = 32, parameter W = 5)
(
    input logic clk,
    input logic rst,
    input logic stall
);

// Fetch
logic [N-1:0] f_instruction;
logic [N-1:0] f_PC_next;
logic [N-1:0] f_PC;
logic [N-1:0] f_PC_plus_4;
logic f_stall;

// Decode
logic [N-1:0] d_instruction;
logic [N-1:0] d_read_address1;
logic [N-1:0] d_read_address2;
logic [N-1:0] d_ImmExt;
logic [N-1:0] d_PC;
logic [N-1:0] d_PC_plus_4;
logic d_RegWrite;
logic d_ALUSrc;
logic d_MemWrite;
logic d_Branch;
logic d_Jump;
logic d_JALRSrc;
logic d_stall;
logic d_flush;
logic [4:0] d_ALUCon;
logic [1:0] ALUOp;
logic [1:0] d_ResultSrc;
logic [2:0] d_ImmSrc;
logic [W-1:0] d_rs1;
logic [W-1:0] d_rs2;
logic [W-1:0] d_rd;

// Execute
logic [N-1:0] e_read_address1;
logic [N-1:0] e_read_address2;
logic [N-1:0] e_ImmExt;
logic [N-1:0] e_PC;
logic [N-1:0] e_PC_plus_4;
logic [W-1:0] e_rs1;
logic [W-1:0] e_rs2;
logic [W-1:0] e_rd;
logic e_RegWrite;
logic e_ALUSrc;
logic e_MemWrite;
logic e_Branch;
logic e_Jump;
logic e_JALRSrc;
logic e_PCSrc;
logic [1:0] e_ResultSrc;
logic [4:0] e_ALUCon;
logic [2:0] e_funct3;
logic e_flush;
logic [1:0] forwardA;
logic [1:0] forwardB;
logic [N-1:0] e_ALU_Result;
logic [N-1:0] A;
logic [N-1:0] B;
logic [N-1:0] e_PC_Target;
logic [N-1:0] e_PC_or_rs1;
logic [N-1:0] e_write_data;

// Memory
logic [N-1:0] m_ALU_Result;
logic [N-1:0] m_write_data;
logic [N-1:0] m_write_data_shifted;
logic [N-1:0] m_PC_plus_4;
logic [N-1:0] m_read_address;
logic [N-1:0] m_read_data;
logic [W-1:0] m_rd;
logic [2:0] m_funct3;
logic [3:0] byte_en;
logic [1:0] m_ResultSrc;
logic m_RegWrite;
logic m_MemWrite;

// Writeback
logic [N-1:0] w_ALU_Result;
logic [N-1:0] w_read_data;
logic [N-1:0] w_PC_plus_4;
logic [N-1:0] w_Result;
logic [W-1:0] w_rd;
logic [1:0] w_ResultSrc;
logic w_RegWrite;

assign d_rs1 = d_instruction[19:15];
assign d_rs2 = d_instruction[24:20];
assign d_rd = d_instruction[11:7];

PC_counter PC_counter_module(
    .clk(clk),  
    .rst(rst),
    .f_stall(f_stall),
    .f_PC(f_PC),
    .f_PC_next(f_PC_next)
);

PC_plus_4_counter PC_plus_4_counter_module(
    .rst(rst),
    .f_PC(f_PC),
    .f_PC_plus_4(f_PC_plus_4)
);

Instr_Mem Instr_Mem_module(
    .clk(clk),
    .rst(rst),
    .address(f_PC),
    .instruction_out(f_instruction)
);

Reg_File Reg_File_module(
    .clk(clk),
    .rst(rst),
    .w_RegWrite(w_RegWrite),
    .address1(d_instruction[19:15]),
    .address2(d_instruction[24:20]),
    .read_address1(d_read_address1),
    .read_address2(d_read_address2),
    .address_data(w_rd),
    .write_data(w_Result)
);

Control_Unit Control_Unit_Module(
    .opcode(d_instruction[6:0]),
    .d_RegWrite(d_RegWrite),
    .d_ALUSrc(d_ALUSrc),
    .d_MemWrite(d_MemWrite),
    .d_ResultSrc(d_ResultSrc),
    .d_Branch(d_Branch),
    .d_ImmSrc(d_ImmSrc),
    .d_Jump(d_Jump),
    .d_JALRSrc(d_JALRSrc),
    .ALUOp(ALUOp)
);

ALU_Decoder ALU_Decoder_Module(
    .funct3(d_instruction[14:12]),
    .ALUOp(ALUOp),
    .funct7_5(d_instruction[30]),
    .op5(d_instruction[5]),
    .d_ALUCon(d_ALUCon)
);

Sign_Ext Sign_Ext_Module(
    .d_ImmSrc(d_ImmSrc),
    .d_ImmExt(d_ImmExt),
    .d_instruction(d_instruction)
);

Mux_JALRSrc Mux_JALRSrc_module(
    .e_PC(e_PC),
    .A(A),
    .e_JALRSrc(e_JALRSrc),
    .e_PC_or_rs1(e_PC_or_rs1)
);

PC_Target PC_Target(
    .e_PC_or_rs1(e_PC_or_rs1),
    .e_ImmExt(e_ImmExt),
    .e_JALRSrc(e_JALRSrc),
    .e_PC_Target(e_PC_Target)
);

Mux_PCTarget_to_PC Mux_PCTarget_to_PC_module(
    .e_PC_Target(e_PC_Target),
    .f_PC_plus_4(f_PC_plus_4),
    .e_PCSrc(e_PCSrc),
    .f_PC_next(f_PC_next)
);

MuxA MuxA_module(
    .e_read_address1(e_read_address1),
    .w_Result(w_Result),
    .m_ALU_Result(m_ALU_Result),
    .forwardA(forwardA),
    .A(A)
);

Mux_Reg_to_B Mux_Reg_to_B_module(
    .forwardB(forwardB),
    .e_read_address2(e_read_address2),
    .w_Result(w_Result),
    .m_ALU_Result(m_ALU_Result),
    .e_write_data(e_write_data)
);

MuxB MuxB_module(
    .e_ALUSrc(e_ALUSrc),
    .e_write_data(e_write_data),
    .e_ImmExt(e_ImmExt),
    .B(B)
);

MuxWB MuxWB_module(
    .w_ALU_Result(w_ALU_Result),
    .w_read_data(w_read_data),
    .w_PC_plus_4(w_PC_plus_4),
    .w_Result(w_Result),
    .w_ResultSrc(w_ResultSrc)
);

ALU ALU_module(
    .e_ALUCon(e_ALUCon),
    .e_ALU_Result(e_ALU_Result),
    .A(A),
    .B(B),
    .e_PC(e_PC)
);

J_and_B J_and_B_module(
    .A(A),
    .B(e_write_data),
    .e_funct3(e_funct3),
    .e_PCSrc(e_PCSrc),
    .e_Jump(e_Jump),
    .e_Branch(e_Branch)
);

Store_Decoder Store_Decoder_module(
    .e_funct3(m_funct3),
    .address_offset(m_ALU_Result[1:0]),
    .m_write_data(m_write_data),
    .byte_en(byte_en),
    .m_write_data_shifted(m_write_data_shifted)
);

Data_Mem Data_Mem_module(
    .clk(clk),
    .m_MemWrite(m_MemWrite),
    .byte_en(byte_en),
    .address(m_ALU_Result),
    .m_write_data_shifted(m_write_data_shifted),
    .m_read_address(m_read_address)
);

Load_Decoder Load_Decoder_module(
    .m_funct3(m_funct3),
    .address_offset(m_ALU_Result[1:0]),
    .m_read_address(m_read_address),
    .m_read_data(m_read_data)
);

Reg_IF_ID Reg_IF_ID_module(
    .clk(clk),
    .rst(rst),
    .f_instruction(f_instruction),
    .d_instruction(d_instruction),
    .f_PC_plus_4(f_PC_plus_4),
    .d_PC_plus_4(d_PC_plus_4),
    .f_PC(f_PC),
    .d_PC(d_PC),
    .clr(d_flush),
    .d_stall(d_stall)
);

Reg_ID_EX Reg_ID_EX_module(
    .clk(clk),
    .clr(e_flush),
    .rst(rst),
    .d_read_address1(d_read_address1),
    .d_read_address2(d_read_address2),
    .d_rd(d_rd),
    .d_ImmExt(d_ImmExt),
    .d_PC(d_PC),
    .d_PC_plus_4(d_PC_plus_4),
    .d_rs1(d_rs1),
    .d_rs2(d_rs2),
    .d_RegWrite(d_RegWrite),
    .d_ALUSrc(d_ALUSrc),
    .d_MemWrite(d_MemWrite),
    .d_Branch(d_Branch),
    .d_Jump(d_Jump),
    .d_JALRSrc(d_JALRSrc),
    .d_ResultSrc(d_ResultSrc),
    .d_ALUCon(d_ALUCon),
    .e_read_address1(e_read_address1),
    .e_read_address2(e_read_address2),
    .e_rd(e_rd),
    .e_ImmExt(e_ImmExt),
    .e_PC(e_PC),
    .e_PC_plus_4(e_PC_plus_4),
    .e_rs1(e_rs1),
    .e_rs2(e_rs2),
    .e_RegWrite(e_RegWrite),
    .e_ALUSrc(e_ALUSrc),
    .e_MemWrite(e_MemWrite),
    .e_Branch(e_Branch),
    .e_Jump(e_Jump),
    .e_JALRSrc(e_JALRSrc),
    .e_ResultSrc(e_ResultSrc),
    .e_ALUCon(e_ALUCon),
    .d_funct3(d_instruction[14:12]),
    .e_funct3(e_funct3)
);

Reg_EX_MEM Reg_EX_MEM_module(
    .clk(clk),
    .rst(rst),
    .e_ALU_Result(e_ALU_Result),
    .e_write_data(e_write_data),
    .e_PC_plus_4(e_PC_plus_4),
    .e_rd(e_rd),
    .e_ResultSrc(e_ResultSrc),
    .e_RegWrite(e_RegWrite),
    .e_MemWrite(e_MemWrite),
    .m_ALU_Result(m_ALU_Result),
    .m_write_data(m_write_data),
    .m_PC_plus_4(m_PC_plus_4),
    .m_rd(m_rd),
    .m_ResultSrc(m_ResultSrc),
    .m_RegWrite(m_RegWrite),
    .m_MemWrite(m_MemWrite),
    .e_funct3(e_funct3),
    .m_funct3(m_funct3)
);

Reg_MEM_WB Reg_MEM_WB_module(
    .clk(clk),
    .rst(rst),
    .m_ALU_Result(m_ALU_Result),
    .m_read_data(m_read_data),
    .m_PC_plus_4(m_PC_plus_4),
    .m_rd(m_rd),
    .m_ResultSrc(m_ResultSrc),
    .m_RegWrite(m_RegWrite),
    .w_ALU_Result(w_ALU_Result),
    .w_read_data(w_read_data),
    .w_PC_plus_4(w_PC_plus_4),
    .w_rd(w_rd),
    .w_ResultSrc(w_ResultSrc),
    .w_RegWrite(w_RegWrite)
);

Hazard_Unit Hazard_Unit_module(
    .f_stall(f_stall),
    .d_stall(d_stall),
    .d_flush(d_flush),
    .d_rs1(d_rs1),
    .d_rs2(d_rs2),
    .e_flush(e_flush),
    .e_rd(e_rd),
    .e_rs1(e_rs1),
    .e_rs2(e_rs2),
    .forwardA(forwardA),
    .forwardB(forwardB),
    .e_PCSrc(e_PCSrc),
    .e_ResultSrc(e_ResultSrc),
    .m_rd(m_rd),
    .m_RegWrite(m_RegWrite),
    .w_rd(w_rd),
    .w_RegWrite(w_RegWrite)
);
endmodule
