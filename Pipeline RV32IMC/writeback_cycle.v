`timescale 1ns / 1ps
module writeback_cycle(
    input [1:0] ResultSrcW,
    input [31:0] PCPlus4W, ALU_ResultW, ReadDataW,
    output [31:0] ResultW
);

Mux result_mux (
    .a(ALU_ResultW),
    .b(ReadDataW),
    .c(PCPlus4W),
    .s(ResultSrcW),
    .d(ResultW)
);

endmodule
