`timescale 1ns / 1ps


module execute_cycle(
    input  clk, rst, RegWriteE, ALUSrcE, MemWriteE, BranchE, JumpE,
    input  [1:0]  ResultSrcE,
    input  [3:0]  ALUControlE,
    input  [2:0]  Funct3_E,
    input  [31:0] RD1_E, RD2_E, Imm_Ext_E,
    input  [4:0]  RD_E,
    input  [31:0] PCE, PCPlus4E,
    input  [31:0] ResultW,        // WB forwarding
    input  [31:0] ALU_ResultM,    // MEM forwarding  (= EX/MEM pipeline reg output)
    input  [1:0]  ForwardA_E, ForwardB_E,
    input  IsMExtE,               // CHANGE 1: new input
    output reg PCSrcE,
    output [31:0] PCTargetE,
    output RegWriteM, MemWriteM,
    output [1:0]  ResultSrcM,
    output [4:0]  RD_M,
    output [31:0] PCPlus4M, WriteDataM, ALU_ResultM_out,
    output [2:0]  Funct3_M
);

    wire [31:0] Src_A, Src_B, Src_B_interim;
    wire [31:0] ResultE;     
    wire        ZeroE;

    assign Src_A = (ForwardA_E == 2'b00) ? RD1_E      :
                   (ForwardA_E == 2'b01) ? ResultW     :
                   (ForwardA_E == 2'b10) ? ALU_ResultM :
                   RD1_E;

    assign Src_B_interim = (ForwardB_E == 2'b00) ? RD2_E      :
                           (ForwardB_E == 2'b01) ? ResultW     :
                           (ForwardB_E == 2'b10) ? ALU_ResultM :
                           RD2_E;

    assign Src_B = ALUSrcE ? Imm_Ext_E : Src_B_interim;

    wire [31:0] jalr_target;
    assign jalr_target = Src_A + Imm_Ext_E;
    assign PCTargetE   = (JumpE && ALUSrcE) ? {jalr_target[31:1], 1'b0}
                                            : (PCE + Imm_Ext_E);


    ALU alu (
        .SrcA      (Src_A),
        .SrcB      (Src_B),
        .ALUControl(ALUControlE),
        .ALUResult (ResultE),
        .Zero      (ZeroE)
    );

    wire [31:0] MulDivResult;   
    MulDiv muldiv (
        .SrcA   (Src_A),
        .SrcB   (Src_B_interim), 
        .funct3 (Funct3_E),
        .Result (MulDivResult)
    );


    wire [31:0] FinalResultE;
    assign FinalResultE = IsMExtE ? MulDivResult : ResultE;

    reg branch_taken;
    always @(*) begin
        branch_taken = 1'b0;
        if (BranchE) begin
            case (Funct3_E)
                3'b000: branch_taken =  ZeroE;       // BEQ
                3'b001: branch_taken = !ZeroE;       // BNE
                3'b100: branch_taken =  ResultE[0];  // BLT
                3'b101: branch_taken = !ResultE[0];  // BGE
                3'b110: branch_taken =  ResultE[0];  // BLTU
                3'b111: branch_taken = !ResultE[0];  // BGEU
                default: branch_taken = 1'b0;
            endcase
        end
        PCSrcE = branch_taken | JumpE;
    end

    reg        RegWriteE_r, MemWriteE_r;
    reg [1:0]  ResultSrcE_r;
    reg [4:0]  RD_E_r;
    reg [31:0] PCPlus4E_r, RD2_E_r, ResultE_r_out;
    reg [2:0]  Funct3_E_r;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWriteE_r   <= 1'b0;
            MemWriteE_r   <= 1'b0;
            ResultSrcE_r  <= 2'b00;
            RD_E_r        <= 5'h0;
            PCPlus4E_r    <= 32'h0;
            RD2_E_r       <= 32'h0;
            ResultE_r_out <= 32'h0;
            Funct3_E_r    <= 3'b000;
        end
        else begin
            RegWriteE_r   <= RegWriteE;
            MemWriteE_r   <= MemWriteE;
            ResultSrcE_r  <= ResultSrcE;
            RD_E_r        <= RD_E;
            PCPlus4E_r    <= PCPlus4E;
            RD2_E_r       <= Src_B_interim;
            ResultE_r_out <= FinalResultE; 
            Funct3_E_r    <= Funct3_E;
        end
    end

    assign RegWriteM     = RegWriteE_r;
    assign MemWriteM     = MemWriteE_r;
    assign ResultSrcM    = ResultSrcE_r;
    assign RD_M          = RD_E_r;
    assign PCPlus4M      = PCPlus4E_r;
    assign WriteDataM    = RD2_E_r;
    assign ALU_ResultM_out = ResultE_r_out;
    assign Funct3_M      = Funct3_E_r;

endmodule
