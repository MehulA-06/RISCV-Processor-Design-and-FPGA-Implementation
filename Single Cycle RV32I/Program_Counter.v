`timescale 1ns / 1ps

module PC(PC_next,PC,rst,clk);

input [31:0] PC_next;
input rst;
input clk;

output reg [31:0] PC;

always @(posedge clk or posedge rst) begin
    if (rst)
        PC <= 32'h00000000;
    else
        PC <= PC_next;
end

endmodule
