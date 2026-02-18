module PC_counter #(parameter N = 32)
(
  input logic clk, reset, stall,
  input logic [N-1:0] f_PC_next,
  output logic [N-1:0] f_PC
);
always_ff @(posedge clk) begin
    if (reset) f_PC = 0;
    else (!stall) f_PC = f_PC_next;
end
endmodule