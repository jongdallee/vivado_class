`timescale 1ns / 1ps




module uart_led(
    input        clk,
    input        reset,
    //Transmitter
    output       tx,
       //receiver
    input        rx,
    output      led_0,
    output      led_1,
    output      led_2
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

control_unit U_CONTROL(
    .clk(w_rx_done),
    .reset(reset),
    .rx(w_rx_data),
    .led_0(led_0),
    .led_1(led_1),
    .led_2(led_2)
    
);

endmodule

module control_unit(
    input clk,
    input reset,
    input  [7:0]rx,
    output led_0,
    output led_1,
    output led_2
  
);

parameter LED0 = 0, LED1 = 1, LED2 = 2, LED3 = 3;

reg [1:0] state, state_next;
reg led_0_reg, led_1_reg , led_2_reg;


 assign led_0 = led_0_reg;
 assign led_1 = led_1_reg;
 assign led_2 = led_2_reg;

    //state register
always @(posedge clk, posedge reset) begin
        if(reset)begin
            state     <= LED0;            
        end else begin
            state    <= state_next;
         end
    end        

    //next state combinational logic
 always @(*) begin
        state_next = state;
        case (state)
            LED0 : begin
               if(rx == 1) state_next = LED1;
               else if(rx == 2) state_next = LED2;   
               else if(rx == 3) state_next = LED3;   
               else state_next = LED0;   
            end 
            LED1: begin
               if(rx == 2) state_next = LED2;
               else if(rx == 0) state_next = LED0;   
               else if(rx == 3) state_next = LED3;   
               else state_next = LED1;   
            end   
            LED2: begin
               if(rx == 0) state_next = LED0;
               else if(rx == 1) state_next = LED1;   
               else if(rx == 3) state_next = LED3;   
               else state_next = LED2;   
            end 
            LED3: begin
               if(rx == 0) state_next = LED0;
               else if(rx == 1) state_next = LED1;   
               else if(rx == 2) state_next = LED2;   
               else state_next = LED3;   
            end 

        endcase
    end

    //output combinational logic

     always @(*) begin
        case (state)
            LED0 : begin
                led_0_reg = 1'b0;
                led_1_reg = 1'b0;
                led_2_reg = 1'b0;
            end 
            LED1: begin
                led_0_reg = 1'b1;
                led_1_reg = 1'b0;
                led_2_reg = 1'b0;
            end   
            LED2: begin
                led_0_reg = 1'b1;
                led_1_reg = 1'b1;
                led_2_reg = 1'b0;
            end 
            LED3: begin
                led_0_reg = 1'b1;
                led_1_reg = 1'b1;
                led_2_reg = 1'b1;   
            end 
        endcase
    end

 endmodule