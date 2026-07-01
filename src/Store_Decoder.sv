`timescale 1ns/1ps

// Aligns store data to the target byte lanes and produces the byte-enable mask
// for byte/halfword/word stores.
module Store_Decoder import signals_pkg::*; #(parameter N = 32)
(
    input  logic [2:0]   e_funct3,
    input  logic [1:0]   address_offset, // m_ALU_Result[1:0]
    input  logic [N-1:0] m_write_data,
    output logic [3:0]   byte_en,
    output logic [N-1:0] m_write_data_shifted
);
  always_comb begin
    case (e_funct3)
      F3_WORD: begin // sw
        byte_en = 4'b1111;
        m_write_data_shifted = m_write_data;
      end

      F3_HALF: begin // sh
        case (address_offset)
          2'b00:   begin byte_en = 4'b0011; m_write_data_shifted = {16'b0, m_write_data[15:0]}; end
          2'b10:   begin byte_en = 4'b1100; m_write_data_shifted = {m_write_data[15:0], 16'b0}; end
          default: begin byte_en = 4'b0000; m_write_data_shifted = m_write_data; end
        endcase
      end

      F3_BYTE: begin // sb
        case (address_offset)
          2'b00:   begin byte_en = 4'b0001; m_write_data_shifted = {24'b0, m_write_data[7:0]}; end
          2'b01:   begin byte_en = 4'b0010; m_write_data_shifted = {16'b0, m_write_data[7:0], 8'b0}; end
          2'b10:   begin byte_en = 4'b0100; m_write_data_shifted = {8'b0, m_write_data[7:0], 16'b0}; end
          2'b11:   begin byte_en = 4'b1000; m_write_data_shifted = {m_write_data[7:0], 24'b0}; end
          default: begin byte_en = 4'b0000; m_write_data_shifted = m_write_data; end
        endcase
      end

      default: begin
        byte_en = 4'b0000;
        m_write_data_shifted = m_write_data;
      end
    endcase
  end
endmodule
