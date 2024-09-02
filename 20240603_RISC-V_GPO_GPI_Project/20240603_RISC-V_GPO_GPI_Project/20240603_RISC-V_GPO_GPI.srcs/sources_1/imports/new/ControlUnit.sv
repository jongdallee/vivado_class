`timescale 1ns / 1ps
`include "define.sv"

module ControlUnit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       regFileWe,
    output logic       AluSrcMuxSel,
    output logic [1:0] RFWriteDataSrcMuxSel,
    output logic       RFWriteDataSrcMuxSel2,
    output logic       PC_Extend_Adder_SrcMuxSel,
    output logic       PCSrcMuxSel,
    output logic       dataMemWe,
    output logic [2:0] extType,
    output logic [3:0] aluControl,
    output logic       branch,
    output logic [2:0] dataSize
);
    logic [14:0] controls;
    assign {regFileWe, AluSrcMuxSel, RFWriteDataSrcMuxSel, dataMemWe, extType, branch, RFWriteDataSrcMuxSel2, PC_Extend_Adder_SrcMuxSel, PCSrcMuxSel, dataSize} = controls;

    always_comb begin : main_decoder
        case (op)
            // regFileWe, AluSrcMuxSel, RFWriteDataSrcMuxSel, dataMemWe, extType, branch, RFWriteDataSrcMuxSel2, PC_Extend_Adder_SrcMuxSel, PCSrcMuxSel, dataSize
            `OP_TYPE_R:  controls = 15'b1_0_00_0_xxx_0_0_x_0_xxx;
            `OP_TYPE_IL: begin
                case (funct3)
                    3'b000:
                    controls = 15'b1_1_01_0_000_0_0_x_0_000;        // load Byte
                    3'b001:
                    controls = 15'b1_1_01_0_000_0_0_x_0_001;        // Load Half
                    3'b010:
                    controls = 15'b1_1_01_0_000_0_0_x_0_010;        // Load Word
                    3'b100:
                    controls = 15'b1_1_01_0_000_0_0_x_0_011;        // Load Byte(Unsigned)
                    3'b101:
                    controls = 15'b1_1_01_0_000_0_0_x_0_100;        // Load Half(Unsigned)
                    default: controls = 15'b1_1_01_0_000_0_0_x_0_010;
                endcase
            end
            `OP_TYPE_I: begin
                case (funct3)
                    3'b001:  controls = 15'b1_1_00_0_101_0_0_x_0_xxx;   // SLLI
                    3'b101:  controls = 15'b1_1_00_0_101_0_0_x_0_xxx;   // SRLI
                    default: controls = 15'b1_1_00_0_000_0_0_x_0_xxx;
                endcase
            end
            `OP_TYPE_S: begin
                case (funct3)
                    3'b000:  controls = 15'b0_1_xx_1_001_0_x_x_0_101;   // Store Byte
                    3'b001:  controls = 15'b0_1_xx_1_001_0_x_x_0_110;   // Store Half
                    3'b010:  controls = 15'b0_1_xx_1_001_0_x_x_0_111;   // Store Word
                    default: controls = 15'b0_1_xx_1_001_0_x_x_0_111;
                endcase
            end
            `OP_TYPE_B:  controls = 15'b0_0_xx_0_010_1_x_x_0_xxx;
            `OP_TYPE_U:  controls = 15'b1_x_10_0_011_0_0_x_0_xxx;
            `OP_TYPE_UA: controls = 15'b1_x_11_0_011_0_0_1_0_xxx;
            `OP_TYPE_J:  controls = 15'b1_x_xx_0_100_0_1_1_1_xxx;
            `OP_TYPE_JI: controls = 15'b1_x_xx_0_000_0_1_0_1_xxx;
            default:     controls = 15'bx;
        endcase
    end

    always_comb begin : alu_control_signal
        case (op)
            `OP_TYPE_R:  aluControl = {funct7[5], funct3};
            `OP_TYPE_IL: aluControl = {1'b0, 3'b000};
            `OP_TYPE_I: begin
                case (funct3)
                    3'b001:  aluControl = {funct7[5], funct3};
                    3'b101:  aluControl = {funct7[5], funct3};
                    default: aluControl = {1'b0, funct3};
                endcase
            end
            `OP_TYPE_S:  aluControl = {1'b0, 3'b000};
            `OP_TYPE_B:  aluControl = {1'b0, funct3};
            default:     aluControl = 4'bx;
        endcase
    end

endmodule
