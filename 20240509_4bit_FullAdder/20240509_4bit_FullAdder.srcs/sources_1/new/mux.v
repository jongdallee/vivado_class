`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/09 16:25:58
// Design Name: 
// Module Name: mux
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


module mux(
    input     [1:0] sel,
    input     [3:0] x0,
    input     [3:0] x1,
    input     [3:0] x2,
    input     [3:0] x3,
    output reg[3:0] y
    );

    always @(*) begin //* -> 안에 값을 다 감시함 그중에 바뀌면 실행
        case(sel)
        2'b00: y = x0;
        2'b01: y = x1;
        2'b10: y = x2;
        2'b11: y = x3;
        default: y = x0;
    endcase
    end   
endmodule
