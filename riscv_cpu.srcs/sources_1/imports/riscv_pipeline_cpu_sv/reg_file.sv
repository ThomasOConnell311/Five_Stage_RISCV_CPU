module reg_file (
    input logic clk,
    input logic rst,
    input logic reg_write,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] wd,
    input logic [4:0] dbg_addr,
    output logic [31:0] rd1,
    output logic [31:0] rd2,
    output logic [31:0] dbg_data
);
    logic [31:0] regs [0:31];
    integer i;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i++) regs[i] <= 32'd0;
        end else if (reg_write && rd != 5'd0) begin
            regs[rd] <= wd;
        end
    end

    assign rd1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];
    assign dbg_data = (dbg_addr == 5'd0) ? 32'd0 : regs[dbg_addr];
endmodule
