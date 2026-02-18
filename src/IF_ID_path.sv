module IF_ID_path #(parameter N = 32)
(
    input logic clk, reset,
    input logic stall,
    input logic w_RegWrite,
    input logic [4:0] address_data,
    input logic [N-1:0] w_Result
);
logic [N-1:0] f_instruction, f_PC_next, f_PC, f_PC_plus_4;
logic [N-1:0] d_instruction, d_read_address1, d_read_address2, d_ImmExt;
logic [N-1:0] d_PC, d_PC_plus_4; // w_Result;
logic f_stall;
assign f_stall = stall;
logic d_RegWrite, d_ALUSrc, d_MemWrite, d_Branch, d_Jump, d_stall, d_flush;
logic [1:0] ALUOp, d_ImmSrc, d_ResultSrc;
// logic [N-1:0] d_rs1, d_rs2, d_rd, d_ImmExt;
// logic [4:0] address_data;
// logic w_RegWrite;

assign f_PC_next = f_PC_plus_4;
assign d_flush = 1'b0;

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
    .address_data(address_data),
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

Sign_Ext Sign_Ext_Module(
    .d_ImmSrc(d_ImmSrc),
    .d_ImmExt(d_ImmExt),
    .d_instruction(d_instruction)
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
endmodule
