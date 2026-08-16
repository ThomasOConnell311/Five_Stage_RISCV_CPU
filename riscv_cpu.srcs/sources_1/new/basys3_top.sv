`timescale 1ns / 1ps

module basys3_top (
    input logic clk,
    input logic rst,
    input logic [15:0] sw,
    output logic [15:0] led,
    output logic [6:0] seg,
    output logic [3:0] an,
    output logic dp
);

    logic [31:0] dbg_reg_data;

    riscv_pipeline_cpu cpu (
        .clk(clk),
        .rst(rst),

        .dbg_reg_addr(sw[4:0]),
        .dbg_reg_data(dbg_reg_data),

        .led(led)
    );
    
    seven_seg_driver display (
        .clk(clk),
        .rst(rst),
        .value(dbg_reg_data[15:0]),
        .hex_mode(sw[15]),
        .seg(seg),
        .an(an)
    );
    
    assign dp = 1'b1;

endmodule
