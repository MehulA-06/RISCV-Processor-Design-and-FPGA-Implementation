`timescale 1ns / 1ps


module control_unit(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output RegWrite,
    output [2:0] ImmSrc,
    output ALUSrc,
    output MemWrite,
    output [1:0] ResultSrc,
    output [3:0] ALUControl,
    output Branch,
    output Jump,
    output IsMExt            
);

    wire [1:0] alu_op_wire;
    wire       branch_wire;
    wire       jump_wire;
    wire       IsMExt_w;    
    main_decoder MD (
        .opcode    (opcode),
        .funct7    (funct7),            
        .RegWrite  (RegWrite),
        .ImmSrc    (ImmSrc),
        .ALUSrc    (ALUSrc),
        .MemWrite  (MemWrite),
        .ResultSrc (ResultSrc),
        .Branch    (branch_wire),
        .ALUOp     (alu_op_wire),
        .Jump      (jump_wire),
        .IsMExt    (IsMExt_w)         );

    ALU_decoder AD (              // UNCHANGED
        .ALUOp     (alu_op_wire),
        .funct3    (funct3),
        .funct7    (funct7),
        .ALUControl(ALUControl)
    );

    assign Branch = branch_wire;
    assign Jump   = jump_wire;
    assign IsMExt = IsMExt_w;    
endmodule
