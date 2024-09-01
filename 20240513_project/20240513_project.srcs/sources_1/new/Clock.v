`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/13 16:21:25
// Design Name: 
// Module Name: Clock
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
module Timer (
    input clk,          // 클럭 입력
    input reset,        // 리셋 입력
    output reg [6:0] min,  // 분 (0~59)
    output reg [6:0] sec  // 초 (0~59)
);

    // 10kHz 클럭 생성
    wire w_clk_10khz;
    wire [13:0] w_count_10k;

    clkDiv #(.MAX_COUNT(100_000_000)) U_Clkdiv_10hz (
        .clk(clk),
        .reset(reset),
        .o_clk(w_clk_10khz)
    );

    // 10k 카운터 모듈
    counter #(.MAX_COUNT(10_000)) U_counter_10k (
        .clk(w_clk_10khz),
        .reset(reset),
        .count(w_count_10k)
    );

    // fndController 모듈 사용하여 분과 초를 출력
    fndController U_FndController (
        .clk(clk),
        .reset(reset),
        .digit(w_count_10k),
        .fndFont(),
        .fndCom()
    );

    // 분과 초를 나누는 논리
    always @(posedge w_clk_10khz or posedge reset) begin
        if (reset) begin
            min <= 7'b0000000; // 초기화
            sec <= 7'b0000000;
        end else begin
            // 60초마다 분을 증가
            if (sec == 60) begin
                sec <= 7'b0000000;
                if (min < 59) begin
                    min <= min + 1;
                end else begin
                    min <= 7'b0000000; // 59분에서 다시 0분으로
                end
            end else begin
                sec <= sec + 1; // 초 증가
            end
        end
    end

endmodule
