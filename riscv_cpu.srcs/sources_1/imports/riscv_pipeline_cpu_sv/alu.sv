`include "riscv_defs.sv"
import riscv_defs::*;

module alu (
    input logic [31:0] a,
    input logic [31:0] b,
    input alu_ctrl_t alu_ctrl,
    output logic [31:0] result
);
    always_comb begin
        unique case (alu_ctrl)
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_AND: result = a & b;
            ALU_OR: result = a | b;
            ALU_XOR: result = a ^ b;
            ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_SLL: result = a << b[4:0];
            ALU_SRL: result = a >> b[4:0];
            ALU_SRA: result = $signed(a) >>> b[4:0];
            ALU_COPY_B: result = b;
            default: result = 32'd0;
        endcase
    end
endmodule
