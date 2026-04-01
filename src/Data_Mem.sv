`timescale 1ns/1ps

module Data_Mem #(parameter N = 32)
(
  input logic clk,
  input logic m_MemWrite,
  input logic [3:0] byte_en,
  input logic [N-1:0] address,
  input logic [N-1:0] m_write_data_shifted,
  output logic [N-1:0] m_read_address
);
  logic [N-1:0] RAM [1023:0];

  // Same trick here (Instr_Mem)
  assign m_read_address = RAM[address[11:2]];

  always @(posedge clk) begin
    if (m_MemWrite) begin
      for (int i = 0; i < 4; i++) begin
        if (byte_en[i]) begin
          RAM[address[11:2]][(i*8)+:8] <= m_write_data_shifted[(i*8)+:8];
        end
      end
    end
  end
endmodule
