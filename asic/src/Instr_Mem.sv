`timescale 1ns/1ps

// ASIC version: 64 words with $readmemh initialization
module Instr_Mem #(parameter N = 32)
(
    input logic clk,
    input logic rst,
    input logic [N-1:0] address,
    output logic [N-1:0] instruction_out
);
    logic [N-1:0] ROM[0:63];

    // We need the memory to read/store some data first, or else
    // the tools will look at a bunch of 0s -> blank
    // When the optimization runs, the tools will delete this blank
    // file -> no more Instruction Memory
    initial begin
        $readmemh("instructions.hex", ROM);
    end

    always @(negedge clk) begin
        instruction_out <= (rst) ? 32'b0 : ROM[address[7:2]];
    end

endmodule
