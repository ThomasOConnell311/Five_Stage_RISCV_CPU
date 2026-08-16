`timescale 1ns/1ps

module tb_riscv_pipeline_cpu;

    logic clk;
    logic rst;
    logic [15:0] led;

    riscv_pipeline_cpu dut (
        .clk(clk),
        .rst(rst),
        .led(led)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("riscv_pipeline_cpu.vcd");
        $dumpvars(0, tb_riscv_pipeline_cpu);

        rst = 1'b1;
        repeat (3) @(posedge clk);
        rst = 1'b0;

        repeat (40) @(posedge clk);

        $display("x1 = %0d", dut.u_regfile.regs[1]);
        $display("x2 = %0d", dut.u_regfile.regs[2]);
        $display("x3 = %0d", dut.u_regfile.regs[3]);
        $display("x4 = %0d", dut.u_regfile.regs[4]);
        $display("x5 = %0d", dut.u_regfile.regs[5]);
        $display("mem[0] = %0d", dut.u_dmem.ram[0]);

        if (dut.u_regfile.regs[5] == 32'd16)
            $display("PASS: pipelined CPU demo program worked.");
        else
            $display("FAIL: expected x5 = 16.");

        $finish;
    end

endmodule
