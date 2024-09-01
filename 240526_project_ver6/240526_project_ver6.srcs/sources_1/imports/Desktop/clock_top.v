`timescale 1ns / 1ps

module clock_top #(
    parameter SEC_COUNT = 60,
    MIN_COUNT = 60,
    HOUR_COUNT = 24
) (
    input clk,
    input reset,
    input sw_clear,
    input [1:0] sw,
    input btn_runStop,
    input btn_hourUp,
    input btn_minUp,
    input btn_secUp,
    input btn_mode,

    input rx,
    output tx,

    output [3:0] fndCom,
    output [7:0] fndFont,
    output led_stop,
    output led_run,
    output led_sw_stop,
    output led_sw_run

);
    wire w_sw_clear, w_btn_runStop, w_btn_minUp, w_btn_secUp, w_btn_hourUp, w_btn_mode;
    wire w_clk_1hz;
    wire w_clear, w_runStop, w_minUp, w_secUp, w_hourUp;
    wire w_run_stop_up, w_clear_up;
    wire [ $clog2(SEC_COUNT)-1 : 0] w_sec;
    wire [ $clog2(MIN_COUNT)-1 : 0] w_min;
    wire [$clog2(HOUR_COUNT)-1 : 0] w_hour;

    wire [5:0] w_sec_sw, w_min_sw;
    wire [5:0] w_dis_up, w_dis_low;

    wire w_rx_empty;
    wire [7:0] w_rx_data;

    uart_fifo U_uart_fifo(
    .clk(clk),
    .reset(reset),
    .tx(tx),
    .tx_en(~w_rx_empty),
    .tx_data(w_rx_data),
    .tx_full(),
    .rx(rx),
    .rx_en(~w_rx_empty),
    .rx_data(w_rx_data),
    .rx_empty(w_rx_empty)
    );

    controlunit U_ControlUnit (
        .clk(clk),
        .reset(reset),
        .sw_clear(sw_clear),
        .btn_runStop(w_btn_runStop),
        .btn_minUp(w_btn_minUp),
        .btn_secUp(w_btn_secUp),
        .btn_hourUp(w_btn_hourUp),
        .btn_mode(w_btn_mode),
        .sw(),
        .clear(w_clear),
        .run_stop(w_runStop),
        .minUp(w_minUp),
        .secUp(w_secUp),
        .hourUp(w_hourUp),
        .led_stop(led_stop),
        .led_run(led_run),
        .run_stop_up(w_run_stop_up),
        .clear_up(w_clear_up),
        .led_sw_run(led_sw_run),
        .led_sw_stop(led_sw_stop),

        .rx_data(w_rx_data),
        .tx(tx)
    );

    clock #(
        .SEC_COUNT (60),
        .MIN_COUNT (60),
        .HOUR_COUNT(24)
    ) U_Clock (
        .clk(clk),
        .reset(reset),
        .tick(w_clk_1hz),
        .clear(w_clear),
        .run_stop(w_runStop),
        .hour_up(w_hourUp),
        .min_up(w_minUp),
        .sec_up(w_secUp),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );  
    up_counter #(.SEC_COUNT(60),.MIN_COUNT(60)) U_Stopwatch(
        .clk(clk),
        .reset(reset),
        .tick(w_clk_1hz),
        .run_stop(w_run_stop_up),
        .clear(w_clear_up),
        .sec(w_sec_sw),
        .min(w_min_sw)
    );

    display_controller #(
        .SEC_COUNT (60),
        .MIN_COUNT (60),
        .HOUR_COUNT(24)
    ) U_Display_CU (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .sec_sw(w_sec_sw),
        .min_sw(w_min_sw),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .display_upper(w_dis_up),
        .display_lower(w_dis_low)
    );

    fndController U_FndController (
        .clk    (clk),
        .reset  (reset),
        .digit1 (w_dis_low),
        .digit2 (w_dis_up),
        .fndFont(fndFont),
        .fndCom (fndCom)
    );

    clkDiv #(
        .MAX_COUNT(100_000_000)
    ) U_clkDiv_1Hz (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_clk_1hz)
    );


    button U_Btn_RunStop (
        .clk(clk),
        .in (btn_runStop),
        .out(w_btn_runStop)
    );

    button U_Btn_HourUP (
        .clk(clk),
        .in (btn_hourUp),
        .out(w_btn_hourUp)
    );

    button U_Btn_MinUP (
        .clk(clk),
        .in (btn_minUp),
        .out(w_btn_minUp)
    );

    button U_Btn_SecUP (
        .clk(clk),
        .in (btn_secUp),
        .out(w_btn_secUp)
    );

    button U_Btn_mode (
        .clk(clk),
        .in (btn_mode),
        .out(w_btn_mode)
    );
    
endmodule

module display_controller #(
    parameter SEC_COUNT = 60,
    MIN_COUNT = 60,
    HOUR_COUNT = 24
) (
    input clk,
    input reset,
    input [1:0] sw,
    input [5:0] sec_sw,
    input [5:0] min_sw,
    input [$clog2(SEC_COUNT)-1 : 0] sec,
    input [$clog2(MIN_COUNT)-1 : 0] min,
    input [$clog2(HOUR_COUNT)-1 : 0] hour,
    output [5:0] display_upper,
    output [5:0] display_lower
);
    reg [5:0] display_upper_reg, display_upper_next;
    reg [5:0] display_lower_reg, display_lower_next;

    assign display_upper = display_upper_reg;
    assign display_lower = display_lower_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            display_upper_reg <= 0;
            display_lower_reg <= 0;
        end else begin
            display_upper_reg <= display_upper_next;
            display_lower_reg <= display_lower_next;
        end
    end

    always @(*) begin
        display_upper_next = display_upper_reg;
        display_lower_next = display_lower_reg;
        if (sw == 2'b01) begin
            display_upper_next = min;
            display_lower_next = sec;
        end else if (sw == 2'b10) begin
            display_upper_next = hour;
            display_lower_next = min;
        end else if (sw == 2'b11) begin
            display_upper_next = min_sw;
            display_lower_next = sec_sw;
       end
    end
endmodule
