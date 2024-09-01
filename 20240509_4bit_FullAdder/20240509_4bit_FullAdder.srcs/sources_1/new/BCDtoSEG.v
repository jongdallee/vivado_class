`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/09 13:42:16
// Design Name: 
// Module Name: BCDtoSEG
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


module BCDtoSEG(
    input [3:0] bcd, //입력 4bit
    output reg [7:0] seg //출력 8bit
);

    always @(bcd) begin //switch case문
      case (bcd)
        4'h0: seg = 8'hc0; 
        4'h1: seg = 8'hf9; 
        4'h2: seg = 8'ha4; 
        4'h3: seg = 8'hb0; 
        4'h4: seg = 8'h99; 
        4'h5: seg = 8'h92; 
        4'h6: seg = 8'h82; 
        4'h7: seg = 8'hf8; 
        4'h8: seg = 8'h80; 
        4'h9: seg = 8'h90; 
        4'ha: seg = 8'h88; 
        4'hb: seg = 8'h83; 
        4'hc: seg = 8'hc6; 
        4'hd: seg = 8'ha1; 
        4'he: seg = 8'h86; 
        4'hf: seg = 8'h8e;
        default: seg = 8'hff;
      endcase
    end
endmodule
