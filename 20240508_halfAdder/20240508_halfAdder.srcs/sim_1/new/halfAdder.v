`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/08 15:23:14
// Design Name: 
// Module Name: halfAdder
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


module halfAdder(
  input x0,
  input x1,
  output y0,
  output y1
    );
    
    xor(y0,x0,x1);
    and(y1,x0,x1);
    
endmodule
