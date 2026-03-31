`timescale 1ns/1ps

module Reg_ID_EX #(parameter N = 32, parameter W = 5)
(
    input logic clk, clr, rst,
    input logic [N-1:0] d_read_address1, d_read_address2, d_ImmExt, d_PC, d_PC_plus_4, 
    input logic [W-1:0] d_rs1, d_rs2, d_rd,
    input logic d_RegWrite, d_ALUSrc, d_MemWrite, d_Branch, d_Jump,
    input logic [1:0] d_ResultSrc,
    input logic [4:0] d_ALUCon,
    input logic [2:0] d_funct3,
    output logic [N-1:0] e_read_address1, e_read_address2, e_ImmExt, e_PC, e_PC_plus_4,
    output logic [W-1:0] e_rs1, e_rs2, e_rd,
    output logic e_RegWrite, e_ALUSrc, e_MemWrite, e_Branch, e_Jump,
    output logic [1:0] e_ResultSrc,
    output logic [4:0] e_ALUCon,
    output logic [2:0] e_funct3
);
always_ff @(posedge clk) begin
     if (clr | rst) begin
        e_read_address1 <= 0;
        e_read_address2 <= 0;
        e_rd <= 0;
        e_ImmExt <= 0;
        e_PC <= 0;
        e_PC_plus_4 <= 0;
        e_rs1 <= 0;
        e_rs2 <= 0;
        e_RegWrite <= 0;
        e_ALUSrc <= 0;
        e_MemWrite <= 0;
        e_Branch <= 0;
        e_Jump <= 0;
        e_ResultSrc <= 0;
        e_ALUCon <= 0;
        e_funct3 <= 0;
    end
    else begin
        e_read_address1 <= d_read_address1;
        e_read_address2 <= d_read_address2;
        e_rd <= d_rd;
        e_ImmExt <= d_ImmExt;
        e_PC <= d_PC;
        e_PC_plus_4 <= d_PC_plus_4;
        e_rs1 <= d_rs1;
        e_rs2 <= d_rs2;
        e_RegWrite <= d_RegWrite;
        e_ALUSrc <= d_ALUSrc;
        e_MemWrite <= d_MemWrite;
        e_Branch <= d_Branch;
        e_Jump <= d_Jump;
        e_ResultSrc <= d_ResultSrc;
        e_ALUCon <= d_ALUCon;
        e_funct3 <= d_funct3;
    end
end
endmodule
