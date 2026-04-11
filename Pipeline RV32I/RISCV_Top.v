`timescale 1ns / 1ps
module RISCV_Top(
    input clk,
    input rst,
    output [7:0] led_out
);

wire PCSrcE, FlushE, FlushD, StallF, StallD;
wire RegWriteW, RegWriteE, ALUSrcE, MemWriteE, BranchE, JumpE;
wire RegWriteM, MemWriteM;
wire [1:0] ResultSrcM, ResultSrcW;
wire [1:0] ResultSrcE;
wire [2:0] Funct3_E, Funct3_M;
wire [3:0] ALUControlE;
wire [4:0] RD_E, RD_M, RDW;
wire [31:0] PCTargetE, InstrD, PCD, PCPlus4D, ResultW;
wire [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E;
wire [31:0] PCPlus4M, WriteDataM, ALU_ResultM;
wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;
wire [4:0] RS1_E, RS2_E;
wire [1:0] ForwardAE, ForwardBE;
wire [31:0] cycle_count, instr_count;

assign led_out = ALU_ResultM[7:0];

fetch_cycle Fetch (
    .clk(clk),
    .rst(rst),
    .PCSrcE(PCSrcE),
    .PCTargetE(PCTargetE),
    .StallF(StallF),
    .StallD(StallD),
    .FlushD(FlushD),
    .InstrD(InstrD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D)
);

decode_cycle Decode (
    .clk(clk),
    .rst(rst),
    .InstrD(InstrD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D),
    .RegWriteW(RegWriteW),
    .RDW(RDW),
    .ResultW(ResultW),
    .FlushE(FlushE),
    .RegWriteE(RegWriteE),
    .ALUSrcE(ALUSrcE),
    .MemWriteE(MemWriteE),
    .ResultSrcE(ResultSrcE),
    .BranchE(BranchE),
    .JumpE(JumpE),
    .ALUControlE(ALUControlE),
    .RD1_E(RD1_E),
    .RD2_E(RD2_E),
    .Imm_Ext_E(Imm_Ext_E),
    .RD_E(RD_E),
    .PCE(PCE),
    .PCPlus4E(PCPlus4E),
    .RS1_E(RS1_E),
    .RS2_E(RS2_E),
    .Funct3_E(Funct3_E)
);

execute_cycle Execute (
    .clk(clk),
    .rst(rst),
    .RegWriteE(RegWriteE),
    .ALUSrcE(ALUSrcE),
    .MemWriteE(MemWriteE),
    .ResultSrcE(ResultSrcE),
    .BranchE(BranchE),
    .JumpE(JumpE),
    .ALUControlE(ALUControlE),
    .Funct3_E(Funct3_E),
    .RD1_E(RD1_E),
    .RD2_E(RD2_E),
    .Imm_Ext_E(Imm_Ext_E),
    .RD_E(RD_E),
    .PCE(PCE),
    .PCPlus4E(PCPlus4E),
    .PCSrcE(PCSrcE),
    .PCTargetE(PCTargetE),
    .RegWriteM(RegWriteM),
    .MemWriteM(MemWriteM),
    .ResultSrcM(ResultSrcM),
    .RD_M(RD_M),
    .PCPlus4M(PCPlus4M),
    .WriteDataM(WriteDataM),
    .ALU_ResultM_out(ALU_ResultM),
    .ResultW(ResultW),
    .ForwardA_E(ForwardAE),
    .ForwardB_E(ForwardBE),
    .Funct3_M(Funct3_M) // Added Funct3_M
);

memory_cycle Memory (
    .clk(clk),
    .rst(rst),
    .RegWriteM(RegWriteM),
    .MemWriteM(MemWriteM),
    .ResultSrcM(ResultSrcM),
    .RD_M(RD_M),
    .PCPlus4M(PCPlus4M),
    .WriteDataM(WriteDataM),
    .ALU_ResultM(ALU_ResultM),
    .Funct3_M(Funct3_M), // Added Funct3_M
    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW),
    .RD_W(RDW),
    .PCPlus4W(PCPlus4W),
    .ALU_ResultW(ALU_ResultW),
    .ReadDataW(ReadDataW)
);

writeback_cycle WriteBack (
    .ResultSrcW(ResultSrcW),
    .PCPlus4W(PCPlus4W),
    .ALU_ResultW(ALU_ResultW),
    .ReadDataW(ReadDataW),
    .ResultW(ResultW)
);

forwarding_unit Forwarding_block (
    .RegWriteM(RegWriteM),
    .RegWriteW(RegWriteW),
    .RD_M(RD_M),
    .RDW(RDW),
    .RS1_E(RS1_E),
    .RS2_E(RS2_E),
    .ForwardA_E(ForwardAE),
    .ForwardB_E(ForwardBE)
);

hazard_unit HazardUnit (
    .RS1_D (InstrD[19:15]),
    .RS2_D (InstrD[24:20]),
    .RD_E (RD_E),
    .ResultSrcE (ResultSrcE),
    .PCSrcE (PCSrcE),
    .StallF (StallF),
    .StallD (StallD),
    .FlushE (FlushE),
    .FlushD (FlushD)
);

endmodule
