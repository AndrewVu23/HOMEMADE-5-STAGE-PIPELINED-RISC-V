module MuxA #(parameter N = 32)
(
    input logic [N-1:0] e_read_address1, w_Result, m_ALU_Result,
    input logic [1:0] forwardA,
    output logic [N-1:0] A
);
always_comb begin
    case(forwardA)
        2'b00: A = e_read_address1;
        2'b01: A = w_Result;
        2'b10: A = m_ALU_Result;
        default: A = 32'b0;
    endcase
end
endmodule