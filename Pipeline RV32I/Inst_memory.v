`timescale 1ns / 1ps
module Inst_memory(
    input [31:0] A,
    input rst,
    output [31:0] Rd
);

(* ram_style="block" *)
reg [31:0] memory [0:255]; //this means that there is a memory defined by regiters, the
                           //memory consists of 256 registers and each regiter is 32bit in size
integer i;

initial begin
    // Fill unused memory with NOP
    for(i=0;i<256;i=i+1)
        memory[i] = 32'h00000013; // NOP instruction

    // Program instructions
    memory[0] = 32'h00A00093; // addi x1, x0, 10
    memory[1] = 32'h01400113; // addi x2, x0, 20
    memory[2] = 32'h002081B3; // add x3, x1, x2
    memory[3] = 32'h40208233; // sub x4, x1, x2
    memory[4] = 32'h0020A2B3; // and x5, x1, x2
    memory[5] = 32'h0020F333; // or x6, x1, x2
    memory[6] = 32'h0020E3B3; // xor x7, x1, x2
    memory[7] = 32'h0020C433; // slt x8, x1, x2
    memory[8] = 32'h00209493; // sltu x9, x1, x2
    memory[9] = 32'h0010D513; // addi x10, x0, -5 (0xFFFFFFFB)
    memory[10] = 32'hFFF00593; // addi x11, x0, -1 (0xFFFFFFFF)
    memory[11] = 32'h4015D613; // sra x12, x11, 1
    memory[12] = 32'h123456B7; // lui x13, 0x12345
    memory[13] = 32'h00000717; // auipc x14, 0x0
    memory[14] = 32'h00412223; // sw x4, 0(x2)
    memory[15] = 32'h00412783; // lw x15, 0(x2)
    memory[16] = 32'h00410823; // sb x16, 0(x2)
    memory[17] = 32'h01010803; // lb x17, 0(x2)
    memory[18] = 32'h01014883; // lbu x18, 0(x2)
    memory[19] = 32'hFFE00913; // addi x19, x0, -2
    memory[20] = 32'h01211923; // sh x20, 0(x2)
    memory[21] = 32'h01211983; // lh x21, 0(x2)
    memory[22] = 32'h00C00B13; // lhu x22, 0(x2)
    memory[23] = 32'h00D00B93; // beq x1, x2, 8 (skip next instruction)
    memory[24] = 32'h00000013; // NOP (skipped by branch)
    memory[25] = 32'h00114A63; // bne x1, x2, 8 (take branch)
    memory[26] = 32'h00000013; // NOP (not taken by branch)
    memory[27] = 32'h00000013; // NOP
    memory[28] = 32'h00000013; // NOP
    memory[29] = 32'h00000013; // NOP
    memory[30] = 32'h00000013; // NOP
    memory[31] = 32'h00A00A93; // addi x21, x0, 10 (target of bne)
    memory[32] = 32'h00800F6F; // jal x1, 8 (PC+8)
    memory[33] = 32'h00000013; // NOP
    memory[34] = 32'h01215A03; // addi x22, x0, 12 (target of jal)
    memory[35] = 32'h000F8F67; // jalr x1, 0(x1)
    memory[36] = 32'h00208863; // addi x23, x0, 13 (target of jalr)
    memory[37] = 32'h00000073; // ecall
    memory[38] = 32'h00100073; // ebreak
end

assign Rd = memory[A[31:2]]; // Corrected: Read instruction from memory

endmodule
