`timescale 1ns / 1ps

module ALU_decoder(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input funct7,
    output reg [3:0] ALUControl
);

always @(*) begin
    case(ALUOp)
        2'b00: ALUControl = 4'b0010; // Addition (for lw, sw)
        2'b01: ALUControl = 4'b0110; // Subtraction (for beq)
        2'b10: begin
            case(funct3)
                3'b000: if (funct7)ALUControl = 4'b0001; // sub
                        else          ALUControl = 4'b0000; // add/addi
                3'b010:               ALUControl = 4'b1000; // slt
                3'b110:               ALUControl = 4'b0011; // or
                3'b111:               ALUControl = 4'b0010; // and
                3'b011:               ALUControl = 4'b1001; //sltu
                3'b001:               ALUControl = 4'b0101; //sll
                3'b101: if (funct7)ALUControl = 4'b0111; // sra
                        else          ALUControl = 4'b0110; // srl
                default:              ALUControl = 4'b0000;
            endcase
        end
        default: ALUControl = 4'b0000;
    endcase
end
endmodule