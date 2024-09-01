`timescale 1ns / 1ps

module up_counter #(
    parameter SEC_COUNT = 60,
    MIN_COUNT = 60
) (
    input clk,
    input reset,
    input tick,
    input run_stop,
    input clear,
    output [$clog2(SEC_COUNT)-1 : 0] sec,
    output [$clog2(MIN_COUNT)-1 : 0] min
);

    reg [$clog2(SEC_COUNT)-1 : 0] secCounter_reg, secCounter_next;
    reg [$clog2(MIN_COUNT)-1 : 0] minCounter_reg, minCounter_next;

    assign sec = secCounter_reg;
    assign min = minCounter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            secCounter_reg <= 0;
            minCounter_reg <= 0;
        end else begin
            secCounter_reg <= secCounter_next;
            minCounter_reg <= minCounter_next;
        end
    end

    always @(*) begin
        secCounter_next = secCounter_reg;
        minCounter_next = minCounter_reg; //default 값으로 현재값을 이렇게 하겠다.

        if (tick && run_stop) begin
            if (secCounter_reg == SEC_COUNT - 1) begin
                secCounter_next = 0;
                if (minCounter_reg == MIN_COUNT - 1) begin
                    minCounter_next = 0;
                end else begin
                    minCounter_next = minCounter_reg + 1;
                end
            end else begin
                secCounter_next = secCounter_reg + 1;
            end
        end else if (clear) begin
            secCounter_next = 0;
            minCounter_next = 0;
        end
    end
endmodule


