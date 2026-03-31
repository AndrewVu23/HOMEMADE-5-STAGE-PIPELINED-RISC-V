`timescale 1ns/1ps

module Mux_JALRSrc #(parameter N = 32)
(
    input logic [N-1:0] e_PC,
    input logic [N-1:0] A,
    input logic e_JALRSrc,
    output logic [N-1:0] e_PC_or_rs1
);
    assign e_PC_or_rs1 = (e_JALRSrc) ? A : e_PC;
endmodule
