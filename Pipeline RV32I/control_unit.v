`timescale 1ns / 1ps
module control_unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    // input Zero, // Zero is not used here, it's for branch condition in EX stage
    output RegWrite,
    output [2:0] ImmSrc,
    output ALUSrc,
    output MemWrite,
    output [1:0] ResultSrc,
    output [3:0] ALUControl,
    output Branch,
    output Jump
    // output PCSrc // PCSrc is derived in EX stage
);

wire [1:0] alu_op_wire;
wire branch_wire;
wire jump_wire;

main_decoder MD (
    .opcode(opcode),
    .RegWrite(RegWrite),
    .ImmSrc(ImmSrc),
    .ALUSrc(ALUSrc),
    .MemWrite(MemWrite),
    .ResultSrc(ResultSrc),
    .Branch(branch_wire),
    .ALUOp(alu_op_wire),
    .Jump(jump_wire)
);

ALU_decoder AD (
    //.op5(op5), // Added opcode to ALU_decoder as it's used for LUI
    .ALUOp(alu_op_wire),
    .funct3(funct3),
    .funct7(funct7),
    .ALUControl(ALUControl)
);

assign Branch = branch_wire;
assign Jump = jump_wire;

endmodule
