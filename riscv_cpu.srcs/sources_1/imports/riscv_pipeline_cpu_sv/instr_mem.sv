module instr_mem (
    input  logic [31:0] addr,
    output logic [31:0] instr
);
    logic [31:0] rom [0:255];

    initial begin
        integer i;
        for (i = 0; i < 256; i++) rom[i] = 32'h00000013; // addi x0,x0,0 NOP

        // Demo program:
        // x1 = 5
        // x2 = 10
        // x3 = x1 + x2 = 15
        // mem[0] = x3
        // x4 = mem[0]
        // x5 = x4 + 1 = 16
        // loop forever
        rom[0] = 32'h00500093; // addi x1, x0, 5
        rom[1] = 32'h00A00113; // addi x2, x0, 10
        rom[2] = 32'h002081B3; // add  x3, x1, x2
        rom[3] = 32'h00302023; // sw   x3, 0(x0)
        rom[4] = 32'h00002203; // lw   x4, 0(x0)
        rom[5] = 32'h00120293; // addi x5, x4, 1
        rom[6] = 32'h0000006F; // jal  x0, 0
    end

    assign instr = rom[addr[9:2]];
endmodule
