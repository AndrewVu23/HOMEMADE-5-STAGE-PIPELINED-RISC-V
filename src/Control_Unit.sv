module Control_Unit(
  input logic [6:0] opcode,
  output logic d_RegWrite, d_ALUSrc, d_MemWrite, d_Branch, d_Jump,
  output logic [2:0] d_ImmSrc, 
  output logic [1:0] ALUOp, d_ResultSrc
);
  always @(*) begin
    case(opcode)
      7'b0000011: begin // Load
        d_RegWrite = 1; d_ALUSrc = 1; d_MemWrite = 0; d_ResultSrc = 2'b01; d_Branch = 0; d_Jump = 0;
        d_ImmSrc = 3'b000; ALUOp = 2'b00;
      end
      7'b0100011: begin // Store
        d_RegWrite = 0; d_ALUSrc = 1; d_MemWrite = 1; d_ResultSrc = 2'b00; d_Branch = 0; d_Jump = 0;
        d_ImmSrc = 3'b001; ALUOp = 2'b00;
      end
      7'b0110011: begin // R-type
        d_RegWrite = 1; d_ALUSrc = 0; d_MemWrite = 0; d_ResultSrc = 2'b00; d_Branch = 0; d_Jump = 0;   
        d_ImmSrc = 3'bxxx; ALUOp = 2'b10;
      end
      7'b1100011: begin // Branch
        d_RegWrite = 0; d_ALUSrc = 0; d_MemWrite = 0; d_ResultSrc = 2'b00; d_Branch = 1; d_Jump = 0;
        d_ImmSrc = 3'b010; ALUOp = 2'b01;
      end
      7'b0010011: begin // I-type
        d_RegWrite = 1; d_ALUSrc = 1; d_MemWrite = 0; d_ResultSrc = 2'b00; d_Branch = 0; d_Jump = 0;
        d_ImmSrc = 3'b000; ALUOp = 2'b10;
      end
      7'b1101111: begin // J-type (jal)
        d_RegWrite = 1; d_ALUSrc = 1'bx; d_MemWrite = 0; d_ResultSrc = 2'b10; d_Branch = 0; d_Jump = 1;
        d_ImmSrc = 3'b011; ALUOp = 2'bxx;
      end
      7'b0110111, 7'b0010111: begin // U-type (lui)
        d_RegWrite = 1; d_ALUSrc = 1; d_MemWrite = 0; d_ResultSrc = 2'b00; d_Branch = 0; d_Jump = 0;
        d_ImmSrc = 3'b100; ALUOp = 2'b11;
      end
      default: begin
        d_RegWrite = 0; d_ALUSrc = 0; d_MemWrite = 0; d_ResultSrc = 0; d_Branch = 0; d_Jump = 0;
        d_ImmSrc = 3'b000; ALUOp = 2'b00;
      end
    endcase
  end
endmodule