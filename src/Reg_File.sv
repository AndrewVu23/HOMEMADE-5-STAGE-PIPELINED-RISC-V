module Reg_File #(parameter N = 32, parameter W = 5)
(  
    input logic w_RegWrite, clk, reset,
    input logic [W-1:0] address_1, address_2, address_data,
    input logic [N-1:0] write_data,
    output logic [N-1:0] read_address_1, read_address_2
);

reg [31:0] Registers [31:0];

assign read_address_1 = (reset == 1 || address_1 == 0) ? 32'h0 : Registers[address_1];
assign read_address_2 = (reset == 1 || address_2 == 0) ? 32'h0 : Registers[address_2];

always @(negedge clk) begin
  if (w_RegWrite == 1 && address_data !== 0) Registers[address_data] <= write_data;
end
  
endmodule
