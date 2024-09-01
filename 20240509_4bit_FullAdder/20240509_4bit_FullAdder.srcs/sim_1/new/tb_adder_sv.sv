`timescale 1ns / 1ps
//oop -> class

class transaction;  //start
    rand bit [3:0] a;  //bit 자료형->4bit
    rand bit [3:0] b;

endclass  //finish

module tb_adder_sv();
    reg  [3:0] a; 
    reg  [3:0] b; 
    wire [3:0] sum;
    wire co;

    transaction trans;


    adder dut (
        .a  (a),
        .b  (b),
        .cin(1'b0),
        .sum(sum),
        .co (co)
    );

initial begin
    trans = new();
    for (int i=0; i<100; i++)begin
        trans.randomize();
        a = trans.a;
        b = trans.b;
        #10 $display("a:%d + b:%d", trans.a,trans.b);
        if((a+b) == sum+1)begin
            $display("passed!");
        end
        else begin
            $display("failed!");
        end
    end
    #10 $finish;
 
end
endmodule
