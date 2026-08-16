module branch_unit (
    input logic branch,
    input  logic [2:0] funct3,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic branch_taken
);
    always_comb begin
        branch_taken = 1'b0;

        if (branch) begin
            unique case (funct3)
                3'b000: branch_taken = (a == b);                   // beq
                3'b001: branch_taken = (a != b);                   // bne
                3'b100: branch_taken = ($signed(a) < $signed(b));  // blt
                3'b101: branch_taken = ($signed(a) >= $signed(b)); // bge
                3'b110: branch_taken = (a < b);                   // bltu
                3'b111: branch_taken = (a >= b);                  // bgeu
                default: branch_taken = 1'b0;
            endcase
        end
    end
endmodule
