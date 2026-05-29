`timescale 1ns / 1ps


module fetch_cycle(
    input  clk,
    input  rst,
    input  PCSrcE,
    input  [31:0] PCTargetE,
    input  StallF,
    input  StallD,
    input  FlushD,
    output [31:0] InstrD,
    output [31:0] PCD,
    output [31:0] PCPlus4D   // semantics: PC + 2 (compressed) or PC + 4 (32-bit)
);


    wire [31:0] PC_F, PCF;
    wire [31:0] PCNextF;          
    wire [31:0] InstrF_raw;      
    wire [31:0] InstrF_next;      
    wire [31:0] InstrF;          

    reg [31:0] InstrF_reg;
    reg [31:0] PCF_reg;
    reg [31:0] PCNextF_reg;   


    PC Program_counter (
        .PC_next (PC_F),
        .PC      (PCF),
        .rst     (rst),
        .clk     (clk),
        .stall   (StallF)
    );

    Inst_memory In_mem (
        .A      (PCF),
        .rst    (rst),
        .Rd     (InstrF_raw),
        .Rd_next(InstrF_next)    // CHANGE 1
    );

    wire [15:0] curr_half = PCF[1] ? InstrF_raw[31:16]  
                                   : InstrF_raw[15:0];    

    wire is_compressed = (curr_half[1:0] != 2'b11);

    wire [31:0] raw_instr32;
    assign raw_instr32 = PCF[1] ? {InstrF_next[15:0], InstrF_raw[31:16]}
                                 : InstrF_raw;

    wire [31:0] decompressed_instr;  
    Decompressor decomp (            
        .c_instr (curr_half),
        .instr32 (decompressed_instr)
    );


    assign InstrF = is_compressed ? decompressed_instr : raw_instr32;


    assign PCNextF = is_compressed ? (PCF + 32'd2) : (PCF + 32'd4);


    assign PC_F = PCSrcE ? PCTargetE : PCNextF;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            InstrF_reg  <= 32'h00000013;   // NOP
            PCF_reg     <= 32'h00000000;
            PCNextF_reg <= 32'h00000000;   
        end
        else if (FlushD) begin
        
            InstrF_reg  <= 32'h00000013;   
            PCF_reg     <= PCF;
            PCNextF_reg <= PCNextF;        
        end
        else if (!StallD) begin
            InstrF_reg  <= InstrF;         
            PCF_reg     <= PCF;
            PCNextF_reg <= PCNextF;      
        end

    end


    assign InstrD   = InstrF_reg;
    assign PCD      = PCF_reg;
    assign PCPlus4D = PCNextF_reg;  
endmodule