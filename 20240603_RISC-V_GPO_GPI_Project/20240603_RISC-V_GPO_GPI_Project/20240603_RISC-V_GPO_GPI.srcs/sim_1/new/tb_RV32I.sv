`timescale 1ns / 1ps



module tb_RISCV ();

    logic       clk;
    logic       reset;
    wire [3:0] IOPortA;
    wire [3:0] IOPortB;


    RV32I dut (
        .clk(clk),
        .reset(reset),
        .IOPortA(IOPortA),
        .IOPortB(IOPortB)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #50 reset = 0;
    end
endmodule