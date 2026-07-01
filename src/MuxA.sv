`timescale 1ns/1ps

// Forwarding mux for ALU operand A (rs1).
module MuxA import signals_pkg::*; #(parameter N = 32)
(
    input  logic [N-1:0] e_read_address1,
    input  logic [N-1:0] w_Result,
    input  logic [N-1:0] m_ALU_Result,
    input  forward_t     forwardA,
    output logic [N-1:0] A
);
  always_comb begin
    case (forwardA)
      FWD_NONE: A = e_read_address1;
      FWD_WB:   A = w_Result;
      FWD_MEM:  A = m_ALU_Result;
      default:  A = 32'b0;
    endcase
  end
endmodule
