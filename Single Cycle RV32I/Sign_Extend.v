`timescale 1ns / 1ps

module Sign_extend(
    input  [31:7] instr, 
    input   [2:0] ImmSrc,     
    output reg [31:0] ImmExt
);

    always @(*) begin
        case(ImmSrc)
           3'b000: ImmExt = {{20{instr[31]}}, instr[31:20]};                  // I-type 
           3'b001: ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};     // S-type 
           3'b010: ImmExt = {{19{instr[31]}},instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type 
           3'b011: ImmExt = {instr[31:12], 12'b0};                            // U-type (lui, auipc)
           3'b100: ImmExt = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type (jal)
           default: ImmExt = 32'b0; 
        endcase
    end
endmodule