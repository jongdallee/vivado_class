`timescale 1ns / 1ps

module BUS_interconnector (
    input  logic [31:0] address,
    output logic [ 7:0] slave_sel,
    input  logic [31:0] slave_rdata0,
    input  logic [31:0] slave_rdata1,
    input  logic [31:0] slave_rdata2,
    input  logic [31:0] slave_rdata3,
    input  logic [31:0] slave_rdata4,
    input  logic [31:0] slave_rdata5,
    input  logic [31:0] slave_rdata6,
    output logic [31:0] master_rdata
);

    decoder U_Decoder (
        .x(address),
        .y(slave_sel)
    );

    mux U_MUX (
        .sel(address),
        .a  (slave_rdata0), //RAM
        .b  (slave_rdata1), //GPI
        .c  (slave_rdata2), //GPO
        .d  (slave_rdata3), //GPIO
        .e  (slave_rdata4), //GPIO
        .f  (slave_rdata5), //FND
        .g  (slave_rdata6), //UART
        .y  (master_rdata)
    );

endmodule


module decoder (
    input  logic [31:0] x,
    output logic [ 7:0] y
);
    always_comb begin : decoder
        case (x[31:8])
            24'h0000_10: y = 7'b0000001;
            24'h0000_20: y = 7'b0000010;
            24'h0000_21: y = 7'b0000100;
            24'h0000_22: y = 7'b0001000;
            24'h0000_23: y = 7'b0010000;
            24'h0000_24: y = 7'b0100000; //fnd
            24'h0000_25: y = 7'b1000000;
            default: y = 7'b0;
        endcase
    end
endmodule


module mux (
    input  logic [31:0] sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    input  logic [31:0] d,
    input  logic [31:0] e,
    input  logic [31:0] f,
    input  logic [31:0] g,
    output logic [31:0] y
);
    always_comb begin : decoder
        case (sel[31:8])
            24'h0000_10: y = a; //RAM 
            24'h0000_20: y = b; //GPI
            24'h0000_21: y = c; //GPO
            24'h0000_22: y = d; //GPIO
            24'h0000_23: y = e; //GPIO
            24'h0000_24: y = f; //FND
            24'h0000_25: y = g; //UART
            default: y = 32'bx;
        endcase
    end
endmodule
