`timescale 1ns / 1ps


module top_tx_rx_loop(
    input        clk,
    input        reset,
    //Transmitter
    output       tx,
       //receiver
    input        rx

);
wire [7:0] w_rx_data;
wire w_rx_done;

 uart U_UART(
    .clk(clk),
    .reset(reset),
    //Transmitter
    .tx(tx),
    .start(w_rx_done),
    .tx_data(w_rx_data),
    .tx_done(),
    
    //receiver
    .rx(rx),
    .rx_data(w_rx_data),
    .rx_done(w_rx_done)
);
endmodule
