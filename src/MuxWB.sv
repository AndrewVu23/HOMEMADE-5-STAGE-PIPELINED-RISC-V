`timescale 1ns/1ps

// Writeback mux: selects the value written back to the register file.
module MuxWB import signals_pkg::*; #(parameter N = 32)
(
    input  logic [N-1:0] w_ALU_Result,
    input  logic [N-1:0] w_read_data,
    input  logic [N-1:0] w_PC_plus_4,
    input  resultsrc_t   w_ResultSrc,
    output logic [N-1:0] w_Result
);
  always_comb begin
    case (w_ResultSrc)
      RESULT_ALU:      w_Result = w_ALU_Result;
      RESULT_MEM:      w_Result = w_read_data;
      RESULT_PC_PLUS4: w_Result = w_PC_plus_4;
      default:         w_Result = 32'b0;
    endcase
  end
endmodule
