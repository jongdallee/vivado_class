`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/09 14:17:11
// Design Name: 
// Module Name: Adder_Fnd
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


module Adder_Fnd( //top 제일 꼭대기에 있다 그래서 탑 모듈이라함
    input [7:0] a,
    input [7:0] b,
    input [1:0] fndSel,
    output [3:0] fndCom,
    output [7:0] fndFont,
    output carry 
    );

wire [7:0] w_sum;
wire [3:0] w_digit;
wire [3:0] w_digit_1,w_digit_10,w_digit_100,w_digit_1000;

Decoder U_Decoder_2x4(
 .x(fndSel),
 .y(fndCom)
);

adder8bit U_8bitAdder(
.a(a),  
.b(b),
.cin(1'b0), 
.sum(w_sum),
.co(carry)
);

BCDtoSEG U_BcdToSeg(
.bcd(w_digit),
.seg(fndFont)
);

digitSplitter U_DigitSplitter(
     .i_digit({9'b0,carry,w_sum}), //9'b0 모자란 9비트를 0으로 채움,중괄호는 비트결합 연산자 LSB MSB
     .o_digit_1(w_digit_1),
     .o_digit_10(w_digit_10),
     .o_digit_100(w_digit_100),
     .o_digit_1000(w_digit_1000)
    );

mux U_Mux_4x1(
    .sel(fndSel),
    .x0(w_digit_1),
    .x1(w_digit_10),
    .x2(w_digit_100),
    .x3(w_digit_1000),
    .y(w_digit)
    );    



endmodule
