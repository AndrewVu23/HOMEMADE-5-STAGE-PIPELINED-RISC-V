`timescale 1ns/1ps

module PC_Target #(parameter N = 32)
(
    input logic [N-1:0] e_PC_or_rs1,
    input logic [N-1:0] e_ImmExt,
    input logic e_JALRSrc,
    output logic [N-1:0] e_PC_Target
);
    logic [N-1:0] sum;
    assign sum = e_PC_or_rs1 + e_ImmExt;
    assign e_PC_Target = (e_JALRSrc) ? {sum[N-1:1], 1'b0} : sum;
endmodule