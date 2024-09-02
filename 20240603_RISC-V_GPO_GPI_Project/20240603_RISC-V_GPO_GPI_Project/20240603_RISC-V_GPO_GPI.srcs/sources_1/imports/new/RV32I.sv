`timescale 1ns / 1ps

module RV32I (
    input  logic       clk,
    input  logic       reset,
    inout  logic [3:0] IOPortA,
    inout  logic [3:0] IOPortB,
    output logic [7:0] fndFont,
    output logic [3:0] fndCom
);

    logic [31:0] w_InstrMemAddr, w_InstrMemData;
    logic w_We;
    logic [31:0] w_Addr, w_dataMemRData, w_WData;
    logic [31:0] w_MasterRData, w_GpoRData, w_GpioARData, w_GpioBRData;
    logic [2:0]  w_dataSize;
    logic [7:0]  w_slave_sel;

    CPU_Core U_CPU_Core (
        .clk          (clk),
        .reset        (reset),
        .machineCode  (w_InstrMemData),
        .instrMemRAddr(w_InstrMemAddr),
        .dataMemWe    (w_We),
        .dataMemRAddr (w_Addr),
        .dataMemRData (w_MasterRData),
        .dataMemWData (w_WData),
        .dataSize     (w_dataSize)
    );

    InstructionMemory U_ROM (
        .addr(w_InstrMemAddr),
        .data(w_InstrMemData)
    );

    DataMemory U_RAM (
        .clk     (clk),
        .ce      (w_slave_sel[0]),
        .dataSize(w_dataSize),
        .we      (w_We),
        .addr    (w_Addr[7:0]),
        .wdata   (w_WData),
        .rdata   (w_dataMemRData)
    );

    BUS_interconnector U_BUS_InterConn (
        .address     (w_Addr),
        .slave_sel   (w_slave_sel[7:0]),
        .slave_rdata0(w_dataMemRData), //RAM
        .slave_rdata1(),               //GPI
        .slave_rdata2(),               //GPO
        .slave_rdata3(),               //GPIO
        .slave_rdata4(),               //GPIO
        .slave_rdata5(),               //FND
        .slave_rdata6(),               //UART
        .master_rdata(w_MasterRData)
    );

    // GPO U_GPO (
    //     .clk    (clk),
    //     .reset  (reset),
    //     .ce     (w_slave_sel[1]),
    //     .we     (w_We),
    //     .addr   (w_Addr[1:0]),
    //     .wdata  (w_WData),
    //     .rdata  (w_GpoRData),
    //     .outPort(outPortA)
    // );
/*
    GPIO U_GPIOA (
        .clk   (clk),
        .reset (reset),
        .cs    (w_slave_sel[1]),
        .we    (w_We),
        .addr  (w_Addr[3:0]),
        .wdata (w_WData),
        .rdata (w_GpioARData),
        .IOPort(IOPortA)
    );

    GPIO U_GPIOB (
        .clk   (clk),
        .reset (reset),
        .cs    (w_slave_sel[2]),
        .we    (w_We),
        .addr  (w_Addr[3:0]),
        .wdata (w_WData),
        .rdata (w_GpioBRData),
        .IOPort(IOPortB)
    );
*/    
    fndController U_FND(
        .clk    (clk),
        .reset  (reset),
        .cs     (w_slave_sel[1]) ,
        .we     (w_We),
        .addr   (w_Addr[3:0]),
        .wdata  (w_WData),            // digit,
        .fndFont(fndFont),            
        .fndCom (fndCom)             
    );
endmodule
