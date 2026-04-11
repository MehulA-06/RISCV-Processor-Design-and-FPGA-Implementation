`timescale 1ns / 1ps
module Mux(
    input [31:0] a, b, c,
    input [1:0] s,
    output [31:0] d
);

// Multiplexer logic for selecting the final result in the Write-Back stage
// s = 2'b00: Select ALU result (a)
// s = 2'b01: Select Data Memory read data (b)
// s = 2'b10: Select PC+4 (c)
// default: Output 0
assign d = (s == 2'b00) ? a : 
           (s == 2'b01) ? b : 
           (s == 2'b10) ? c : 
           32'h00000000;

endmodule
