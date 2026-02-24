module Mux_Reg_to_B #(parameter N = 32)
(
    input logic [N-1:0] e_read_address2, w_Result, m_ALU_Result,
    input logic [1:0] forwardB,
    output logic [N-1:0] e_write_data
);
always_comb begin
    case(forwardB)
        2'b00: e_write_data = e_read_address2;
        2'b01: e_write_data = w_Result;
        2'b10: e_write_data = m_ALU_Result;
        default: e_write_data = 32'b0;
    endcase
end
endmodule
