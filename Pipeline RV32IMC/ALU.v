`timescale 1ns / 1ps
module ALU(
    input [31:0] SrcA,SrcB,
    input [3:0] ALUControl,
    output [31:0] ALUResult,
    output Zero
);

reg [31:0] alu_out;

assign ALUResult = alu_out;
assign Zero = (alu_out == 32'b0);

always @(*) begin
    case (ALUControl)
        4'b0000: alu_out = SrcA + SrcB; // ADD
        4'b0001: alu_out = SrcA - SrcB; // SUB
        4'b0010: alu_out = SrcA & SrcB; // AND
        4'b0011: alu_out = SrcA | SrcB; // OR
        4'b0100: alu_out = SrcA ^ SrcB; // XOR
        4'b0101: alu_out = SrcA << SrcB[4:0]; // SLL
        4'b0110: alu_out = SrcA >> SrcB[4:0]; // SRL
        4'b0111: alu_out = $signed(SrcA) >>> SrcB[4:0]; // SRA
        4'b1000: alu_out = ($signed(SrcA) < $signed(SrcB)) ? 32'h1 : 32'h0; // SLT
        4'b1001: alu_out = (SrcA < SrcB) ? 32'h1 : 32'h0; // SLTU
        4'b1010: alu_out = SrcB; // Pass B (for LUI/AUIPC)
        default: alu_out = 32'h0; // Default to 0
    endcase
end

endmodule