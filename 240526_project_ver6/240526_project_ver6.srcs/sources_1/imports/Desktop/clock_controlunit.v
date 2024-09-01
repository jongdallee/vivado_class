`timescale 1ns / 1ps

module controlunit (
    input  clk,
    input  reset,
    input  sw_clear,
    input  btn_runStop,
    input  btn_minUp,
    input  btn_secUp,
    input  btn_hourUp,

    input [7:0] rx_data,
    output tx,

    input btn_mode,
    input [1:0] sw,

    output clear,
    output run_stop,
    output minUp,
    output secUp,
    output hourUp,
    output led_stop,
    output led_run,
    output led_sw_stop,
    output led_sw_run,

    output run_stop_up,
    output clear_up
);
    localparam STOP = 0, RUN = 1, CLEAR = 2, MINUP = 3, SECUP = 4, HOURUP = 5,
                CNT_STOP = 6, CNT_RUN = 7, CNT_CLEAR = 8;
    reg [3:0] state, state_next;
    reg run_stop_reg, run_stop_next, clear_reg, clear_next;
    reg minUp_reg, minUp_next, secUp_reg, secUp_next, hourUP_reg, hourUp_next;
    reg btn_mode_reg, btn_mode_next;
    reg run_stop_reg_up, run_stop_next_up, clear_reg_up, clear_next_up;
    
    assign run_stop = run_stop_reg;
    assign clear = clear_reg;
    assign minUp = minUp_reg;
    assign secUp = secUp_reg;
    assign hourUp = hourUP_reg;

    assign run_stop_up = run_stop_reg_up;
    assign clear_up = clear_reg_up;

    assign led_stop = (state == STOP) ? 1'b1 : 1'b0;
    assign led_run  = (state == RUN) ? 1'b1 : 1'b0;
    assign led_sw_stop = (state == CNT_STOP) ? 1'b1 : 1'b0;
    assign led_sw_run = (state == CNT_RUN) ? 1'b1 : 1'b0;
   
    //state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state        <= STOP;
            run_stop_reg <= 1'b0;
            clear_reg    <= 1'b0;
            minUp_reg    <= 1'b0;
            secUp_reg    <= 1'b0;
            hourUP_reg   <= 1'b0;
            run_stop_reg_up <= 1'b0;
            clear_reg_up <= 1'b0;
            btn_mode_reg <= 1'b0;

        end else begin
            state        <= state_next;
            run_stop_reg <= run_stop_next;
            clear_reg    <= clear_next;
            minUp_reg    <= minUp_next;
            secUp_reg    <= secUp_next;
            hourUP_reg   <= hourUp_next;
            btn_mode_reg <= btn_mode_next;

            run_stop_reg_up <= run_stop_next_up;
            clear_reg_up <= clear_next_up;
        end
    end

    //next combinational logic
    always @(*) begin
        state_next = state;
        if(rx_data) begin
            if(rx_data == "R") state_next = RUN;
            else if(rx_data == "S") state_next = STOP;
            else if(rx_data == "C") state_next = CLEAR;
            else if(rx_data == "I") state_next = MINUP;
            else if(rx_data == "E") state_next = SECUP;
            else if(rx_data == "H") state_next = HOURUP;
            else if(rx_data == "M") begin 
                if(state == STOP ) state_next = CNT_STOP;
                else if(state == RUN) state_next = CNT_STOP;
                else if(state == CNT_STOP) state_next = RUN;
                else if(state == CNT_RUN) state_next = RUN;
                end
            else if(rx_data == "G") state_next = CNT_RUN;
            else if(rx_data == "T") state_next = CNT_STOP;
        end

            case (state)
                STOP: begin
                    if (btn_runStop) state_next = RUN;
                    else if (sw_clear) state_next = CLEAR;
                    else if (btn_minUp) state_next = MINUP;
                    else if (btn_secUp) state_next = SECUP;
                    else if (btn_hourUp) state_next = HOURUP;
                    else if (btn_mode) state_next = CNT_STOP;
                end
                RUN: begin
                    if (btn_runStop) state_next = STOP;
                    else if (btn_mode) state_next = CNT_STOP;
                end
                CLEAR: state_next = STOP;
                MINUP: state_next = STOP;
                SECUP: state_next = STOP;
                HOURUP : state_next = STOP;

                CNT_STOP: begin
                    if(btn_runStop) state_next = CNT_RUN;
                    else if(sw_clear) state_next = CNT_CLEAR;
                    else if (btn_mode) state_next = RUN;

                end
                CNT_RUN : begin
                    if(btn_runStop) state_next = CNT_STOP;
                    else if(sw_clear) state_next = CNT_CLEAR;
                    else if (btn_mode) state_next = RUN;

                end
                CNT_CLEAR: state_next = CNT_STOP;
            endcase
    end

    //output combinational logic
    always @(*) begin
        run_stop_next = 1'b0;
        clear_next    = 1'b0;
        minUp_next    = 1'b0;
        secUp_next    = 1'b0;
        hourUp_next   = 1'b0;

        run_stop_next_up = 1'b0;
        clear_next_up = 1'b0;

        case (state)
            STOP : run_stop_next = 1'b0;
            RUN  : run_stop_next = 1'b1;
            CLEAR: clear_next = 1'b1;
            MINUP: minUp_next = 1'b1;
            SECUP: secUp_next = 1'b1;
            HOURUP: hourUp_next = 1'b1;
            CNT_STOP: run_stop_next_up = 1'b0;
            CNT_RUN: run_stop_next_up = 1'b1;
            CNT_CLEAR: clear_next_up = 1'b1;
        endcase
    end
endmodule
