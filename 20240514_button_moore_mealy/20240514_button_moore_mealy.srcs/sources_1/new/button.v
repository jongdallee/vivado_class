`timescale 1ns / 1ps

module button(
    input clk,
    input in, //입력
    output out
    );

    localparam N = 20; //이걸 조절하면됨

    reg[ N-1 : 0] q_reg,q_next;

    always @(posedge clk)begin
        q_reg <= q_next;
    end

    //next state logic
    always @(q_reg, in)begin
        q_next = {in,q_reg[N-1:1]};
    end

    //output logic
    assign out = (&q_reg[N-1:1]& ~q_reg[0]);

endmodule
