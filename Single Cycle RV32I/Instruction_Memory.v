`timescale 1ns / 1ps

module Inst_memory(A,rst,Rd);

input [31:0] A;
input rst;

output [31:0] Rd;

(* ram_style="block" *)
reg [31:0] memory [0:255]; //this means that there is a memory defined by regiters, the memory consists of 256 registers and each regiter is 32bit in size

integer i;

initial begin
for(i=0;i<256;i=i+1)
    memory[i] = 32'h00000013;

// Program instructions
memory[0]  = 32'h00500093;
memory[1]  = 32'h00300113;
memory[2]  = 32'h002081B3;
memory[3]  = 32'h40208233;
memory[4]  = 32'h0020A2B3;
memory[5]  = 32'h0020F333;
memory[6]  = 32'h0020E3B3;
memory[7]  = 32'h0020C433;

memory[8]  = 32'h00209493;
memory[9]  = 32'h0010D513;
memory[10] = 32'hFFF00593;
memory[11] = 32'h4015D613;

memory[12] = 32'h123456B7;
memory[13] = 32'h00000717;

memory[14] = 32'h00412223;
memory[15] = 32'h00412783;

memory[16] = 32'h00410823;
memory[17] = 32'h01010803;
memory[18] = 32'h01014883;

memory[19] = 32'hFFE00913;
memory[20] = 32'h01211923;
memory[21] = 32'h01211983;
memory[22] = 32'h01215A03;

memory[23] = 32'h00208863;
memory[24] = 32'h00209463;
memory[25] = 32'h00000013;
memory[26] = 32'h00114A63;

memory[31] = 32'h00A00A93;

memory[32] = 32'h008000EF;
memory[34] = 32'h00C00B13;
memory[35] = 32'h00008067;
memory[36] = 32'h00D00B93;

memory[37] = 32'h00000073;
memory[38] = 32'h00100073;

end
     
assign Rd = (rst==1'b0) ? 32'h00000000 : memory [A[31:2]];
 
endmodule
