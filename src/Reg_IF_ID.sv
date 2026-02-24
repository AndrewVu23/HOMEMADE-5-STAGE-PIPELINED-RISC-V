module Reg_IF_ID #(parameter N = 32)
(
    input logic [N-1:0] f_instruction, f_PC, f_PC_plus_4,
    input logic clk, clr, d_stall, reset, 
    output logic [N-1:0] d_instruction, d_PC, d_PC_plus_4
);
always_ff @(posedge clk) begin
    if (clr | reset) begin
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