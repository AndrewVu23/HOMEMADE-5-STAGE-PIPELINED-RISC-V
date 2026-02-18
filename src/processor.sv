module processor #(parameter N = 32, parameter W = 5)
(
    input logic clk, reset,
    input logic stall
);
logic [N-1:0] f_instruction, f_PC_next, f_PC, f_PC_plus_4;
logic [N-1:0] d_instruction, d_read_address1, d_read_address2, d_ImmExt;
logic [N-1:0] d_PC, d_PC_plus_4;
logic [N-1:0] w_Result;
logic f_stall;
logic d_RegWrite, d_ALUSrc, d_MemWrite, d_Branch, d_Jump, d_stall, d_flush;
logic [2:0] d_ALUCon;
logic [1:0] ALUOp, d_ImmSrc, d_ResultSrc;
logic [W-1:0] d_rs1, d_rs2, d_rd;
logic [N-1:0] e_read_address1, e_read_address2, e_ImmExt, e_PC, e_PC_plus_4;
logic [W-1:0] e_rs1, e_rs2, e_rd;
logic e_RegWrite, e_ALUSrc, e_MemWrite, e_Branch, e_Jump, e_PCSrc;
logic [1:0] e_ResultSrc;
logic [2:0] e_ALUCon;
logic e_flush;
logic [1:0] forwardA, forwardB;
logic [N-1:0] e_ALUResult, A, B, e_PC_Target;
logic zero;
logic [N-1:0] e_write_data;
logic [N-1:0] m_ALU_Result, m_write_data, m_PC_plus_4, m_read_address;
logic [W-1:0] m_rd;
logic [1:0] m_ResultSrc;
logic m_RegWrite, m_MemWrite;
logic [N-1:0] w_ALU_Result, w_read_address, w_PC_plus_4;
logic [W-1:0] w_rd;
logic [1:0] w_ResultSrc;
logic w_RegWrite;


assign d_rs1 = d_instruction[19:15];
assign d_rs2 = d_instruction[24:20];
assign d_rd = d_instruction[11:7];

PC_counter PC_counter_module(
    .clk(clk),  
    .reset(reset),
    .f_stall(f_stall),
    .f_PC(f_PC),
    .f_PC_next(f_PC_next)
);

PC_plus_4_counter PC_plus_4_counter_module(
    .reset(reset),
    .f_PC(f_PC),
    .f_PC_plus_4(f_PC_plus_4)
);

Instr_Mem Instr_Mem_module(
    .clk(clk),
    .reset(reset),
    .address(f_PC),
    .instruction_out(f_instruction)
);

Reg_File Reg_File_module(
    .clk(clk),
    .reset(reset),
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

PC_Target PC_Target(
    .e_PC(e_PC),
    .e_ImmExt(e_ImmExt),
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

ALU ALU_module(
    .e_ALUCon(e_ALUCon),
    .e_ALUResult(e_ALUResult),
    .A(A),
    .B(B),
    .zero(zero)
);

J_and_B J_and_B_module(
    .zero(zero),
    .e_PCSrc(e_PCSrc),
    .e_Jump(e_Jump),
    .e_Branch(e_Branch)
);

Data_Mem Data_Mem_module(
    .clk(clk),
    .m_MemWrite(m_MemWrite),
    .address(m_ALU_Result),
    .m_write_data(m_write_data),
    .m_read_address(m_read_address)
);

Reg_IF_ID Reg_IF_ID_module(
    .clk(clk),
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
    .e_ResultSrc(e_ResultSrc),
    .e_ALUCon(e_ALUCon)
);

Reg_EX_MEM Reg_EX_MEM_module(
    .clk(clk),
    .e_ALU_Result(e_ALUResult),
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
    .m_MemWrite(m_MemWrite)
);

Reg_MEM_WB Reg_MEM_WB_module(
    .clk(clk),
    .m_ALU_Result(m_ALU_Result),
    .m_read_address(m_read_address),
    .m_PC_plus_4(m_PC_plus_4),
    .m_rd(m_rd),
    .m_ResultSrc(m_ResultSrc),
    .m_RegWrite(m_RegWrite),
    .w_ALU_Result(w_ALU_Result),
    .w_read_address(w_read_address),
    .w_PC_plus_4(w_PC_plus_4),
    .w_rd(w_rd),
    .w_ResultSrc(w_ResultSrc),
    .w_RegWrite(w_RegWrite)
);

endmodule
