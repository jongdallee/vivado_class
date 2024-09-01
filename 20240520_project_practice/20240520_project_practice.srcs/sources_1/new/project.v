`timescale 1ns / 1ps



module project(
   
    );

 uart U_UART(
    .clk(),
    .reset(),
    .tx(),
    .start(),
    .tx_data(),
    .tx_done(),
    .rx(rx),
    .rx_data(),
    .rx_done()
);

button U_Btn(
    .clk(),
    .in(), 
    .out()
    );

fndController U_fndController (
    .clk(),
    .reset(),
    .digit(),
    .fndFont(),
    .fndCom()
);

endmodule
