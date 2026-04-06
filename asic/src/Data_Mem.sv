`timescale 1ns/1ps

// ASIC version: 64 words with $readmemh initialization
module Data_Mem #(parameter N = 32)
(
    input logic clk,
    input logic m_MemWrite,
    input logic [3:0] byte_en,
    input logic [N-1:0] address,
    input logic [N-1:0] m_write_data_shifted,
    output logic [N-1:0] m_read_address
);
    logic [N-1:0] RAM [0:63];

    // We need the memory to read/store some data first, or else
    // the tools will look at a bunch of 0s -> blank
    // When the optimization runs, the tools will delete this blank
    // file -> no more Data Memory
    initial begin
        $readmemh("instructions.hex", RAM);
    end

    assign m_read_address = RAM[address[7:2]];

    always @(posedge clk) begin
        if (m_MemWrite) begin
            for (int i = 0; i < 4; i++) begin
                if (byte_en[i])
                    RAM[address[7:2]][(i*8)+:8] <= m_write_data_shifted[(i*8)+:8];
            end
        end
    end
endmodule
