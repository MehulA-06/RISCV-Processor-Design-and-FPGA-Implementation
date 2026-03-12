`timescale 1ns / 1ps

module control_unit(
    input  [6:0] opcode,             
    input  [2:0] funct3,         
    input  [6:0] funct7,     
    input        Zero,           
    output       RegWrite, 
    output [2:0] ImmSrc,         
    output       ALUSrc,
    output       MemWrite,
    output [1:0] MemtoReg,      
    output [3:0] ALUControl,
    output       PCSrc           
);

    wire [1:0] alu_op_wire;
    wire       branch_wire;
    wire       jump_wire;

    main_decoder MD (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(branch_wire),    
        .ALUOp(alu_op_wire),
        .Jump(jump_wire)                  
    );

    ALU_decoder AD (
        .ALUOp(alu_op_wire),
        .funct3(funct3),
        .funct7(funct7[5]),
        .ALUControl(ALUControl)
    );

    assign PCSrc = (branch_wire & Zero)| jump_wire;

endmodule