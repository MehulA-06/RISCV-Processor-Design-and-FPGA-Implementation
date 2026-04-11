`timescale 1ns / 1ps
module main_decoder(
    input [6:0] opcode,
    output reg [1:0] ResultSrc,
    output reg MemWrite, Branch, ALUSrc, RegWrite, Jump,
    output reg [2:0] ImmSrc,
    output reg [1:0] ALUOp
);

always @(*) begin
    // Default values to avoid latches and ensure defined state
    RegWrite = 0;
    ImmSrc = 3'b000;
    ALUSrc = 0;
    MemWrite = 0;
    ResultSrc = 2'b00;
    Branch = 0;
    ALUOp = 2'b00;
    Jump = 0;

    case(opcode)
        // R-type (add, sub, and, or, etc.)
        7'b0110011: begin
            RegWrite = 1;
            ALUSrc = 0; // Register operand
            ResultSrc = 2'b00; // ALU result to register
            ALUOp = 2'b10; // R-type ALU operation
        end
        // I-type (addi, slti, andi, ori, xori)
        7'b0010011: begin
            RegWrite = 1;
            ImmSrc = 3'b000; // I-type immediate
            ALUSrc = 1; // Immediate operand
            ResultSrc = 2'b00; // ALU result to register
            ALUOp = 2'b10; // I-type ALU operation
        end
        // Load Word (lw)
        7'b0000011: begin
            RegWrite = 1;
            ImmSrc = 3'b000; // I-type immediate
            ALUSrc = 1; // Immediate operand
            MemWrite = 0;
            ResultSrc = 2'b01; // Data memory read to register
            ALUOp = 2'b00; // Addition for address calculation
        end
        // Store Word (sw)
        7'b0100011: begin
            RegWrite = 0;
            ImmSrc = 3'b001; // S-type immediate
            ALUSrc = 1; // Immediate operand
            MemWrite = 1;
            ResultSrc = 2'b00; // Not writing to register
            ALUOp = 2'b00; // Addition for address calculation
        end
        // Branch Equal (beq)
        7'b1100011: begin
            RegWrite = 0;
            ImmSrc = 3'b010; // B-type immediate
            ALUSrc = 0; // Register operand comparison
            Branch = 1;
            ALUOp = 2'b01; // Subtraction for branch condition
        end
        // Load Upper Immediate (lui)
        7'b0110111: begin
            RegWrite = 1;
            ImmSrc = 3'b011; // U-type immediate
            ALUSrc = 1; // Immediate operand
            ResultSrc = 2'b00; // ALU result (immediate) to register
            ALUOp = 2'b11; // Pass B (immediate) to ALU
        end
        // Jump and Link (jal)
        7'b1101111: begin
            RegWrite = 1;
            ImmSrc = 3'b100; // J-type immediate
            ALUSrc = 0; // PC + immediate
            ResultSrc = 2'b10; // PC+4 to register
            Jump = 1;
            ALUOp = 2'b00; // Addition for target address
        end
        // Jump and Link Register (jalr)
        7'b1100111: begin // Corrected opcode for JALR
            RegWrite = 1;
            ImmSrc = 3'b000; // I-type immediate for offset
            ALUSrc = 1; // Register + immediate
            ResultSrc = 2'b10; // PC+4 to register
            Jump = 1;
            ALUOp = 2'b00; // Addition for target address
        end
        default: begin
            // Default values are already set at the beginning of the always block
        end
    endcase
end

endmodule