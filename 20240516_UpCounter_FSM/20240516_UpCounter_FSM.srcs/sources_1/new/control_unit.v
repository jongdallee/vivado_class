`timescale 1ns / 1ps


module control_unit(
    input clk,
    input reset,
    input btn_run_stop,
    input btn_clear,
    output run_stop,
    output clear,
    output led_stop,
    output led_run,
    output led_clear
    );

    parameter STOP = 2'd0, RUN = 2'd1, CLEAR = 2'd2;
    reg [1:0] state, state_next;
    reg run_stop_reg,run_stop_next, clear_reg, clear_next;
    reg led_stop_reg, led_stop_next,led_run_reg ,led_run_next, led_clear_reg, led_clear_next;

    assign run_stop = run_stop_reg;
    assign clear = clear_reg;
    assign led_stop = led_stop_reg;
    assign led_run = led_run_reg;
    assign led_clear = led_clear_reg;
    //state register
    always @(posedge clk, posedge reset) begin
        if(reset)begin
            state <= STOP;
            run_stop_reg <= 1'b0;
            clear_reg <= 1'b0;
            led_stop_reg <= 1'b0;
            led_run_reg <= 1'b0;
            led_clear_reg <= 1'b0;
        end else begin
            state <= state_next;
            run_stop_reg <= run_stop_next;
            clear_reg <= clear_next;
            led_stop_reg <= led_stop_next;
            led_run_reg <= led_run_next;
            led_clear_reg <= led_clear_next;
        end
    end 

    //next state combinational logic
    always @(*) begin
        state_next = state;
        case (state)
            STOP: begin
                if(btn_run_stop) state_next = RUN;
                else if(btn_clear) state_next = CLEAR;
                else state_next = STOP;
            end 
            RUN: begin
                if(btn_run_stop) state_next = STOP;
                else state_next = RUN;
            end
            CLEAR: begin
                state_next = STOP;
               
            end 
        endcase
    end
    //output combinational logic
assign led_stop  = (state == STOP) ? 1'b1 :1'b0;
assign led_run   = (state == RUN) ? 1'b1 :1'b0;
assign led_clear = (state == CLEAR) ? 1'b1 :1'b0;

    always @(*) begin
        run_stop_next = 1'b0;
        clear_next = 1'b0;
       
        case (state)
            STOP: begin
                run_stop_next = 1'b0;
              
            end 
            RUN: begin
                run_stop_next = 1'b1;
              
            end 
            CLEAR: begin
                clear_next = 1'b1;
               
            end 
           
        endcase
        
    end
endmodule
