module Hazard_Unit #(parameter N = 32)
(
    input logic [N-1:0] e_rd, e_rs1, e_rs2, m_rd, w_rd, d_rs1, d_rs2,
    output logic f_stall, d_stall, d_flush, e_flush, e_ResultSrc, m_RegWrite, w_RegWrite
    output logic [1:0] forwardA, forwardB, e_PCSrc
);
logic lw_stall;

always_comb begin
    lw_stall = e_ResultSrc[0] & ((d_rs1 == e_rd ) | (d_rs2 == e_rd));
    f_stall = lw_stall;
    d_stall = lw_stall;
    e_flush = lw_stall | e_PCSrc;
    d_flush = e_PCSrc;
    
    if ((e_rs1 == m_rd) & m_RegWrite) & (e_rs1 != 0) forwardA = 10;
    else if ((e_rs1 == w_rd) & w_RegWrite) & (e_rs1 != 0) forwardA = 01;
    else forwardA = 00;

    if ((e_rs2 == m_rd) & m_RegWrite) & (e_rs2 != 0) forwardB = 10;
    else if ((e_rs2 == w_rd) & w_RegWrite) & (e_rs2 != 0) forwardB = 01;
    else forwardB = 00;
end
endmodule