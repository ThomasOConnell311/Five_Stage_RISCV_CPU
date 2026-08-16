`timescale 1ns / 1ps

module seven_seg_driver (
    input  logic clk,
    input  logic rst,
    input  logic [15:0] value,

    // 0 = decimal
    // 1 = hexadecimal
    input  logic hex_mode,

    output logic [6:0] seg,
    output logic [3:0] an
);

    logic [19:0] refresh_counter;
    logic [1:0] digit_select;

    logic [3:0] digit0;
    logic [3:0] digit1;
    logic [3:0] digit2;
    logic [3:0] digit3;

    logic [3:0] display_digit;

    // Display refresh counter
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            refresh_counter <= 20'd0;
        else
            refresh_counter <= refresh_counter + 1'b1;
    end

    assign digit_select = refresh_counter[19:18];

    // Decimal / hexadecimal conversion
    always_comb begin

        if (hex_mode) begin

            // HEXADECIMAL MODE
            digit0 = value[3:0];
            digit1 = value[7:4];
            digit2 = value[11:8];
            digit3 = value[15:12];

        end else begin

            // DECIMAL MODE
            digit0 = value % 10;
            digit1 = (value / 10) % 10;
            digit2 = (value / 100) % 10;
            digit3 = (value / 1000) % 10;

        end
    end

    // Select which physical display digit is currently active
    always_comb begin

        case (digit_select)

            2'b00: begin
                an = 4'b1110;
                display_digit = digit0;
            end

            2'b01: begin
                an = 4'b1101;
                display_digit = digit1;
            end

            2'b10: begin
                an = 4'b1011;
                display_digit = digit2;
            end

            2'b11: begin
                an = 4'b0111;
                display_digit = digit3;
            end

            default: begin
                an = 4'b1111;
                display_digit = 4'd0;
            end

        endcase
    end

    // Digit to Seven-Segment Decoder
    always_comb begin

        case (display_digit)

            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;

            // Only used in hexadecimal mode
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;

            default:
                seg = 7'b1111111;

        endcase
    end

endmodule