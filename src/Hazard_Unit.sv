`timescale 1ns/1ps

module Hazard_Unit #(parameter N = 32, parameter W = 5)
(
    input logic [W-1:0] e_rd,
    input logic [W-1:0] e_rs1,
    input logic [W-1:0] e_rs2,
    input logic [W-1:0] m_rd,
    input logic [W-1:0] w_rd,
    input logic [W-1:0] d_rs1,
    input logic [W-1:0] d_rs2,
    input logic [1:0] e_ResultSrc,
    input logic m_RegWrite,
    input logic w_RegWrite,
    input logic e_PCSrc,
    output logic f_stall,
    output logic d_stall,
    output logic d_flush,
    output logic e_flush,
    output logic [1:0] forwardA,
    output logic [1:0] forwardB
);
logic lw_stall;

always_comb begin
    lw_stall = e_ResultSrc[0] & ((d_rs1 == e_rd ) | (d_rs2 == e_rd));
    f_stall = lw_stall;
    d_stall = lw_stall;
    e_flush = lw_stall | e_PCSrc;
    d_flush = e_PCSrc;
    
    if (((e_rs1 == m_rd) & m_RegWrite) & (e_rs1 != 0)) forwardA = 2'b10;
    else if (((e_rs1 == w_rd) & w_RegWrite) & (e_rs1 != 0)) forwardA = 2'b01;
    else forwardA = 2'b00;

    if (((e_rs2 == m_rd) & m_RegWrite) & (e_rs2 != 0)) forwardB = 2'b10;
    else if (((e_rs2 == w_rd) & w_RegWrite) & (e_rs2 != 0)) forwardB = 2'b01;
    else forwardB = 2'b00;
end
endmodule