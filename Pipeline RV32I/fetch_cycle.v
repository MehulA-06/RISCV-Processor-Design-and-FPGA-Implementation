`timescale 1ns / 1ps
module fetch_cycle(
    input clk,
    input rst,
    input PCSrcE,
    input [31:0] PCTargetE,
    input StallF,
    input StallD,
    input FlushD,
    output [31:0] InstrD,
    output [31:0] PCD,
    output [31:0] PCPlus4D
);

wire [31:0] PC_F, PCF, PCPlus4F;
wire [31:0] InstrF;

reg [31:0] InstrF_reg, PCF_reg, PCPlus4F_reg;

PC Program_counter(
    .PC_next(PC_F),
    .PC(PCF),
    .rst(rst),
    .clk(clk),
    .stall(StallF)
);

Inst_memory In_mem(
    .A(PCF),
    .rst(rst),
    .Rd(InstrF)
);

assign PCPlus4F = PCF + 32'd4;
assign PC_F = PCSrcE ? PCTargetE : PCPlus4F;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        InstrF_reg <= 32'h00000013; // NOP instruction
        PCF_reg <= 32'h00000000;
        PCPlus4F_reg <= 32'h00000000;
    end
    else if (FlushD) begin // Flush on branch/jump
        InstrF_reg <= 32'h00000013; // Inject NOP
        PCF_reg <= PCF; // PC still updates, but instruction is NOP
        PCPlus4F_reg <= PCPlus4F;
    end
    else if (!StallD) begin // Only update if not stalled
        InstrF_reg <= InstrF;
        PCF_reg <= PCF;
        PCPlus4F_reg <= PCPlus4F;
    end
end

assign InstrD = InstrF_reg;
assign PCD = PCF_reg;
assign PCPlus4D = PCPlus4F_reg;

endmodule
