`timescale 1ns/1ps

module Mux_PCTarget_to_PC #(parameter N = 32)
(
    input logic [N-1:0] e_PC_Target,
    input logic [N-1:0] f_PC_plus_4,
    input logic e_PCSrc,
    output logic [N-1:0] f_PC_next
);
    assign f_PC_next = (e_PCSrc) ? e_PC_Target : f_PC_plus_4;
endmodule
