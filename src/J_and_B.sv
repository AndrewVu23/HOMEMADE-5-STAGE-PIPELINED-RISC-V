module J_and_B(
    input logic e_Jump, e_Branch, zero,
    output logic e_PCSrc
);
    wire logic Jump_out;
    assign Jump_out = e_Branch & zero;
    assign e_PCSrc = Jump_out ^ e_Jump;
endmodule