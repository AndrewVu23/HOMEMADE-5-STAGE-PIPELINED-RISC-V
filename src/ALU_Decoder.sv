module ALU_Decoder(
  input logic [2:0] funct3,
  input logic [1:0] ALUOp,
  input logic funct7_5, op5,
  output logic [4:0] d_ALUCon
);
wire [1:0] op5_funct7_5;

assign op5_funct7_5 = {op5, funct7_5};

always @(*) begin
  case(ALUOp)
    2'b00: d_ALUCon = 5'b00000; // ADD (lw,sw)
    2'b01: d_ALUCon = 5'b00001; // SUB (beq)
    2'b11: d_ALUCon = op5 ? 5'b00110 : 5'b01011; // LUI : AUIPC
    2'b10: begin // R-type / I-type ALU
      if (funct3 == 3'b000) begin
        if (op5_funct7_5 == 2'b11) d_ALUCon = 5'b00001; // SUB
        else d_ALUCon = 5'b00000; // ADD / ADDI
      end
      else if (funct3 == 3'b001) d_ALUCon = 5'b00111; // SLL / SLLI
      else if (funct3 == 3'b010) d_ALUCon = 5'b00101; // SLT / SLTI
      else if (funct3 == 3'b011) d_ALUCon = 5'b01010; // SLTU / SLTIU
      else if (funct3 == 3'b100) d_ALUCon = 5'b00100; // XOR / XORI
      else if (funct3 == 3'b101) begin
        if (funct7_5) d_ALUCon = 5'b01001; // SRA / SRAI
        else d_ALUCon = 5'b01000; // SRL / SRLI
      end
      else if (funct3 == 3'b110) d_ALUCon = 5'b00011; // OR / ORI
      else if (funct3 == 3'b111) d_ALUCon = 5'b00010; // AND / ANDI
      else d_ALUCon = 5'b00000;
    end
    default: d_ALUCon = 5'b00000;
  endcase
end
endmodule