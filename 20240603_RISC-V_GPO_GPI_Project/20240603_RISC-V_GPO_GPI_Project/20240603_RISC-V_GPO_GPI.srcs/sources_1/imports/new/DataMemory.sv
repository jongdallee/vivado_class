`timescale 1ns / 1ps

module DataMemory (
    input  logic        clk,
    input  logic        ce,
    input  logic        we,
    input  logic [ 2:0] dataSize,
    input  logic [ 7:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [31:0] ram[0:2**6-1];

    initial begin
        int i;
        for (i = 0; i < (2 ** 6) - 3; i++) begin
            ram[i] = 100 + i;
        end
        ram[61] = 32'h000000ff;
        ram[62] = 32'h0000ffff;
        ram[63] = 32'hffffffff;
    end

    always_ff @(posedge clk) begin : Write
        if (we & ce) begin
            case (dataSize)
                3'b101: ram[addr[7:2]][7:0] <= wdata[7:0];  // Store Byte
                3'b110: ram[addr[7:2]][15:0] <= wdata[15:0];  // Store Half
                3'b111: ram[addr[7:2]]  <= wdata[31:0];  // Store Word
            endcase
        end
    end

    always_comb begin : Read
        case (dataSize)
            3'b000: rdata = {{24{ram[addr[7:2]][7]}}, ram[addr[7:2]][7:0]};        // load Byte 
            3'b001: rdata = {{16{ram[addr[7:2]][15]}}, ram[addr[7:2]][15:0]};      // Load Half 
            3'b010: rdata = ram[addr[7:2]];                                        // Load Word 
            3'b011: rdata = {24'b0, ram[addr[7:2]][7:0]};                          // Load Byte(Unsigned) 
            3'b100: rdata = {16'b0, ram[addr[7:2]][15:0]};                         // Load Half(Unsigned) 
        endcase
    end

endmodule
