`timescale 1ns / 1ps

module InstructionMemory (
    input  logic [31:0] addr,
    output logic [31:0] data
);
    logic [31:0] rom[0:63];

    initial begin
        $readmemh("inst.mem", rom);  // instruction hexa code 
    end

    assign data = rom[addr[31:2]];

endmodule



//  // x0 = 0, x1 = 1, x2 = 2, x3 = 3, x4 = 4, x5 = 5

// //R-type
// rom[0] = 32'h00520333;  // add x6, x4, x5  -> 9
// rom[1] = 32'h401183b3;  // sub x7, x3, x1 -> 2
// rom[2] = 32'h00121433;  //sll x8, x4, x1 -> 8
// rom[3] = 32'h001fd4b3;  //srl x9, x31, x1 -> 32'h7fffffff
// rom[4] = 32'h401fd533;  //sra x10, x31, x1 -> 32'hffffffff
// rom[5] = 32'h01f0a5b3;  //slt x11, x1, x31 -> 0
// rom[6] = 32'h01f0b633;  //sltu x12, x1, x31 -> 1
// rom[7] = 32'h0020c6b3;  //xor x13, x1, x2 -> 3
// rom[8] = 32'h0020e733;  //or x14, x1, x2 -> 3
// rom[9] = 32'h0020f7b3;  //and x15, x1, x2 -> 0

// //I-type
// rom[10] = 32'h004f2803;  //lw x16 x30 4  -> 101
// rom[11] = 32'h00908893;  //addi x17 x1 9  -> 10
// rom[12] = 32'h004fa913;  //slti x18 x31 4  -> 1
// rom[13] = 32'h004fb993;  //sltiu x19 x31 4 -> 0 
// rom[14] = 32'h0020ca13;  //xori x20 x1 2  -> 3
// rom[15] = 32'h0020ea93;  //ori x21 x1 2  -> 3
// rom[16] = 32'h0020fb13;  //andi x22 x1 2  -> 0
// rom[17] = 32'h00221b93;  //slli x23 x4 2  -> 16
// rom[18] = 32'h002fdc13;  //srli x24 x31 2  -> 32'h3fffffff
// rom[19] = 32'h402fdc93;  //srai x25 x31 2  -> 32'hffffffff

// //S-type
// rom[20] = 32'h005f2423;  //sw x5, x30 8 -> Ram[2] = 5

// //B-type
// rom[21] = 32'h00108463;  //beq x1 x1 8 -> pc = pc + 8
// rom[23] = 32'h00209463;  //bne x1 x2 8 -> pc = pc + 8
// rom[25] = 32'h002fc463;  //blt x31 x2 8 -> pc = pc + 8
// rom[27] = 32'h01f25463;  //bge x4 x31 8 -> pc = pc + 8
// rom[29] = 32'h002fe463;  //bltu x31 x2 8 -> pc = pc + 4
// rom[30] = 32'h01f27463;  //bgeu x4 x31 8 -> pc = pc + 4

// //U-type
// rom[31] = 32'h00001d37;  //lui x26 1 -> 4096

// //UA-type
// rom[32] = 32'h00001d97;  //auipc x27 1 -> pc(128) + 4096

// //J-type
// rom[33] = 32'h00800e6f;  //jal x28 8 -> rd = pc(132) + 4 / pc = pc + imm

// //I-type
// rom[35] = 32'h008e0ee7; //jalr x29 x28 8 -> rd = pc(140) + 4 / pc = rs1(136) + imm(8)

// // additional test
// rom[36] = 32'h0f4f0303;  //lB x6 x30 244 -> 32'hffffffff
// rom[37] = 32'h0f8f1383;  //LH x7 x30 248 -> 32'hffffffff
// rom[38] = 32'h00cf2403;  //lw x8 x30 12 -> 103
// rom[39] = 32'h0fcf4483;  //LBU x9 x30 252 -> 32'h000000ff
// rom[40] = 32'h0fcf5503;  //LHU x10 x30 252 -> 32'h0000ffff
// rom[41] = 32'h01ff0823;  //sb x31 x30 16 -> ram[4] = 32'h000000ff
// rom[42] = 32'h01ff1a23;  //sh x31 x30 20 -> ram[5] = 32'h0000ffff
// rom[43] = 32'h01ff2c23;  //sw x31 x30 24 -> ram[6] = 32'hffffffff



// rom[0] = 32'h00520333;  // add  x6, x4, x5
// rom[1] = 32'h401183b3;  // sub  x7, x3, x1
// rom[2] = 32'h0020f433;  // and  x8, x1, x2  =>  0
// rom[3] = 32'h0020E4B3;  // or   x9, x1, x2  =>  3
// rom[4] = 32'h0040A503;  // lw   x10, x1, 4  =>  101
// rom[5] = 32'h00A08193;  // addi x3, x1, 10  =>  11
// rom[6] = 32'h00502223;  // sw   x0, 4, x5   =>  5
// rom[7] = 32'h00108463;  // beq  x1, x1, 8   =>  PC + 8
// //rom[8] = 32'h00108463;  // beq  x1, x1, 8   =>  PC + 8 
// rom[9] = 32'h000015b7;  // lui  x11, 1   =>  x11 <= 4096
// rom[10] = 32'h00001617;  // AUIPC  x12, 1   =>  x12 <= 40 + 4096 = 4136
// rom[11] = 32'h008006ef;  // jal x13, 8 => x13 = PC + 4, PC += 8
// //rom[12] = 32'h008006ef;  // jal x13, 8 => x13 = PC + 4, PC += 8 
// rom[13] = 32'h00C68767;  // jalr x14, x13, 12 => x14 = PC + 4 = 56, PC = 48 + 12 
// //rom[14] = 32'h00C68767;  // jalr x14, x13, 12 => x14 = PC + 4, PC = 48 + 12 
// rom[15] = 32'h00908793;  // addi x15 x1 9 => 10
// rom[16] = 32'h40225813;  // srai x16 x4 2 => 1
