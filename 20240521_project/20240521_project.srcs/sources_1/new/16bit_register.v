`timescale 1ns / 1ps

module register_16bit(
input clk,
input reset,
input valid,
input [15:0] inA,
output[15:0] outA
    );

reg [15:0] outA_reg, outA_next; //next의 filpflop은 없음

assign outA = outA_reg;


//register
always @(posedge clk, posedge reset) begin
    if (reset) begin
        outA_reg <= 1'b0;
    end else begin
        outA_reg <=  outA_next;
    end
end

always @(*) begin
    outA_next = outA_reg;//원하지 않은 래치 
    if(valid)begin
        outA_next = inA;
    end
end

endmodule
