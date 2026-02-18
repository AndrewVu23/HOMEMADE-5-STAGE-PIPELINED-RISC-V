module MuxB #(parameter N = 32)
(
    input logic [N-1:0] e_write_data, e_ImmExt,
    input logic e_ALUSrc,
    output logic [N-1:0] B
)
always_ff @(*) begin
    case(e_ALUSrc)
        1'b0: B = e_write_data;
        1'b1: B = e_ImmExt;
    endcase
end
endmodule