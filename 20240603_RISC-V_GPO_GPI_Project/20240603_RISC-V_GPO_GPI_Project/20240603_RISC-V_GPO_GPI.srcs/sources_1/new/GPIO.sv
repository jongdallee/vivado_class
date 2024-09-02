`timescale 1ns / 1ps

module GPIO (
    input  logic        clk,
    input  logic        reset,
    input  logic        cs,
    input  logic        we,
    input  logic [ 3:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    inout  logic [ 3:0] IOPort
);

    logic [31:0] MODER, IDR, ODR;
    logic [31:0] rdata_reg;

    assign rdata = rdata_reg;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            MODER <= 0;
            ODR   <= 0;
        end else begin
            if (cs & we) begin
                case (addr[3:2])
                    2'b00: MODER <= wdata;
                    2'b10: ODR <= wdata;
                endcase
            end
        end
    end

    always_comb begin
        case (addr[3:2])
            2'b00:   rdata_reg = MODER;
            2'b01:   rdata_reg = IDR;
            2'b10:   rdata_reg = ODR;
            default: rdata_reg = 32'bx;
        endcase
    end

    always_comb begin
        IDR[0] = MODER[0] ? 1'bz : IOPort[0];
        IDR[1] = MODER[1] ? 1'bz : IOPort[1];
        IDR[2] = MODER[2] ? 1'bz : IOPort[2];
        IDR[3] = MODER[3] ? 1'bz : IOPort[3];
    end

    assign IOPort[0] = MODER[0] ? ODR[0] : 1'bz;
    assign IOPort[1] = MODER[1] ? ODR[1] : 1'bz;
    assign IOPort[2] = MODER[2] ? ODR[2] : 1'bz;
    assign IOPort[3] = MODER[3] ? ODR[3] : 1'bz;

endmodule
