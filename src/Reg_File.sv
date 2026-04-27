`timescale 1ns/1ps

module Reg_File #(parameter N = 32, parameter W = 5)
(  
    input logic clk,
    input logic rst,
    input logic w_RegWrite,
    input logic [W-1:0] address1,
    input logic [W-1:0] address2,
    input logic [W-1:0] address_data,
    input logic [N-1:0] write_data,
    output logic [N-1:0] read_address1,
    output logic [N-1:0] read_address2
);

reg [31:0] Registers [31:0];

// Previous: read on negedge -> write on the first half, read on the second half.
// This method works fine, however the timing will be too tight, affecting the speed
// when synthesizing.

// New fix: Bypass write_data from WB to ID.
// When WB is writing the same register that ID is reading in the same cycle, forward write_data directly.
assign read_address1 = (rst == 1 || address1 == 0) ? 32'h0 :
                       (w_RegWrite && address_data != 0 && address_data == address1) ? write_data :
                       Registers[address1];
assign read_address2 = (rst == 1 || address2 == 0) ? 32'h0 :
                       (w_RegWrite && address_data != 0 && address_data == address2) ? write_data :
                       Registers[address2];

always @(posedge clk) begin
  if (w_RegWrite == 1 && address_data !== 0) Registers[address_data] <= write_data;
end
  
endmodule
