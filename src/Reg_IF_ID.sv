`timescale 1ns/1ps

module Reg_IF_ID #(parameter N = 32)
(
    input logic clk,
    input logic clr,
    input logic d_stall,
    input logic rst,
    input logic [N-1:0] f_instruction,
    input logic [N-1:0] f_PC,
    input logic [N-1:0] f_PC_plus_4,
    output logic [N-1:0] d_instruction,
    output logic [N-1:0] d_PC,
    output logic [N-1:0] d_PC_plus_4
);
always_ff @(posedge clk) begin
    if (clr | rst) begin
        d_instruction <= 0;
        d_PC <= 0;
        d_PC_plus_4 <= 0;
    end
    else if (!d_stall) begin
        d_instruction <= f_instruction;
        d_PC <= f_PC;
        d_PC_plus_4 <= f_PC_plus_4;
    end
end
endmodule