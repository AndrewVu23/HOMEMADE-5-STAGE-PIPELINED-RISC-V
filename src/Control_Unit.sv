module Control_Unit(
  input logic [6:0] opcode,
  output logic d_RegWrite, d_ALUSrc, d_MemWrite, d_Branch, d_Jump,
  output logic [1:0] d_ImmSrc, ALUOp, d_ResultSrc
);
  always @(*) begin
    case(opcode)
      7'b0000011: begin
        d_RegWrite = 1; d_ALUSrc = 1; d_MemWrite = 0; d_ResultSrc = 2'b01; d_Branch = 0; d_Jump = 0;
        d_ImmSrc = 2'b00; ALUOp = 2'b00;
      end
      7'b0100011: begin
        d_RegWrite = 0; d_ALUSrc = 1; d_MemWrite = 1; d_ResultSrc = 1'bx; d_Branch = 0; d_Jump = 0;
        d_ImmSrc = 2'b01; ALUOp = 2'b00;
      end
      7'b0110011: begin
        d_RegWrite = 1; d_ALUSrc = 0; d_MemWrite = 0; d_ResultSrc = 2'b00; d_Branch = 0; d_Jump = 0;   
        d_ImmSrc = 2'bxx; ALUOp = 2'b10;
      end
      7'b1100011: begin
        d_RegWrite = 0; d_ALUSrc = 0; d_MemWrite = 0; d_ResultSrc = 2'bxx; d_Branch = 1; d_Jump = 0;
        d_ImmSrc = 2'b10; ALUOp = 2'b01;
      end
      7'b0010011: begin
        d_RegWrite = 1; d_ALUSrc = 1; d_MemWrite = 0; d_ResultSrc = 2'b00; d_Branch = 0; d_Jump = 0;
        d_ImmSrc = 2'b00; ALUOp = 2'b10;
      end
      7'b1101111: begin
        d_RegWrite = 1; d_ALUSrc = 1'bx; d_MemWrite = 0; d_ResultSrc = 2'b10; d_Branch = 0; d_Jump = 1;
        d_ImmSrc = 2'b11; ALUOp = 2'bxx;
      end
      default: begin
        d_RegWrite = 0; d_ALUSrc = 0; d_MemWrite = 0; d_ResultSrc = 0; d_Branch = 0; d_Jump = 0;
        d_ImmSrc = 2'b00; ALUOp = 2'b00;
      end
    endcase
  end
endmodule