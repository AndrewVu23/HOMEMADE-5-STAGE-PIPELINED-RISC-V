module ALU_Decoder(
  input logic [2:0] funct3,
  input logic [1:0] ALUOp,
  input logic funct7_5, op5,
  output logic [2:0] ALUCon
);
wire [1:0] op5_funct7_5;

assign op5_funct7_5 = {op5, funct7_5};

always @(*) begin
  case(ALUOp)
    2'b00: ALUCon = 3'b000;
    2'b01: ALUCon = 3'b001;
    2'b10: begin
    if (funct3 == 3'b000) begin
      if (op5_funct7_5 == 2'b11) ALUCon = 3'b001;
      else ALUCon = 3'b000;
    end
    else if (funct3 == 3'b010) ALUCon = 3'b101; 
    else if (funct3 == 3'b110) ALUCon = 3'b011;
    else if(funct3 == 3'b111) ALUCon = 3'b010;
    end
    default: ALUCon = 3'b000;
  endcase
end
endmodule