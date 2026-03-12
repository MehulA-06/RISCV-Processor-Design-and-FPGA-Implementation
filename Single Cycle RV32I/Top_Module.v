`timescale 1ns / 1ps

module RISCV_Top(
    input clk,
    input rst,
    output [7:0] led_out
);

    wire [31:0] PC_Current;
    wire [31:0] PC_Next;
    wire [31:0] PC_Plus4;
    wire [31:0] PCTarget;

    wire [31:0] Instr;
    wire [31:0] Result;
    wire [31:0] ReadData;
    wire [31:0] ALUResult;

    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] WriteData;
    wire [31:0] ImmExt;

    wire [3:0] ALUControl;
    wire [2:0] ImmSrc;
    wire [1:0] MemtoReg;

    wire RegWrite;
    wire ALUSrc;
    wire MemWrite;
    wire PCSrc;
    wire Zero;

    wire [31:0] cycle_count;
    wire [31:0] instr_count;

    reg [26:0] clk_div;
reg slow_clk;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        clk_div <= 0;
        slow_clk <= 0;
    end
    else begin
        clk_div <= clk_div + 1;
        slow_clk <= clk_div[25];   // slow clock
    end
end

    assign led_out = PC_Current[7:0];

    PC p_counter (
        .PC_next(PC_Next),
        .PC(PC_Current),
        .rst(rst),
        .clk(slow_clk)
    );

    assign PC_Plus4 = PC_Current + 32'd4;
    assign PCTarget = PC_Current + ImmExt;
    assign PC_Next  = (PCSrc) ? PCTarget : PC_Plus4;

    Inst_memory i_mem (
        .A(PC_Current),
        .rst(rst),
        .Rd(Instr)
    );

    Reg_file rf (
        .A1(Instr[19:15]),
        .A2(Instr[24:20]),
        .A3(Instr[11:7]),
        .Wd3(Result),
        .clk(slow_clk),
        .rst(rst),
        .RegWrite(RegWrite),
        .Rd1(SrcA),
        .Rd2(WriteData)
    );

    control_unit cu (
        .opcode(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7(Instr[30]),
        .Zero(Zero),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUControl(ALUControl),
        .PCSrc(PCSrc)
    );

    Sign_extend ext_imm (
        .instr(Instr[31:7]),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    assign SrcB = (ALUSrc) ? ImmExt : WriteData;

    
    ALU core_alu (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUControl(ALUControl),
        .Zero(Zero),
        .ALUResult(ALUResult)
    );

    Data_memory d_mem (
        .A(ALUResult),
        .Wd(WriteData),
        .clk(slow_clk),
        .MemWrite(MemWrite),
        .Rd(ReadData)
    );

  
    PerformanceCounter perf_count(
        .clk(slow_clk),
        .rst(rst),
        .enable(RegWrite),
        .cycle_count(cycle_count),
        .instr_count(instr_count)
    );

    
    assign Result = (MemtoReg == 2'b00) ? ALUResult :
                    (MemtoReg == 2'b01) ? ReadData  :
                    (MemtoReg == 2'b10) ? PC_Plus4  :
                    ALUResult;

endmodule