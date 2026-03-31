`timescale 1ns/1ps

module Mux_WB_to_Reg #(parameter N = 32)
(
    input logic [N-1:0] w_ALU_Result, w_read_address, w_PC_plus_4,
    input logic [1:0] w_ResultSrc,
    output logic [N-1:0] w_Result
);
always_comb begin
    case(w_ALU_Result)
        2'b00: w_Result = w_ALU_Result;
        2'b01: w_Result = w_read_address;
        2'b10: w_Result = w_PC_plus_4;
        default: w_Result = 32'b0;
    endcase
end
endmodule