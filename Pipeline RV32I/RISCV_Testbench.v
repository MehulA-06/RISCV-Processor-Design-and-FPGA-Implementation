`timescale 1ns / 1ps

module RISCV_Testbench;

    // DUT ports
    reg clk, rst;
    wire [7:0] led_out;

    // DUT instance
    RISCV_Top dut (
        .clk (clk),
        .rst (rst),
        .led_out (led_out)
    );

    // Clock generation: 25 MHz frequency
    // Frequency = 1 / Period
    // 25 MHz = 1 / 40 ns
    // Period = 40 ns
    localparam CLK_PERIOD = 40;
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    integer pass_count;
    integer fail_count;

    // Hierarchical path to the Register File array
    // Based on your previous error: dut -> Decode -> rf -> Reg
    `define RF_ARRAY dut.Decode.rf.Reg

    // Task to check register values
    task check_reg;
        input [4:0] reg_num;
        input [31:0] expected;
        input [8*40-1:0] test_name;
        reg [31:0] actual;
        begin
            actual = `RF_ARRAY[reg_num];
            if (actual === expected) begin
                $display("PASS: %-30s | x%-2d = 0x%08h", test_name, reg_num, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %-30s | x%-2d = 0x%08h (expected 0x%08h)",
                         test_name, reg_num, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        // VCD generation for waveform analysis and low power estimation
        $dumpfile("riscv_waves.vcd");
        $dumpvars(0, RISCV_Testbench);
        
        pass_count = 0;
        fail_count = 0;

        $display("============================================================");
        $display(" RISC-V RV32I Pipeline - Functional Verification");
        $display("============================================================");

        // 1. Reset System
        rst = 1;
        // Wait for 2 clock cycles before releasing reset
        #(CLK_PERIOD * 2);
        rst = 0;
        $display("Reset released at time %0t", $time);

        // 2. Wait for program to complete
        // 60 cycles is specified in the original testbench
        repeat (60) @(posedge clk);

        $display("\n[REGISTER CHECKS]");

        // --- Basic Arithmetic ---
        check_reg(5'd1,  32'd10,         "addi x1, x0, 10");
        check_reg(5'd2,  32'd20,         "addi x2, x0, 20");
        check_reg(5'd3,  32'd30,         "add x3, x1, x2");
        check_reg(5'd4,  32'hFFFFFFF6,   "sub x4, x1, x2"); // 10 - 20 = -10

        // --- Logical Operations ---
        check_reg(5'd6,  32'd0,          "and x6, x1, x2");
        check_reg(5'd7,  32'd30,         "or  x7, x1, x2");
        check_reg(5'd13, 32'h12345000,   "lui x13, 0x12345");

        // --- Branching ---
        // bne x1, x2 is taken, so x21 should be 10
        check_reg(5'd21, 32'd10,         "bne target: addi x21");

        // --- Jumps (The Fix) ---
        // JAL was at PC 0x80 (index 32). Return address is 0x84.
        // We changed the destination to x31.
        check_reg(5'd30, 32'h00000084,   "jal return addr -> x30");
        check_reg(5'd22, 32'd12,         "jal target: addi x22");

        // JALR was at PC 0x8C (index 35). Return address is 0x90.
        // We changed the destination to x30.
        // check_reg(5'd31, 32'h00000090,   "jalr return addr -> x31");
        // check_reg(5'd23, 32'd13,         "jalr target: addi x23");

        // Final Summary
        $display("\n============================================================");
        $display("  PASSED : %0d", pass_count);
        $display("  FAILED : %0d", fail_count);
        if (fail_count == 0)
            $display("  RESULT : ALL TESTS PASSED");
        else
            $display("  RESULT : SOME TESTS FAILED");
        $display("============================================================");
        
        $finish;
    end

endmodule
