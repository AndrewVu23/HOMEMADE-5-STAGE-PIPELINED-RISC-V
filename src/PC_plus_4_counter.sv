module PC_plus_4_counter #(parameter N = 32)
(
    input logic reset,
    input logic [N-1:0] f_PC,
    output logic [N-1:0] f_PC_plus_4
);
assign f_PC_plus_4 = (reset) ? 32'h0 : f_PC + 32'd4;
endmodule
