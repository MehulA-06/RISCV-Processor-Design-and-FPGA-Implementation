`timescale 1ns / 1ps

module ALU(SrcA,SrcB,ALUControl,Zero,ALUResult);

input [31:0] SrcA,SrcB;
input [3:0] ALUControl;

output [31:0] ALUResult;
output Zero;

reg [31:0] alu_out;
assign ALUResult = alu_out;
assign Zero = (alu_out == 32'b0);
    
always @(*)
    begin
        case (ALUControl)
            4'b0000: alu_out = SrcA + SrcB;
            4'b0001: alu_out = SrcA - SrcB;
            4'b0010: alu_out = SrcA & SrcB;                 
            4'b0011: alu_out = SrcA | SrcB;
            4'b0100: alu_out = SrcA ^ SrcB;
            4'b0101: alu_out = SrcA << SrcB[4:0]; //(SLL)
            4'b0110: alu_out = SrcA >> SrcB[4:0]; //(SRL)                 
            4'b0111: alu_out = $signed(SrcA) >>> SrcB[4:0];                
            4'b1000: alu_out = ($signed(SrcA) < $signed(SrcB)) ? 32'h1 : 32'h0; //SLT
            4'b1001: alu_out = (SrcA < SrcB) ? SrcA : 0; //SLTU
            4'b1010: alu_out = SrcB; // pass B for U type
            default: alu_out = 32'h0;                     
        endcase
    end

endmodule
