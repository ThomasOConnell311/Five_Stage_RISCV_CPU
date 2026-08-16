`ifndef RISCV_DEFS_SV
`define RISCV_DEFS_SV

package riscv_defs;

    typedef enum logic [3:0] {
        ALU_ADD  = 4'd0,
        ALU_SUB  = 4'd1,
        ALU_AND  = 4'd2,
        ALU_OR   = 4'd3,
        ALU_XOR  = 4'd4,
        ALU_SLT  = 4'd5,
        ALU_SLL  = 4'd6,
        ALU_SRL  = 4'd7,
        ALU_SRA  = 4'd8,
        ALU_COPY_B = 4'd9
    } alu_ctrl_t;

    typedef enum logic [1:0] {
        WB_ALU = 2'b00,
        WB_MEM = 2'b01,
        WB_PC4 = 2'b10,
        WB_IMM = 2'b11
    } wb_src_t;

endpackage

`endif
