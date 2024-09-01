`timescale 1ns / 1ps

module TopModule (
    input clk,     // 100 MHz system clock
    input reset,   // System reset
    input btn1,    // Button for start/stop
    input btn2,    // Button for clear
    output [7:0] fndFont,
    output [3:0] fndCom
);

    wire tick_100hz;
    wire btn1_debounced;
    wire btn2_debounced;
    reg en;
    reg btn1_state;
    reg btn2_state;
    
    // Debouncing for buttons
    button btn1_debounce (
        .clk(clk),
        .in(btn1),
        .out(btn1_debounced)
    );

    button btn2_debounce (
        .clk(clk),
        .in(btn2),
        .out(btn2_debounced)
    );

    // 100 Hz clock for tick generation
    clkDiv #(
        .HERZ(100)
    ) tickGen (
        .clk(clk),
        .reset(reset),
        .o_clk(tick_100hz)
    );

    // UpCounter instance
    wire [$clog2(10000)-1:0] counter_value;
    UpCounter #(
        .MAX_NUM(10000)
    ) upcounter (
        .clk(tick_100hz), // Use 100Hz clock here
        .reset(reset || btn2_state),
        .tick(1'b1), // Always enable tick at every clock cycle
        .en(en),
        .counter(counter_value)
    );

    // FND Controller instance
    fndController fnd_ctrl (
        .clk(clk),
        .reset(reset),
        .digit(counter_value),
        .fndFont(fndFont),
        .fndCom(fndCom)
    );

    // Control logic for start/stop and clear
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            en <= 0;
            btn1_state <= 0;
            btn2_state <= 0;
        end else begin
            if (btn1_debounced && !btn1_state) begin
                en <= ~en;
                btn1_state <= 1;
            end else if (!btn1_debounced) begin
                btn1_state <= 0;
            end
            
            if (btn2_debounced && !btn2_state) begin
                en <= 0;
                btn2_state <= 1;
            end else if (!btn2_debounced) begin
                btn2_state <= 0;
            end
        end
    end

endmodule

module UpCounter #(
    parameter MAX_NUM = 10000
) (
    input clk,
    input reset,
    input tick,
    input en,
    output reg [$clog2(MAX_NUM)-1:0] counter
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else if (tick && en) begin
            if (counter == MAX_NUM - 1) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule

module fndController (
    input clk,
    input reset,
    input [13:0] digit,
    output [7:0] fndFont,
    output [3:0] fndCom
);

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_digit;
    wire [1:0] w_count;
    wire w_clk_1khz;

    clkDiv #(
        .HERZ(1000)
    ) U_Clkdiv (
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_1khz)
    );

    counter #(
        .MAX_COUNT(4)
    ) U_counter_2bit (
        .clk(w_clk_1khz),
        .reset(reset),
        .count(w_count)
    );

    Decoder UDecoder2x4 (
        .x(w_count),
        .y(fndCom)
    );

    digitSplitter U_DigitSplitter (
        .i_digit(digit),
        .o_digit_1(w_digit_1),
        .o_digit_10(w_digit_10),
        .o_digit_100(w_digit_100),
        .o_digit_1000(w_digit_1000)
    );

    mux U_Mux4x1 (
        .sel(w_count),
        .x0(w_digit_1),
        .x1(w_digit_10),
        .x2(w_digit_100),
        .x3(w_digit_1000),
        .y(w_digit)
    );

    BCDtoSEG U_BCDtoSEG (
        .bcd(w_digit),
        .seg(fndFont)
    );

endmodule

module digitSplitter (
    input [13:0] i_digit,
    output [3:0] o_digit_1,
    output [3:0] o_digit_10,
    output [3:0] o_digit_100,
    output [3:0] o_digit_1000
);

    assign o_digit_1 = i_digit % 10;
    assign o_digit_10 = (i_digit / 10) % 10;
    assign o_digit_100 = (i_digit / 100) % 10;
    assign o_digit_1000 = (i_digit / 1000) % 10;

endmodule

module mux (
    input [1:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    output reg [3:0] y
);

    always @(*) begin
        case (sel)
            2'b00: y = x0;
            2'b01: y = x1;
            2'b10: y = x2;
            2'b11: y = x3;
            default: y = x0;
        endcase
    end
endmodule

module BCDtoSEG (
    input [3:0] bcd,
    output reg [7:0] seg
);

    always @(*) begin
        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hf9;
            4'h2: seg = 8'ha4;
            4'h3: seg = 8'hb0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'ha: seg = 8'h88;
            4'hb: seg = 8'h83;
            4'hc: seg = 8'hc6;
            4'hd: seg = 8'ha1;
            4'he: seg = 8'h86;
            4'hf: seg = 8'h8e;
            default: seg = 8'hff;
        endcase
    end
endmodule

module Decoder (
    input [1:0] x,
    output reg [3:0] y
);

    always @(*) begin
        case (x)
            2'b00: y = 4'b1110;
            2'b01: y = 4'b1101;
            2'b10: y = 4'b1011;
            2'b11: y = 4'b0111;
            default: y = 4'b1111;
        endcase
    end
endmodule

module counter #(
    parameter MAX_COUNT = 4
) (
    input clk,
    input reset,
    output reg [$clog2(MAX_COUNT)-1:0] count
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            if (count == MAX_COUNT - 1) begin
                count <= 0;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule

module clkDiv #(
    parameter HERZ = 100
)(
    input clk, 
    input reset, 
    output reg o_clk
);

    reg [$clog2(100_000_000/HERZ)-1 : 0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            o_clk <= 1'b0;
        end else begin 
            if (counter == ((100_000_000/HERZ)-1)) begin
                counter <= 0;
                o_clk <= ~o_clk;  // Toggle the output clock
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule

module button(
    input clk,
    input in,
    output out
);

    localparam N = 20;
    reg [N-1:0] q_reg, q_next;

    always @(posedge clk) begin
        q_reg <= q_next;
    end

    always @(*) begin
        q_next = {in, q_reg[N-1:1]};
    end

    assign out = (&q_reg[N-1:1] & ~q_reg[0]);
endmodule