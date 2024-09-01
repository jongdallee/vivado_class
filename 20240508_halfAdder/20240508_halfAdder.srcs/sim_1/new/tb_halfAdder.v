`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/08 15:29:47
// Design Name: 
// Module Name: tb_halfAdder
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


module tb_halfAdder();
reg x0;
reg x1;
wire y0;
wire y1;

halfAdder test_bench(
.x0(x0),
.x1(x1),
.y0(y0),
.y1(y1)
);

initial begin //전원이 들어가면 실행
#00 x1=0; x0=0;
#10 x1=0; x0=1;
#10 x1=1; x0=0;
#10 x1=1; x0=1;
#10 $finish;
end
endmodule
