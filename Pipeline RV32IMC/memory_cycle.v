`timescale 1ns / 1ps
module memory_cycle(
    input clk, rst, RegWriteM, MemWriteM,
    input [1:0] ResultSrcM,
    input [4:0] RD_M,
    input [31:0] PCPlus4M, WriteDataM, ALU_ResultM,
    input [2:0] Funct3_M,
    output RegWriteW,
    output [1:0] ResultSrcW,
    output [4:0] RD_W,
    output [31:0] PCPlus4W, ALU_ResultW, ReadDataW
);

wire [31:0] ReadDataM;
reg RegWriteM_r;
reg [1:0] ResultSrcM_r;
reg [4:0] RD_M_r;
reg [31:0] PCPlus4M_r, ALU_ResultM_r, ReadDataM_r;

Data_memory dmem (
    .clk(clk),
    .rst(rst),
    .MemWrite(MemWriteM),
    .size(Funct3_M[1:0]),
    .sign_ext(!Funct3_M[2]),
    .A(ALU_ResultM),
    .Wd(WriteDataM),
    .Rd(ReadDataM)
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        RegWriteM_r <= 1'b0;
        ResultSrcM_r <= 2'b00;
        RD_M_r <= 5'h00;
        PCPlus4M_r <= 32'h00000000;
        ALU_ResultM_r <= 32'h00000000;
        ReadDataM_r <= 32'h00000000;
    end
    else begin
        RegWriteM_r <= RegWriteM;
        ResultSrcM_r <= ResultSrcM;
        RD_M_r <= RD_M;
        PCPlus4M_r <= PCPlus4M;
        ALU_ResultM_r <= ALU_ResultM;
        ReadDataM_r <= ReadDataM;
    end
end

assign RegWriteW = RegWriteM_r;
assign ResultSrcW = ResultSrcM_r;
assign RD_W = RD_M_r;
assign PCPlus4W = PCPlus4M_r;
assign ALU_ResultW = ALU_ResultM_r;
assign ReadDataW = ReadDataM_r;

endmodule
