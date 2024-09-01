`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/08 10:29:08
// Design Name: 
// Module Name: gates
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


module gates(
   input x0,
   input x1,
   output y0,
   output y1,
   output y2,
   output y3,
   output y4,
   output y5,
   output y6
    );
    
//   assign y0 = x0 & x1;
//   assign y1 = ~(x0 & x1);
//   assign y2 = x0 | x1;
//   assign y3 = ~(x0 | x1);
//   assign y4 = x0 ^ x1;
//   assign y5 = ~(x0 ^ x1); 
//   assign y6 = ~x0;
      
      //Gate Primitive
      and(y0,x0,x1); //gate(output, input, input);
      nand(y1,x0,x1); 
      or(y2,x0,x1);
      nor(y3,x0,x1);
      xor(y4,x0,x1);
      xnor(y5,x0,x1);
      not(y6,x0); 
endmodule
