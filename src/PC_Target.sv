module PC_Target #(parameter N = 32)
(
    input logic [N-1:0] e_PC, e_ImmExt,
    output logic [N-1:0] e_PC_Target
);
    assign e_PC_Target = e_ImmExt + e_PC;
endmodule