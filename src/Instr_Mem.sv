module Instr_Mem #(parameter N = 32)
(
    input logic reset, clk,
    input logic [N-1:0] address,
    output logic [N-1:0] instruction_out
);
    logic [N-1:0] ROM[0:1023];

    always @(negedge clk) begin
        instruction_out <= (reset) ? 32'b0 : ROM[address[11:2]];
    end

endmodule