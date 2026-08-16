`include "riscv_defs.sv"
import riscv_defs::*;

module control_unit (
    input  logic [6:0] opcode,
    output logic reg_write,
    output logic mem_write,
    output logic mem_read,
    output logic alu_src,
    output logic branch,
    output logic jump,
    output wb_src_t wb_src,
    output logic [1:0] alu_op
);
    always_comb begin
        reg_write = 1'b0;
        mem_write = 1'b0;
        mem_read = 1'b0;
        alu_src = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        wb_src = WB_ALU;
        alu_op = 2'b00;

        unique case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1'b1;
                alu_src = 1'b0;
                wb_src = WB_ALU;
                alu_op = 2'b10;
            end

            7'b0010011: begin // I-type ALU
                reg_write = 1'b1;
                alu_src = 1'b1;
                wb_src = WB_ALU;
                alu_op = 2'b10;
            end

            7'b0000011: begin // lw
                reg_write = 1'b1;
                mem_read = 1'b1;
                alu_src = 1'b1;
                wb_src = WB_MEM;
                alu_op = 2'b00;
            end

            7'b0100011: begin // sw
                mem_write = 1'b1;
                alu_src = 1'b1;
                alu_op = 2'b00;
            end

            7'b1100011: begin // branch
                branch = 1'b1;
                alu_op = 2'b01;
            end

            7'b1101111: begin // jal
                reg_write = 1'b1;
                jump = 1'b1;
                wb_src = WB_PC4;
            end

            7'b0110111: begin // lui
                reg_write = 1'b1;
                wb_src = WB_IMM;
            end

            default: begin
                // NOP / unsupported instruction
            end
        endcase
    end
endmodule
