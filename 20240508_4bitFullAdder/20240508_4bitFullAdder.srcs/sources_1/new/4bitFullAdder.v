`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/08 18:43:46
// Design Name: 
// Module Name: 4bitFullAdder
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

module bitFullAdder(
input a0,
input a1,
input a2,
input a3,
input b0,
input b1,
input b2,
input b3,
input cin,
output sum0,
output sum1,
output sum2,
output sum3,
output cOut
    );
    
wire w_carry1,w_carry2,w_carry3;    

fullAdder u_FA0(
.a(a0),
.b(b0),
.cin(cin),
.carry(w_carry1),
.sum(sum0)
);
fullAdder u_FA1(
.a(a1),
.b(b1),
.cin(w_carry1),
.carry(w_carry2),
.sum(sum1)
);
fullAdder u_FA2(
.a(a2),
.b(b2),
.cin(w_carry2),
.carry(w_carry3),
.sum(sum2)
);
fullAdder u_FA3(
.a(a3),
.b(b3),
.cin(w_carry3),
.sum(sum3),
.carry(cOut)
);

endmodule
