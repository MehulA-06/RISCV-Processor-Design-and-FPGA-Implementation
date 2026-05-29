`timescale 1ns / 1ps
module PC(
    input [31:0] PC_next,
    input rst,
    input clk,stall,
    output reg [31:0] PC
);

always @(posedge clk or posedge rst) begin
    if (rst)
        PC <= 32'h00000000;
    else if (!stall)
        PC <= PC_next;
end

endmodule
