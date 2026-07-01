`timescale 1ns/1ps

// Forwarding mux for the rs2 value (feeds ALU operand B and store data).
module Mux_Reg_to_B import signals_pkg::*; #(parameter N = 32)
(
    input  logic [N-1:0] e_read_address2,
    input  logic [N-1:0] w_Result,
    input  logic [N-1:0] m_ALU_Result,
    input  forward_t     forwardB,
    output logic [N-1:0] e_write_data
);
  always_comb begin
    case (forwardB)
      FWD_NONE: e_write_data = e_read_address2;
      FWD_WB:   e_write_data = w_Result;
      FWD_MEM:  e_write_data = m_ALU_Result;
      default:  e_write_data = 32'b0;
    endcase
  end
endmodule
