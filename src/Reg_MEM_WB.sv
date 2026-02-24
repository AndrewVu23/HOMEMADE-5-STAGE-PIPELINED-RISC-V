module Reg_MEM_WB #(parameter N = 32, parameter W = 5)
(
    input clk, reset,
    input logic [N-1:0] m_read_address, m_PC_plus_4, m_ALU_Result,
    input logic [W-1:0] m_rd, 
    input logic [1:0] m_ResultSrc,
    input logic m_RegWrite,
    output logic [N-1:0] w_ALU_Result, w_read_address, w_PC_plus_4,
    output logic [W-1:0] w_rd,
    output logic [1:0] w_ResultSrc,
    output logic w_RegWrite
);
    always_ff @(posedge clk) begin
        if (reset) begin
            w_ALU_Result <= 0;
            w_read_address <= 0;
            w_PC_plus_4 <= 0;
            w_rd <= 0;
            w_ResultSrc <= 0;
            w_RegWrite <= 0;
        end
        else begin
            w_ALU_Result <= m_ALU_Result;
            w_read_address <= m_read_address;
            w_PC_plus_4 <= m_PC_plus_4;
            w_rd <= m_rd;
            w_ResultSrc <= m_ResultSrc;
            w_RegWrite <= m_RegWrite;
        end
    end
endmodule