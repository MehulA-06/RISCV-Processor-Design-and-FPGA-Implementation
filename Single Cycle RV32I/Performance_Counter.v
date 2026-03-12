`timescale 1ns / 1ps

module PerformanceCounter(
    input clk, rst, enable,
    output reg [31:0] cycle_count,
    output reg [31:0] instr_count
);
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            cycle_count <= 0;
            instr_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
            if(enable)
                instr_count <= instr_count + 1;
        end
    end
endmodule