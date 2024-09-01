`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/08 18:37:45
// Design Name: 
// Module Name: fullAdder
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
/////////////////////////////////////////////////////////////////////////////////

module fullAdder(
input a,
input b,
input cin,
output sum,
output carry
);

wire w_sum1, w_carry1,w_carry2;

halfAdder u_HA1(
.a(a),
.b(b),
.sum(w_sum1),
.carry(w_carry1)
);

halfAdder u_HA2(
.a(w_sum1),
.b(cin),
.sum(sum),
.carry(w_carry2)
);

assign carry = w_carry1 | w_carry2;

endmodule