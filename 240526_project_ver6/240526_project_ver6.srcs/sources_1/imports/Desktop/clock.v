`timescale 1ns / 1ps

module clock #(
    parameter SEC_COUNT = 60,
    MIN_COUNT = 60,
    HOUR_COUNT = 24
) (
    input clk,
    input reset,
    input tick,
    input clear,
    input run_stop,
    input hour_up,
    input min_up,
    input sec_up,
    output [$clog2(SEC_COUNT)-1 : 0] sec,
    output [$clog2(MIN_COUNT)-1 : 0] min,
    output [$clog2(HOUR_COUNT)-1 : 0] hour
);
    reg [$clog2(SEC_COUNT)-1 : 0] secCounter_reg, secCounter_next;
    reg [$clog2(MIN_COUNT)-1 : 0] minCounter_reg, minCounter_next;
    reg [$clog2(MIN_COUNT)-1 : 0] hourCounter_reg, hourCounter_next;

    assign sec  = secCounter_reg;
    assign min  = minCounter_reg;
    assign hour = hourCounter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            secCounter_reg  <= 0;
            minCounter_reg  <= 0;
            hourCounter_reg <= 0;
        end else begin
            secCounter_reg  <= secCounter_next;
            minCounter_reg  <= minCounter_next;
            hourCounter_reg <= hourCounter_next;
        end
    end

    always @(*) begin
        secCounter_next  = secCounter_reg;
        minCounter_next  = minCounter_reg;
        hourCounter_next = hourCounter_reg;
        if (tick && run_stop) begin
            if (secCounter_reg == SEC_COUNT - 1) begin
                secCounter_next = 0;
                if (minCounter_reg == MIN_COUNT - 1) begin
                    minCounter_next = 0;
                    if (hourCounter_reg == HOUR_COUNT - 1) begin
                        hourCounter_next = 0;
                    end else begin
                        hourCounter_next = hourCounter_reg + 1;
                    end
                end else begin
                    minCounter_next = minCounter_reg + 1;
                end
            end else begin
                secCounter_next = secCounter_reg + 1;
            end
        end else if (clear) begin
            secCounter_next  = 0;
            minCounter_next  = 0;
            hourCounter_next = 0;
        end else if (sec_up) begin
            if (secCounter_reg == SEC_COUNT - 1) begin
                secCounter_next = 0;
            end else secCounter_next = secCounter_reg + 1;
        end else if (min_up) begin
            if (minCounter_reg == MIN_COUNT - 1) begin
                minCounter_next = 0;
            end else minCounter_next = minCounter_reg + 1;
        end else if (hour_up) begin
            if (hourCounter_reg == HOUR_COUNT - 1) begin
                hourCounter_next = 0;
            end else hourCounter_next = hourCounter_reg + 1;
        end
    end

    always @(*) begin
        
    end
endmodule
