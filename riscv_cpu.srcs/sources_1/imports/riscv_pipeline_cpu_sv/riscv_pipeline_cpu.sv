`include "riscv_defs.sv"
import riscv_defs::*;

module riscv_pipeline_cpu (
    input logic clk,
    input logic rst,
    input logic [4:0] dbg_reg_addr,
    output logic [31:0] dbg_reg_data,
    output logic [15:0] led
);

    // ============================================================
    // IF stage
    // ============================================================
    logic [31:0] pc_f, pc_next_f, pc_plus4_f, instr_f;

    assign pc_plus4_f = pc_f + 32'd4;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc_f <= 32'd0;
        else if (!stall)
            pc_f <= pc_next_f;
    end

    instr_mem u_imem (
        .addr(pc_f),
        .instr(instr_f)
    );

    // ============================================================
    // IF/ID pipeline register
    // ============================================================
    logic [31:0] pc_d, pc_plus4_d, instr_d;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_d <= 32'd0;
            pc_plus4_d <= 32'd0;
            instr_d <= 32'h00000013; // NOP
        end else if (flush_d) begin
            pc_d <= 32'd0;
            pc_plus4_d <= 32'd0;
            instr_d <= 32'h00000013;
        end else if (!stall) begin
            pc_d <= pc_f;
            pc_plus4_d <= pc_plus4_f;
            instr_d <= instr_f;
        end
    end

    // ============================================================
    // ID stage
    // ============================================================
    logic [6:0] opcode_d;
    logic [4:0] rs1_d, rs2_d, rd_d;
    logic [2:0] funct3_d;
    logic [6:0] funct7_d;

    assign opcode_d = instr_d[6:0];
    assign rd_d = instr_d[11:7];
    assign funct3_d = instr_d[14:12];
    assign rs1_d = instr_d[19:15];
    assign rs2_d = instr_d[24:20];
    assign funct7_d = instr_d[31:25];

    logic reg_write_d, mem_write_d, mem_read_d, alu_src_d, branch_d, jump_d;
    wb_src_t wb_src_d;
    logic [1:0] alu_op_d;
    logic [31:0] rd1_d, rd2_d, imm_d;

    control_unit u_control (
        .opcode(opcode_d),
        .reg_write(reg_write_d),
        .mem_write(mem_write_d),
        .mem_read(mem_read_d),
        .alu_src(alu_src_d),
        .branch(branch_d),
        .jump(jump_d),
        .wb_src(wb_src_d),
        .alu_op(alu_op_d)
    );

    reg_file u_regfile (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write_w),
        .rs1(rs1_d),
        .rs2(rs2_d),
        .rd(rd_w),
        .wd(wb_data_w),
        .dbg_addr(dbg_reg_addr),
        .dbg_data(dbg_reg_data),
        .rd1(rd1_d),
        .rd2(rd2_d)
    );

    imm_gen u_imm (
        .instr(instr_d),
        .imm(imm_d)
    );

    // ============================================================
    // Hazard detection
    // ============================================================
    logic stall;
    logic flush_d, flush_e;

    hazard_unit u_hazard (
        .id_ex_mem_read(mem_read_e),
        .id_ex_rd(rd_e),
        .if_id_rs1(rs1_d),
        .if_id_rs2(rs2_d),
        .stall(stall)
    );

    // ============================================================
    // ID/EX pipeline register
    // ============================================================
    logic [31:0] pc_e, pc_plus4_e, rd1_e, rd2_e, imm_e;
    logic [4:0] rs1_e, rs2_e, rd_e;
    logic [2:0] funct3_e;
    logic [6:0] funct7_e;
    logic reg_write_e, mem_write_e, mem_read_e, alu_src_e, branch_e, jump_e;
    wb_src_t wb_src_e;
    logic [1:0] alu_op_e;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_e <= 32'd0; pc_plus4_e <= 32'd0; rd1_e <= 32'd0; rd2_e <= 32'd0; imm_e <= 32'd0;
            rs1_e <= 5'd0; rs2_e <= 5'd0; rd_e <= 5'd0; funct3_e <= 3'd0; funct7_e <= 7'd0;
            reg_write_e <= 1'b0; mem_write_e <= 1'b0; mem_read_e <= 1'b0; alu_src_e <= 1'b0;
            branch_e <= 1'b0; jump_e <= 1'b0; wb_src_e <= WB_ALU; alu_op_e <= 2'b00;
        end else if (flush_e || stall) begin
            // Insert bubble
            pc_e <= 32'd0; pc_plus4_e <= 32'd0; rd1_e <= 32'd0; rd2_e <= 32'd0; imm_e <= 32'd0;
            rs1_e <= 5'd0; rs2_e <= 5'd0; rd_e <= 5'd0; funct3_e <= 3'd0; funct7_e <= 7'd0;
            reg_write_e <= 1'b0; mem_write_e <= 1'b0; mem_read_e <= 1'b0; alu_src_e <= 1'b0;
            branch_e <= 1'b0; jump_e <= 1'b0; wb_src_e <= WB_ALU; alu_op_e <= 2'b00;
        end else begin
            pc_e <= pc_d; pc_plus4_e <= pc_plus4_d; rd1_e <= rd1_d; rd2_e <= rd2_d; imm_e <= imm_d;
            rs1_e <= rs1_d; rs2_e <= rs2_d; rd_e <= rd_d; funct3_e <= funct3_d; funct7_e <= funct7_d;
            reg_write_e <= reg_write_d; mem_write_e <= mem_write_d; mem_read_e <= mem_read_d; alu_src_e <= alu_src_d;
            branch_e <= branch_d; jump_e <= jump_d; wb_src_e <= wb_src_d; alu_op_e <= alu_op_d;
        end
    end

    // ============================================================
    // EX stage
    // ============================================================
    alu_ctrl_t alu_ctrl_e;
    logic [1:0] forward_a, forward_b;
    logic [31:0] src_a_e, src_b_reg_e, src_b_e;
    logic [31:0] alu_result_e;
    logic branch_taken_e;
    logic pc_src_e;
    logic [31:0] pc_target_e;

    alu_control u_alu_control (
        .alu_op(alu_op_e),
        .funct3(funct3_e),
        .funct7(funct7_e),
        .alu_ctrl(alu_ctrl_e)
    );

    forwarding_unit u_forwarding (
        .ex_mem_reg_write(reg_write_m),
        .ex_mem_rd(rd_m),
        .mem_wb_reg_write(reg_write_w),
        .mem_wb_rd(rd_w),
        .id_ex_rs1(rs1_e),
        .id_ex_rs2(rs2_e),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    always_comb begin
        unique case (forward_a)
            2'b00: src_a_e = rd1_e;
            2'b10: src_a_e = alu_result_m;
            2'b01: src_a_e = wb_data_w;
            default: src_a_e = rd1_e;
        endcase

        unique case (forward_b)
            2'b00: src_b_reg_e = rd2_e;
            2'b10: src_b_reg_e = alu_result_m;
            2'b01: src_b_reg_e = wb_data_w;
            default: src_b_reg_e = rd2_e;
        endcase
    end

    assign src_b_e = alu_src_e ? imm_e : src_b_reg_e;

    alu u_alu (
        .a(src_a_e),
        .b(src_b_e),
        .alu_ctrl(alu_ctrl_e),
        .result(alu_result_e)
    );

    branch_unit u_branch (
        .branch(branch_e),
        .funct3(funct3_e),
        .a(src_a_e),
        .b(src_b_reg_e),
        .branch_taken(branch_taken_e)
    );

    assign pc_src_e = branch_taken_e || jump_e;
    assign pc_target_e = pc_e + imm_e;

    assign flush_d = pc_src_e;
    assign flush_e = pc_src_e;

    always_comb begin
        if (pc_src_e)
            pc_next_f = pc_target_e;
        else
            pc_next_f = pc_plus4_f;
    end

    // ============================================================
    // EX/MEM pipeline register
    // ============================================================
    logic [31:0] alu_result_m, write_data_m, pc_plus4_m, imm_m;
    logic [4:0] rd_m;
    logic reg_write_m, mem_write_m, mem_read_m;
    wb_src_t wb_src_m;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_m <= 32'd0; write_data_m <= 32'd0; pc_plus4_m <= 32'd0; imm_m <= 32'd0;
            rd_m <= 5'd0;
            reg_write_m <= 1'b0; mem_write_m <= 1'b0; mem_read_m <= 1'b0; wb_src_m <= WB_ALU;
        end else begin
            alu_result_m <= alu_result_e;
            write_data_m <= src_b_reg_e;
            pc_plus4_m <= pc_plus4_e;
            imm_m <= imm_e;
            rd_m <= rd_e;
            reg_write_m <= reg_write_e;
            mem_write_m <= mem_write_e;
            mem_read_m <= mem_read_e;
            wb_src_m <= wb_src_e;
        end
    end

    // ============================================================
    // MEM stage
    // ============================================================
    logic [31:0] mem_data_m;

    data_mem u_dmem (
        .clk(clk),
        .mem_write(mem_write_m),
        .addr(alu_result_m),
        .wd(write_data_m),
        .rd(mem_data_m)
    );

    // ============================================================
    // MEM/WB pipeline register
    // ============================================================
    logic [31:0] alu_result_w, mem_data_w, pc_plus4_w, imm_w;
    logic [4:0] rd_w;
    logic reg_write_w;
    wb_src_t wb_src_w;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_w <= 32'd0; mem_data_w <= 32'd0; pc_plus4_w <= 32'd0; imm_w <= 32'd0;
            rd_w <= 5'd0;
            reg_write_w <= 1'b0; wb_src_w <= WB_ALU;
        end else begin
            alu_result_w <= alu_result_m;
            mem_data_w <= mem_data_m;
            pc_plus4_w <= pc_plus4_m;
            imm_w <= imm_m;
            rd_w <= rd_m;
            reg_write_w <= reg_write_m;
            wb_src_w <= wb_src_m;
        end
    end

    // ============================================================
    // WB stage
    // ============================================================
    logic [31:0] wb_data_w;

    always_comb begin
        unique case (wb_src_w)
            WB_ALU: wb_data_w = alu_result_w;
            WB_MEM: wb_data_w = mem_data_w;
            WB_PC4: wb_data_w = pc_plus4_w;
            WB_IMM: wb_data_w = imm_w;
            default: wb_data_w = alu_result_w;
        endcase
    end

    // Debug:
    // Lower 8 LEDs = PC
    // Upper 8 LEDs = x5 result if you inspect with hierarchy in sim, or PC upper bits here.
    assign led = pc_f[15:0];

endmodule
