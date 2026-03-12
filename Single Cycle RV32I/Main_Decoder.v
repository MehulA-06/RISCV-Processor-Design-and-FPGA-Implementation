`timescale 1ns / 1ps

module main_decoder(
    input  [6:0] opcode,
    output reg   [1:0] MemtoReg,
    output reg   MemWrite, Branch, ALUSrc, RegWrite, Jump,
    output reg   [2:0] ImmSrc,
    output reg   [1:0] ALUOp
  
);

always @(*) begin
    case(opcode)
        // R-type (add, sub, and, or)
        7'b0110011: begin
            RegWrite = 1; 
            ImmSrc = 3'b000; 
            ALUSrc = 0; 
            MemWrite = 0;
            MemtoReg = 2'b00; 
            Branch = 0; 
            ALUOp = 2'b10; 
            Jump = 0;
        end
        // I-type (addi)
        7'b0010011: begin
            RegWrite = 1; 
            ImmSrc = 3'b000; 
            ALUSrc = 1; 
            MemWrite = 0;
            MemtoReg = 2'b00; 
            Branch = 0; 
            ALUOp = 2'b10; 
            Jump = 0;
        end
        // lw 
        7'b0000011: begin
            RegWrite = 1; 
            ImmSrc = 3'b000; 
            ALUSrc = 1; 
            MemWrite = 0;
            MemtoReg = 2'b01; 
            Branch = 0; 
            ALUOp = 2'b00; 
            Jump = 0;
        end
        // sw
        7'b0100011: begin
            RegWrite = 0; 
            ImmSrc = 3'b001; 
            ALUSrc = 1; 
            MemWrite = 1;
            MemtoReg = 2'b00; 
            Branch = 0; 
            ALUOp = 2'b00; 
            Jump = 0;
        end
        // beq
        7'b1100011: begin
            RegWrite = 0; 
            ImmSrc = 3'b010; 
            ALUSrc = 0; 
            MemWrite = 0;
            MemtoReg = 2'b00; 
            Branch = 1; 
            ALUOp = 2'b01; 
            Jump = 0;
        end
        // lui
        7'b0110111: begin
            RegWrite = 1; 
            ImmSrc = 3'b011; 
            ALUSrc = 1; 
            MemWrite = 0;
            MemtoReg = 2'b00; 
            Branch = 0; 
            ALUOp = 2'b11; 
            Jump = 0;
        end
        // jal
        7'b1101111: begin
            RegWrite = 1; 
            ImmSrc = 3'b100; 
            ALUSrc = 1'b0; 
            MemWrite = 0;
            MemtoReg = 2'b10; 
            Branch = 0; 
            ALUOp = 2'b00; 
            Jump = 1;
        end
        default: begin
            RegWrite = 0; 
            ImmSrc = 3'b000; 
            ALUSrc = 0; 
            MemWrite = 0;
            MemtoReg = 0; 
            Branch = 0; 
            ALUOp = 2'b00; 
            Jump = 0;
        end
    endcase
end
endmodule