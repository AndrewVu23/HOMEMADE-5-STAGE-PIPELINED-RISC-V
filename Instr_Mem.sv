module Instr_Mem(#parameter N = 32)
(
    input reset,
    input [N-1:0] address,
    output [N-1:0] instruction_out
);
logic [N-1:0] instruction_mem [1023:0];

assign instruction_out = (reset) ? 0 : instruction_mem[address[11:2]];

endmodule