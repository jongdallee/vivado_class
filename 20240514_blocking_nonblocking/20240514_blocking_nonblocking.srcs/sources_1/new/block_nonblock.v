`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/14 09:40:57
// Design Name: 
// Module Name: block_nonblock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module case_latch_(
input [1:0]sel,
input [7:0]in1,
input [7:0]in2,
output reg[7:0]out
);



always  @(sel, in1,in2 ) begin
   out =  8'b0;
   case(sel)
   2'b01 : out = in1;
   2'b10 : out = in2;
   endcase
end
endmodule
