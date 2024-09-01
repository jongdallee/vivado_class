`timescale 1ns / 1ps

module UpCounter_10k(
input clk,
input reset,
output [3:0]fndCom,
output [7:0]fndFont
    );
wire w_clk_10khz;
wire [13:0] w_count_10k;

    clkDiv #(.MAX_COUNT(100_000_000))U_Clkdiv_10hz(
    .clk(clk),
    .reset (reset),
    .o_clk(w_clk_10khz)
    );
    counter #(.MAX_COUNT(10_000))U_counter_10k(
    .clk(w_clk_10khz),
    .reset (reset),
    .count(w_count_10k)
    );
fndController U_FndController(
    .clk(clk),
    .reset (reset),
    .digit(w_count_10k),
    .fndFont(fndFont),
    .fndCom(fndCom)
);

endmodule
