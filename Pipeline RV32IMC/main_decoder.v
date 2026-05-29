`timescale 1ns / 1ps

module main_decoder(
    input  [6:0] opcode,
    input  [6:0] funct7,         
    output reg [1:0] ResultSrc,
    output reg MemWrite, Branch, ALUSrc, RegWrite, Jump,
    output reg [2:0] ImmSrc,
    output reg [1:0] ALUOp,
    output reg IsMExt            );

    always @(*) begin
     
        RegWrite  = 0;
        ImmSrc    = 3'b000;
        ALUSrc    = 0;
        MemWrite  = 0;
        ResultSrc = 2'b00;
        Branch    = 0;
        ALUOp     = 2'b00;
        Jump      = 0;
        IsMExt    = 0;            
        case (opcode)

            7'b0110011: begin
                RegWrite  = 1;
                ALUSrc    = 0;
                ResultSrc = 2'b00;
                ALUOp     = 2'b10;
                if (funct7 == 7'b0000001)
                    IsMExt = 1;   // CHANGE 5: flag M-ext
            end

            7'b0010011: begin     // I-type ALU
                RegWrite  = 1;
                ImmSrc    = 3'b000;
                ALUSrc    = 1;
                ResultSrc = 2'b00;
                ALUOp     = 2'b10;
            end

            7'b0000011: begin     // Load
                RegWrite  = 1;
                ImmSrc    = 3'b000;
                ALUSrc    = 1;
                MemWrite  = 0;
                ResultSrc = 2'b01;
                ALUOp     = 2'b00;
            end

            7'b0100011: begin     // Store
                RegWrite  = 0;
                ImmSrc    = 3'b001;
                ALUSrc    = 1;
                MemWrite  = 1;
                ResultSrc = 2'b00;
                ALUOp     = 2'b00;
            end

            7'b1100011: begin     // Branch
                RegWrite  = 0;
                ImmSrc    = 3'b010;
                ALUSrc    = 0;
                Branch    = 1;
                ALUOp     = 2'b01;
            end

            7'b0110111: begin     // LUI
                RegWrite  = 1;
                ImmSrc    = 3'b011;
                ALUSrc    = 1;
                ResultSrc = 2'b00;
                ALUOp     = 2'b11;
            end

            7'b1101111: begin     // JAL
                RegWrite  = 1;
                ImmSrc    = 3'b100;
                ALUSrc    = 0;
                ResultSrc = 2'b10;
                Jump      = 1;
                ALUOp     = 2'b00;
            end

            7'b1100111: begin     // JALR
                RegWrite  = 1;
                ImmSrc    = 3'b000;
                ALUSrc    = 1;
                ResultSrc = 2'b10;
                Jump      = 1;
                ALUOp     = 2'b00;
            end

            default: begin end   
        endcase
    end

endmodule
