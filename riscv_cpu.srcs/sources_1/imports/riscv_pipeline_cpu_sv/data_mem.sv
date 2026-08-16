module data_mem (
    input logic clk,
    input logic mem_write,
    input logic [31:0] addr,
    input logic [31:0] wd,
    output logic [31:0] rd
);
    logic [31:0] ram [0:255];

    initial begin
        integer i;
        for (i = 0; i < 256; i++) ram[i] = 32'd0;
    end

    always_ff @(posedge clk) begin
        if (mem_write)
            ram[addr[9:2]] <= wd;
    end

    assign rd = ram[addr[9:2]];
endmodule
