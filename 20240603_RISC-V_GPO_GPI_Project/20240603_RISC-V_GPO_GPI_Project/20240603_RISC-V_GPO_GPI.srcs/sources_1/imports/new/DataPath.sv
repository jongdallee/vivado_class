`timescale 1ns / 1ps
`include "define.sv"

module DataPath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] machineCode,
    input  logic        regFileWe,
    input  logic [ 3:0] aluControl,
    output logic [31:0] instrMemRAddr,
    output logic [31:0] dataMemRAddr,
    output logic [31:0] dataMemWData,
    input  logic [31:0] dataMemRData,
    input  logic [ 2:0] extType,
    input  logic        AluSrcMuxSel,
    input  logic [ 1:0] RFWriteDataSrcMuxSel,
    input  logic        RFWriteDataSrcMuxSel2,
    input  logic        PC_Extend_Adder_SrcMuxSel,
    input  logic        PCSrcMuxSel,
    input  logic        branch
);

    logic [31:0] w_ALUResult, w_RegFileRData1, w_RegFileRData2, w_PCData;
    logic [31:0] w_AluSrcMuxOut, w_extendOut, w_RFWriteDataSrcMuxOut;
    logic [31:0] w_PCAdderSrcMuxOut, w_PC_Extend_Adder_SrcMuxOut;
    logic w_btaken;
    logic [31:0] w_PC_Extend_Adder_out, w_PCSrcMuxOut, w_RFWriteDataSrcMuxOut2;
    assign dataMemRAddr = w_ALUResult;
    assign dataMemWData = w_RegFileRData2;


    Register U_PC (
        .clk  (clk),
        .reset(reset),
        .d    (w_PCSrcMuxOut),
        .q    (instrMemRAddr)
    );

    mux_2x1 U_PCSrcMux (
        .sel(PCSrcMuxSel),
        .a  (w_PCData),
        .b  (w_PC_Extend_Adder_out),
        .y  (w_PCSrcMuxOut)
    );

    assign w_PCAdderSrcMuxSel = branch & w_btaken;

    mux_2x1 U_PCAdderSrcMux (
        .sel(w_PCAdderSrcMuxSel),
        .a  (32'd4),
        .b  (w_extendOut),
        .y  (w_PCAdderSrcMuxOut)
    );

    adder U_Adder_PC (
        .a(instrMemRAddr),
        .b(w_PCAdderSrcMuxOut),
        .y(w_PCData)
    );

    RegisterFile U_RegisterFile (
        .clk   (clk),
        .we    (regFileWe),
        .RAddr1(machineCode[19:15]),
        .RAddr2(machineCode[24:20]),
        .WAddr (machineCode[11:7]),
        .WData (w_RFWriteDataSrcMuxOut2),
        .RData1(w_RegFileRData1),
        .RData2(w_RegFileRData2)
    );

    mux_2x1 U_ALUSrcMux (
        .sel(AluSrcMuxSel),
        .a  (w_RegFileRData2),
        .b  (w_extendOut),
        .y  (w_AluSrcMuxOut)
    );

    alu U_ALU (
        .a         (w_RegFileRData1),
        .b         (w_AluSrcMuxOut),
        .aluControl(aluControl),
        .result    (w_ALUResult),
        .btaken    (w_btaken)
    );

    adder U_Adder_PC_Extend (
        .a(w_PC_Extend_Adder_SrcMuxOut),
        .b(w_extendOut),
        .y(w_PC_Extend_Adder_out)
    );

    mux_4x1 U_RFWriteDataSrcMux (
        .sel(RFWriteDataSrcMuxSel),
        .a  (w_ALUResult),
        .b  (dataMemRData),
        .c  (w_extendOut),
        .d  (w_PC_Extend_Adder_out),
        .y  (w_RFWriteDataSrcMuxOut)
    );

    mux_2x1 U_RFWriteDataSrcMux2 (
        .sel(RFWriteDataSrcMuxSel2),
        .a  (w_RFWriteDataSrcMuxOut),
        .b  (w_PCData),
        .y  (w_RFWriteDataSrcMuxOut2)
    );

    mux_2x1 U_PC_Extend_Adder_Src_Mux (
        .sel(PC_Extend_Adder_SrcMuxSel),
        .a  (w_RegFileRData1),
        .b  (instrMemRAddr),
        .y  (w_PC_Extend_Adder_SrcMuxOut)
    );

    extand U_Extend (
        .extType(extType),
        .instr  (machineCode[31:7]),
        .immext (w_extendOut)
    );

endmodule


module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [ 4:0] RAddr1,
    input  logic [ 4:0] RAddr2,
    input  logic [ 4:0] WAddr,
    input  logic [31:0] WData,
    output logic [31:0] RData1,
    output logic [31:0] RData2
);

    logic [31:0] RegFile[0:31];

    initial begin
        RegFile[0] = 32'd0;
        RegFile[1] = 32'd1;
        RegFile[2] = 32'd2;
        RegFile[3] = 32'd3;
        RegFile[4] = 32'd4;
        RegFile[5] = 32'd5;
        RegFile[30] = 32'd4096;
        RegFile[31] = 32'hffffffff;
    end

    always_ff @(posedge clk) begin
        if (we) RegFile[WAddr] <= WData;
    end

    assign RData1 = (RAddr1 != 0) ? RegFile[RAddr1] : 0;
    assign RData2 = (RAddr2 != 0) ? RegFile[RAddr2] : 0;

endmodule

module Register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) q <= 0;
        else q <= d;
    end
endmodule


module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] aluControl,
    output logic        btaken,
    output logic [31:0] result
);

    always_comb begin
        case (aluControl)
            `ADD:    result = a + b;
            `SUB:    result = a - b;
            `SLL:    result = a << b;
            `SRL:    result = a >> b;
            `SRA:    result = $signed(a) >>> b;
            `SLT:    result = ($signed(a) < $signed(b)) ? 1 : 0;
            `SLTU:   result = (a < b) ? 1 : 0;
            `XOR:    result = a ^ b;
            `OR:     result = a | b;
            `AND:    result = a & b;
            default: result = 32'bx;
        endcase
    end

    always_comb begin : comparatorcase
        case (aluControl[2:0])
            3'b000:  btaken = (a == b);  // BEQ
            3'b001:  btaken = (a != b);  // BNE
            3'b100:  btaken = ($signed(a) < $signed(b));   // BLT
            3'b101:  btaken = ($signed(a) >= $signed(b));  // BGE
            3'b110:  btaken = (a < b);   // BLTU
            3'b111:  btaken = (a >= b);  // BGEU
            default: btaken = 1'bx;
        endcase
    end

endmodule


module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule


module extand (
    input  logic [ 2:0] extType,
    input  logic [31:7] instr,
    output logic [31:0] immext
);
    always_comb begin
        case (extType)
            3'b000: immext = {{21{instr[31]}}, instr[30:20]};  // I-Type
            3'b001: immext = {{21{instr[31]}}, instr[30:25], instr[11:7]};  // S-Type
            3'b010: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};  // B-Type
            3'b011: immext = {instr[31:12], 12'b0};  // U-Type
            3'b100: immext = {{12{instr[31]}},instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0};  // J-Type
            3'b101: immext = {{28{instr[24]}}, instr[23:20]};  // I-Type_shift
            default: immext = 32'bx;
        endcase
    end
endmodule


module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);

    always_comb begin
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
            default: y = 32'bx;
        endcase
    end

endmodule


module mux_4x1 (
    input  logic [ 1:0] sel,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    input  logic [31:0] d,
    output logic [31:0] y
);

    always_comb begin
        case (sel)
            2'b00:   y = a;
            2'b01:   y = b;
            2'b10:   y = c;
            2'b11:   y = d;
            default: y = 32'bx;
        endcase
    end

endmodule
