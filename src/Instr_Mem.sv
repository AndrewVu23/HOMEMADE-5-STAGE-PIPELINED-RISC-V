`timescale 1ns/1ps

module Instr_Mem #(parameter N = 32)
(
    input logic clk,
    input logic rst,
    input logic [N-1:0] address,
    output logic [N-1:0] instruction_out
);  
    // Expand the memory size to accommodate compliance suite testing (RISCOF in this case)
    logic [N-1:0] ROM[0:524287];

    // Reset gates output to 0 rather than clearing the entire array to save area & power
    // RISCV uses byte-addressing, so we shift the address right by 2 (or dividing by 4) to align the word index
    // For example, we want Instruction Memory to read address 8 (which is index 2), we have to divide the address by 4
    // Similarly, address 16 is index 4, address 20 is index 5,...
    // To right shift by 2, we select only the upper bits, cutting out 2 bits at the bottom
    // To select one of 524288 slots, we only use 19 bits since 2^19 = 524288 => [20:2]
    // Also we use negedge to avoid timing conflict, where PC register latches new address on posedge
    // -> address is still unstable at that point
    always @(negedge clk) begin
        instruction_out <= (rst) ? 32'b0 : ROM[address[20:2]];
    end

endmodule