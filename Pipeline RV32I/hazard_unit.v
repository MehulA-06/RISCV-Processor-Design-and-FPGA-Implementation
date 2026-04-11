`timescale 1ns / 1ps
module hazard_unit (
    input [4:0] RS1_D, RS2_D,
    input [4:0] RD_E,
    input [1:0] ResultSrcE,
    input PCSrcE,
    output StallF,
    output StallD,
    output FlushE,
    output FlushD
);

// Load-use hazard: load in EX, consumer in ID
// ResultSrcE == 2'b01 indicates a load instruction
wire load_use = (ResultSrcE == 2'b01) &&
                ((RD_E == RS1_D) || (RD_E == RS2_D)) &&
                (RD_E != 5'b0);

assign StallF = load_use;
assign StallD = load_use;
assign FlushE = load_use | PCSrcE;
assign FlushD = PCSrcE;

endmodule
