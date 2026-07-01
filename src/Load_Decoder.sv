`timescale 1ns/1ps

// Extracts and sign/zero-extends the requested byte/halfword/word from the
// raw 32-bit word returned by Data_Mem, based on funct3 and the byte offset.
module Load_Decoder import signals_pkg::*; #(parameter N = 32)
(
    input  logic [2:0]   m_funct3,
    input  logic [1:0]   address_offset, // m_ALU_Result[1:0]
    input  logic [N-1:0] m_read_address, // raw 32-bit word from Data_Mem
    output logic [N-1:0] m_read_data
);
  always_comb begin
    case (m_funct3)
      F3_BYTE: begin // lb (sign-extended)
        case (address_offset)
          2'b00: m_read_data = {{24{m_read_address[7]}},  m_read_address[7:0]};
          2'b01: m_read_data = {{24{m_read_address[15]}}, m_read_address[15:8]};
          2'b10: m_read_data = {{24{m_read_address[23]}}, m_read_address[23:16]};
          2'b11: m_read_data = {{24{m_read_address[31]}}, m_read_address[31:24]};
        endcase
      end

      F3_HALF: begin // lh (sign-extended)
        case (address_offset)
          2'b00:   m_read_data = {{16{m_read_address[15]}}, m_read_address[15:0]};
          2'b10:   m_read_data = {{16{m_read_address[31]}}, m_read_address[31:16]};
          default: m_read_data = 0;
        endcase
      end

      F3_WORD: m_read_data = m_read_address; // lw

      F3_BYTE_U: begin // lbu (zero-extended)
        case (address_offset)
          2'b00: m_read_data = {24'b0, m_read_address[7:0]};
          2'b01: m_read_data = {24'b0, m_read_address[15:8]};
          2'b10: m_read_data = {24'b0, m_read_address[23:16]};
          2'b11: m_read_data = {24'b0, m_read_address[31:24]};
        endcase
      end

      F3_HALF_U: begin // lhu (zero-extended)
        case (address_offset)
          2'b00:   m_read_data = {16'b0, m_read_address[15:0]};
          2'b10:   m_read_data = {16'b0, m_read_address[31:16]};
          default: m_read_data = 0;
        endcase
      end

      default: m_read_data = m_read_address;
    endcase
  end
endmodule
