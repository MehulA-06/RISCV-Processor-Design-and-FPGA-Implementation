`timescale 1ns / 1ps
module Reg_file(
    input [4:0] A1,A2,A3,
    input [31:0] Wd3,
    input clk,rst,RegWrite,
    output [31:0] Rd1,Rd2
);

reg [31:0] Reg [0:31];
integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1) begin
            Reg[i] <= 32'b0;
        end
    end
    else if (RegWrite && (A3 != 5'b00000)) begin // x0 cannot be written
        Reg[A3] <= Wd3;
    end
end

assign Rd1 = (A1 == 5'b0) ? 32'h0 : Reg[A1]; // Read x0 as 0
assign Rd2 = (A2 == 5'b0) ? 32'h0 : Reg[A2]; // Read x0 as 0

endmodule
