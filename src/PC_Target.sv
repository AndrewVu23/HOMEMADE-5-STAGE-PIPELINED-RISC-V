module PC_Target #(parameter N = 32)
(
    input [N-1:0] e_PC, e_ImmExt,
    output [N-1:0] e_PC_Target
)
    assign e_PC_Target = e_ImmExt + e_PC;
endmodule