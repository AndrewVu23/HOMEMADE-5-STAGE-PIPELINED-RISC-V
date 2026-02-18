module Data_Mem(
  input clk, m_MemWrite,
  input logic [31:0] address, m_write_data,
  output logic [31:0] m_read_address
);
  logic [31:0] RAM [1023:0];

  assign m_read_address = RAM[address[11:2]];

  always @(posedge clk) begin
    if (m_MemWrite) RAM[address[11:2]] = m_write_data;
  end
endmodule