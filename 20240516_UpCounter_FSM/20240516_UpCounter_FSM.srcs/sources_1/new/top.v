`timescale 1ns / 1ps


module top(
    input clk,
    input reset,
    input btn_run_stop,
    input btn_clear,
    output [3:0]fndCom,
    output [7:0]fndFont,
    output led_stop,
    output led_run,
    output led_clear
    );

    wire w_clk_10khz;
    wire w_run_stop, w_clear;
    wire [13:0]w_digit;


    clkDiv #(
        .MAX_COUNT(10_000_000)
    ) U_Clkdiv_10hz (
        .clk  (clk),
        .reset (reset),
        .o_clk(w_clk_10khz)
    );

 up_counter U_UpCounter(
    .clk(clk),
    .reset(reset),
    .tick(w_clk_10khz),
    .run_stop(w_run_stop),  //제어회로
    .clear(w_clear),
    .count(w_digit)
);

fndController U_fndController (
    .clk(clk),
    .reset(reset),
    .digit(w_digit),
    .fndFont(fndFont),
    .fndCom(fndCom)
);
wire w_btn_runStop, w_btn_clear;

button U_Btn_RunStop(
    .clk(clk),
    .in(btn_run_stop), 
    .out(w_btn_runStop)
    );
button U_Btn_Clear(
    .clk(clk),
    .in(btn_clear), 
    .out(w_btn_clear)
    );

control_unit U_control_unit(
    .clk(clk),
    .reset(reset),
    .btn_run_stop(w_btn_runStop),
    .btn_clear(w_btn_clear),
    .run_stop(w_run_stop),
    .clear(w_clear),
    .led_stop (led_stop),
    .led_run (led_run),
    .led_clear(led_clear)
    );

ila_0 U_ILA (
	.clk(clk), // input wire clk
	.probe0(w_btn_runStop), // input wire [0:0]  probe0  
	.probe1(w_btn_clear), // input wire [0:0]  probe1 
	.probe2(w_run_stop), // input wire [0:0]  probe2 
	.probe3(w_clear), // input wire [0:0]  probe3 
	.probe4(w_digit), // input wire [13:0]  probe4 
	.probe5(fndCom) // input wire [3:0]  probe5
);

endmodule
