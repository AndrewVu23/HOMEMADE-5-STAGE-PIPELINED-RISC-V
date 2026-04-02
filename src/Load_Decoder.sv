`timescale 1ns/1ps

module Load_Decoder #(parameter N = 32)
(
    input logic [2:0] m_funct3,
    input logic [1:0] address_offset, // m_ALU_Result[1:0]
    input logic [N-1:0] m_read_address, // raw 32-bit word from Data_Mem
    output logic [N-1:0] m_read_data
);
always_comb begin
    case(m_funct3)

        // LB 
        3'b000: begin
            case(address_offset)
                2'b00: m_read_data = {{24{m_read_address[7]}},  m_read_address[7:0]};
                2'b01: m_read_data = {{24{m_read_address[15]}}, m_read_address[15:8]};
                2'b10: m_read_data = {{24{m_read_address[23]}}, m_read_address[23:16]};
                2'b11: m_read_data = {{24{m_read_address[31]}}, m_read_address[31:24]};
            endcase
        end

        // LH 
        3'b001: begin
            case(address_offset)
                2'b00: m_read_data = {{16{m_read_address[15]}}, m_read_address[15:0]};
                2'b10: m_read_data = {{16{m_read_address[31]}}, m_read_address[31:16]};
                default: m_read_data = 0;
            endcase
        end

        // LW
        3'b010: m_read_data = m_read_address;

        // LBU
        3'b100: begin
            case(address_offset)
                2'b00: m_read_data = {24'b0, m_read_address[7:0]};
                2'b01: m_read_data = {24'b0, m_read_address[15:8]};
                2'b10: m_read_data = {24'b0, m_read_address[23:16]};
                2'b11: m_read_data = {24'b0, m_read_address[31:24]};
            endcase
        end

        // LHU
        3'b101: begin
            case(address_offset)
                2'b00: m_read_data = {16'b0, m_read_address[15:0]};
                2'b10: m_read_data = {16'b0, m_read_address[31:16]};
                default: m_read_data = 0;
            endcase
        end

        default: m_read_data = m_read_address;
    endcase
end
endmodule
