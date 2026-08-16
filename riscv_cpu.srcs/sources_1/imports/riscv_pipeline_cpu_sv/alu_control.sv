`include "riscv_defs.sv"
import riscv_defs::*;

module alu_control (
    input logic [1:0] alu_op,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output alu_ctrl_t alu_ctrl
);
    always_comb begin
        unique case (alu_op)
            2'b00: alu_ctrl = ALU_ADD; // lw/sw address calculation
            2'b01: alu_ctrl = ALU_SUB; // branch compare helper

            2'b10: begin
                unique case (funct3)
                    3'b000: alu_ctrl = funct7[5] ? ALU_SUB : ALU_ADD;
                    3'b111: alu_ctrl = ALU_AND;
                    3'b110: alu_ctrl = ALU_OR;
                    3'b100: alu_ctrl = ALU_XOR;
                    3'b010: alu_ctrl = ALU_SLT;
                    3'b001: alu_ctrl = ALU_SLL;
                    3'b101: alu_ctrl = funct7[5] ? ALU_SRA : ALU_SRL;
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            default: alu_ctrl = ALU_ADD;
        endcase
    end
endmodule
