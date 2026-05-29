module Inst_memory(
    input  [31:0] A,
    input  rst,
    output [31:0] Rd,       // 32-bit word at  A[31:2]
    output [31:0] Rd_next   );

    (* ram_style="block" *) reg [31:0] memory [0:255];
    integer i;

    initial begin
       
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;

        memory[ 0] = 32'h00A00093; // addi x1,  x0, 10      ? x1 = 10
        memory[ 1] = 32'h01400113; // addi x2,  x0, 20      ? x2 = 20
        memory[ 2] = 32'h00000013; // NOP
        memory[ 3] = 32'h00000013; // NOP
        memory[ 4] = 32'h00000013; // NOP
        memory[ 5] = 32'h002081B3; // add  x3,  x1, x2      ? x3 = 30
        memory[ 6] = 32'h40208233; // sub  x4,  x1, x2      ? x4 = -10
        memory[ 7] = 32'h0020F333; // and  x6,  x1, x2      ? x6 = 0
        memory[ 8] = 32'h0020E3B3; // or   x7,  x1, x2      ? x7 = 30
        memory[ 9] = 32'h123456B7; // lui  x13, 0x12345     ? x13 = 0x12345000
        memory[10] = 32'h00000013; // NOP
        memory[11] = 32'h00000013; // NOP
        memory[12] = 32'h00000013; // NOP
        memory[13] = 32'h00209663; // bne  x1, x2, +12      (taken ? mem[16])
        memory[14] = 32'h00000013; // NOP (skipped)
        memory[15] = 32'h00000013; // NOP (skipped)
        memory[16] = 32'h00A00A93; // addi x21, x0, 10      ? x21 = 10
        memory[17] = 32'h00000013; // NOP
        memory[18] = 32'h00000013; // NOP
        memory[19] = 32'h00000013; // NOP
        memory[20] = 32'h00000013; // NOP
        memory[21] = 32'h00000013; // NOP
        memory[22] = 32'h00000013; // NOP
        memory[23] = 32'h00800F6F; // jal  x30, +8          ? x30 = PC+4 = 0x60 (? mem[25])
        memory[24] = 32'h00000013; // NOP (skipped)
        memory[25] = 32'h00C00B13; // addi x22, x0, 12      ? x22 = 12
        memory[26] = 32'h010F0EE7; // jalr x29, 16(x30)     ? x29 = PC+4 = 0x6C (? mem[28])
        memory[27] = 32'h00000013; // NOP (skipped)
        memory[28] = 32'h00D00B93; // addi x23, x0, 13      ? x23 = 13
        memory[29] = 32'h00000013; // NOP (pipeline drain)
        memory[30] = 32'h022082B3; // mul  x5,  x1, x2      ? x5  = 200
        memory[31] = 32'h00000013; // NOP
        memory[32] = 32'h02114433; // div  x8,  x2, x1      ? x8  = 2
        memory[33] = 32'h00000013; // NOP
        memory[34] = 32'h0221E4B3; // rem  x9,  x3, x2      ? x9  = 10
        memory[35] = 32'h00000013; // NOP (pipeline drain before C instructions)
        memory[36] = {16'h4841, 16'h45A1}; // x16=16, x11=8
        memory[37] = {16'h8942, 16'h4885}; // x18=x16, x17=1
        
        memory[38] = {16'h0001, 16'h0001};
        
        memory[39] = {16'h0785, 16'h98C2}; 
        memory[40] = {16'h0001, 16'h0001};
    end

    assign Rd      = memory[A[31:2]];
    assign Rd_next = memory[A[31:2] + 1];

endmodule