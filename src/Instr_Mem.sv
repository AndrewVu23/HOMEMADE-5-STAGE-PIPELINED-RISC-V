`timescale 1ns/1ps

module Instr_Mem #(parameter N = 32)
(
    input logic clk,
    input logic rst,
    input logic [N-1:0] address,
    output logic [N-1:0] instruction_out
);
    logic [N-1:0] ROM[0:1023];

    always @(negedge clk) begin
        instruction_out <= (rst) ? 32'b0 : ROM[address[11:2]];
    end

endmodule