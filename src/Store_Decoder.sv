module Store_Decoder #(parameter N = 32)
(
    input logic [2:0] e_funct3,
    input logic [1:0] address_offset, // m_ALU_Result [1:0]
    input logic [N-1:0] m_write_data,
    output logic [3:0] byte_en,
    output logic [N-1:0] m_write_data_shifted
);
always_comb begin
    case(e_funct3)

        // SW
        3'b010: begin
            byte_en = 4'b1111;
            m_write_data_shifted = m_write_data;
        end

        // SH
        3'b001: begin
            case(address_offset)
                2'b00: begin byte_en = 4'b0011; m_write_data_shifted = {16'b0, m_write_data[15:0]}; end
                2'b10: begin byte_en = 4'b1100; m_write_data_shifted = {m_write_data[15:0], 16'b0}; end
                default: begin byte_en = 4'b0000; m_write_data_shifted = m_write_data; end
            endcase
        end

        // SB
        3'b000: begin
            case(address_offset)
                2'b00: begin byte_en = 4'b0001; m_write_data_shifted = {24'b0, m_write_data[7:0]}; end
                2'b01: begin byte_en = 4'b0010; m_write_data_shifted = {16'b0, m_write_data[7:0], 8'b0}; end
                2'b10: begin byte_en = 4'b0100; m_write_data_shifted = {8'b0, m_write_data[7:0], 16'b0}; end
                2'b11: begin byte_en = 4'b1000; m_write_data_shifted = {m_write_data[7:0], 24'b0}; end
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
