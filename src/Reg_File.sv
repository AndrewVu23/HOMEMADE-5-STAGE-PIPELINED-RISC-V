module Reg_File #(parameter N = 32, parameter W = 5)
(  
    input logic w_RegWrite, clk, rst,
    input logic [W-1:0] address1, address2, address_data,
    input logic [N-1:0] write_data,
    output logic [N-1:0] read_address1, read_address2
);

reg [31:0] Registers [31:0];

assign read_address1 = (rst == 1 || address1 == 0) ? 32'h0 : Registers[address1];
assign read_address2 = (rst == 1 || address2 == 0) ? 32'h0 : Registers[address2];

always @(negedge clk) begin
  if (w_RegWrite == 1 && address_data !== 0) Registers[address_data] <= write_data;
end
  
endmodule
