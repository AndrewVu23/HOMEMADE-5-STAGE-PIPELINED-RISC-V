`timescale 1ns/1ps

// EX/MEM pipeline register.
module Reg_EX_MEM import signals_pkg::*; #(parameter N = 32, parameter W = 5)
(
    input  logic         clk,
    input  logic         rst,
    input  logic [N-1:0] e_ALU_Result,
    input  logic [N-1:0] e_write_data,
    input  logic [N-1:0] e_PC_plus_4,
    input  logic [W-1:0] e_rd,
    input  resultsrc_t   e_ResultSrc,
    input  logic         e_RegWrite,
    input  logic         e_MemWrite,
    input  logic [2:0]   e_funct3,
    output logic [N-1:0] m_ALU_Result,
    output logic [N-1:0] m_write_data,
    output logic [N-1:0] m_PC_plus_4,
    output logic [W-1:0] m_rd,
    output resultsrc_t   m_ResultSrc,
    output logic         m_RegWrite,
    output logic         m_MemWrite,
    output logic [2:0]   m_funct3
);
  always_ff @(posedge clk) begin
    if (rst) begin
      m_ALU_Result <= 0;
      m_write_data <= 0;
      m_PC_plus_4  <= 0;
      m_rd         <= 0;
      m_ResultSrc  <= RESULT_ALU;
      m_RegWrite   <= 0;
      m_MemWrite   <= 0;
      m_funct3     <= 0;
    end
    else begin
      m_ALU_Result <= e_ALU_Result;
      m_write_data <= e_write_data;
      m_PC_plus_4  <= e_PC_plus_4;
      m_rd         <= e_rd;
      m_ResultSrc  <= e_ResultSrc;
      m_RegWrite   <= e_RegWrite;
      m_MemWrite   <= e_MemWrite;
      m_funct3     <= e_funct3;
    end
  end
endmodule
