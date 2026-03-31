`timescale 1ns/1ps

module Data_Mem #(parameter N = 32)
(
  input logic clk, m_MemWrite,
  input logic [N-1:0] address, m_write_data,
  output logic [N-1:0] m_read_address
);
  logic [N-1:0] RAM [1023:0];

  assign m_read_address = RAM[address[11:2]];

  always @(posedge clk) begin
    if (m_MemWrite) RAM[address[11:2]] = m_write_data;
  end
endmodule