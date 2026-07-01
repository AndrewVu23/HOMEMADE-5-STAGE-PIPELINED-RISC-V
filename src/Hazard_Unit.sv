`timescale 1ns/1ps

// Detects data/control hazards: generates load-use stalls, branch/jump flushes,
// and the forwarding selects for the two ALU operands.
module Hazard_Unit import signals_pkg::*; #(parameter N = 32, parameter W = 5)
(
    input  logic [W-1:0] e_rd,
    input  logic [W-1:0] e_rs1,
    input  logic [W-1:0] e_rs2,
    input  logic [W-1:0] m_rd,
    input  logic [W-1:0] w_rd,
    input  logic [W-1:0] d_rs1,
    input  logic [W-1:0] d_rs2,
    input  resultsrc_t   e_ResultSrc,
    input  logic         m_RegWrite,
    input  logic         w_RegWrite,
    input  logic         e_PCSrc,
    output logic         f_stall,
    output logic         d_stall,
    output logic         d_flush,
    output logic         e_flush,
    output forward_t     forwardA,
    output forward_t     forwardB
);
  logic lw_stall;

  always_comb begin

    // A load is in EX, but its data won't be available until end of MEM/start of WB
    // The next instruction in ID needs that register value right now
    // -> We stall IF/ID for one cycle so the load can reach MEM, then forward
    // the value from MEM to EX (via forwarding logic below)
    lw_stall = (e_ResultSrc == RESULT_MEM) & ((d_rs1 == e_rd) | (d_rs2 == e_rd));
    f_stall  = lw_stall;
    d_stall  = lw_stall;

    // Insert bubble in EX, or else the old instruction would advance to MEM -> duplication
    e_flush = lw_stall | e_PCSrc;

    // Jump/Branch in the EX stage -> instructions in the ID stage are stale
    // -> Flush all the instructions in the ID register
    d_flush = e_PCSrc;

    // Forwarding for ALU input A (rs1)
    // We evaluate the register at MEM stage first since it is more recent (1 previous cycle)
    // compared to the register at WB stage (2 previous cycles)
    if      (((e_rs1 == m_rd) & m_RegWrite) & (e_rs1 != 0)) forwardA = FWD_MEM;  // ALU result forwarded from MEM
    else if (((e_rs1 == w_rd) & w_RegWrite) & (e_rs1 != 0)) forwardA = FWD_WB;   // result forwarded from WB
    else                                                    forwardA = FWD_NONE; // use rs1 straight from the register file

    // Forwarding for ALU input B (rs2)
    if      (((e_rs2 == m_rd) & m_RegWrite) & (e_rs2 != 0)) forwardB = FWD_MEM;
    else if (((e_rs2 == w_rd) & w_RegWrite) & (e_rs2 != 0)) forwardB = FWD_WB;
    else                                                    forwardB = FWD_NONE;
  end
endmodule
