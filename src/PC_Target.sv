`timescale 1ns/1ps

module PC_Target #(parameter N = 32)
(
    input logic [N-1:0] e_PC_or_rs1,
    input logic [N-1:0] e_ImmExt,
    input logic e_JALRSrc,
    output logic [N-1:0] e_PC_Target
);
    logic [N-1:0] target;

    // Target to jump to
    assign target = e_PC_or_rs1 + e_ImmExt;

    // According to RISC-V specs, JALR need to clear the LSB of the target to 
    // ensure the jump is always 2-byte align (halfword).
    // The reason for 2-byte instead of 4-byte is because we can implement 
    // C extenstion (compressed), which used 16 bits instead of 32 bits 
    // (but yeah there's no way I'm doing that so)
    // In other words: target = (rs1 + imm) & ~1
    assign e_PC_Target = (e_JALRSrc) ? {target[N-1:1], 1'b0} : target;
endmodule