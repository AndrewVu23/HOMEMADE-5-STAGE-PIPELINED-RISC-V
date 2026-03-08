module J_and_B #(parameter N = 32)
(
    input logic [N-1:0] A, B,
    input logic [2:0] e_funct3,
    input logic e_Jump, e_Branch,
    output logic e_PCSrc
);
logic branch_taken, eq, lt, ltu;

assign eq  = (A == B);
assign lt  = ($signed(A) < $signed(B));
assign ltu = (A < B);

always @(*) begin
  case(e_funct3)
    3'b000:  branch_taken =  eq;  // BEQ
    3'b001:  branch_taken = !eq;  // BNE
    3'b100:  branch_taken =  lt;  // BLT
    3'b101:  branch_taken = !lt;  // BGE
    3'b110:  branch_taken =  ltu; // BLTU
    3'b111:  branch_taken = !ltu; // BGEU
    default: branch_taken = 1'b0;
  endcase
end

assign e_PCSrc = (e_Branch & branch_taken) | e_Jump;

endmodule