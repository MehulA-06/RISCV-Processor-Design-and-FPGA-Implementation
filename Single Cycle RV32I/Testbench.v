`timescale 1ns / 1ps

module RISCV_Testbench();
    reg clk;
    reg rst;
    wire [7:0] led_out;

    RISCV_Top dut (
        .clk(clk),
        .rst(rst),
        .led_out(led_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
     
        rst = 1;
        #20 rst = 0;
        #20 rst = 1;
        
     #1000;
        
        $display("--- Verification ---");
        $display("PC_Current: %h", dut.PC_Current);
        $display("x1 (Exp: 5): %d", dut.rf.Reg[1]);
        $display("x2 (Exp: 3): %d", dut.rf.Reg[2]);
        $display("x3 (Exp: 8): %d", dut.rf.Reg[3]);
        
        $stop;
    end
endmodule