`timescale 1ns/1ps

module PC_plus_4_counter #(parameter N = 32)
(
    input logic rst,
    input logic [N-1:0] f_PC,
    output logic [N-1:0] f_PC_plus_4
);
assign f_PC_plus_4 = (rst) ? 32'h0 : f_PC + 32'd4;
endmodule
