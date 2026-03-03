module Reg_EX_MEM #(parameter N = 32, parameter W = 5)
(
    input logic clk, rst,
    input logic [N-1:0] e_ALU_Result, e_write_data, e_PC_plus_4,
    input logic [W-1:0] e_rd,
    input logic [1:0] e_ResultSrc,
    input logic e_RegWrite, e_MemWrite,
    output logic [N-1:0] m_ALU_Result, m_write_data, m_PC_plus_4,
    output logic [W-1:0] m_rd,
    output logic [1:0] m_ResultSrc,
    output logic m_RegWrite, m_MemWrite
);
    always_ff @(posedge clk) begin
        if (rst) begin
            m_ALU_Result <= 0;
            m_write_data <= 0;
            m_PC_plus_4 <= 0;
            m_rd <= 0;
            m_ResultSrc <= 0;
            m_RegWrite <= 0;
            m_MemWrite <= 0;
        end
        else begin
            m_ALU_Result <= e_ALU_Result;
            m_write_data <= e_write_data;
            m_PC_plus_4 <= e_PC_plus_4;
            m_rd <= e_rd;
            m_ResultSrc <= e_ResultSrc;
            m_RegWrite <= e_RegWrite;
            m_MemWrite <= e_MemWrite;
        end
    end
endmodule