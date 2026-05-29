`timescale 1ns / 1ps
module RISCV_Testbench;

    localparam CLK_PERIOD  = 40;    // ns  (10 = 100 MHz ZedBoard,
                                    //      40 = 25 MHz  Genesys2)
    localparam WAIT_CYCLES = 150;   // pipeline run cycles after reset
    localparam TIMEOUT_NS  = 50000; // watchdog (ns)

    reg        clk;
    reg        rst;
    wire [7:0] led_out;

    RISCV_Top dut (
        .clk    (clk),
        .rst    (rst),
        .led_out(led_out)
    );

    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    `define RF dut.Decode.rf.Reg

    integer pass_count, fail_count;

    task check_reg;
        input [4:0]       reg_num;
        input [31:0]      expected;
        input [8*40-1:0]  test_name;
        reg   [31:0]      actual;
        begin
            actual = `RF[reg_num];
            if (actual === expected) begin
                $display("PASS: %-40s | x%-2d = 0x%08h",
                         test_name, reg_num, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %-40s | x%-2d = 0x%08h  (expected 0x%08h)",
                         test_name, reg_num, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("============================================================");
        $display("  RISC-V RV32IMC Pipeline - Functional Verification");
        $display("  CLK = %0d ns | Run = %0d cycles after reset",
                 CLK_PERIOD, WAIT_CYCLES);
        $display("============================================================");

        rst = 1'b1;
        repeat (5) @(posedge clk);
        #2;
        rst = 1'b0;
        $display("Reset released at time %0t ns\n", $time);

        repeat (WAIT_CYCLES) @(posedge clk);

        $display("[REGISTER CHECKS - RV32I]");
        check_reg(5'd1,  32'h0000000A,  "addi x1,  x0, 10");
        check_reg(5'd2,  32'h00000014,  "addi x2,  x0, 20");
        check_reg(5'd3,  32'h0000001E,  "add  x3,  x1, x2  -> 30");
        check_reg(5'd4,  32'hFFFFFFF6,  "sub  x4,  x1, x2  -> -10");
        check_reg(5'd6,  32'h00000000,  "and  x6,  x1, x2  -> 0");
        check_reg(5'd7,  32'h0000001E,  "or   x7,  x1, x2  -> 30");
        check_reg(5'd13, 32'h12345000,  "lui  x13, 0x12345");
        check_reg(5'd21, 32'h0000000A,  "bne taken -> addi x21, x0, 10");
        check_reg(5'd30, 32'h00000060,  "jal  x30, +8  -> link=0x60");
        check_reg(5'd22, 32'h0000000C,  "jal  target: addi x22, x0, 12");
        check_reg(5'd29, 32'h0000006C,  "jalr x29, 16(x30) -> link=0x6C");
        check_reg(5'd23, 32'h0000000D,  "jalr target: addi x23, x0, 13");

        $display("\n[REGISTER CHECKS - RV32M]");
        check_reg(5'd5,  32'h000000C8,  "mul  x5,  x1, x2  -> 200");
        check_reg(5'd8,  32'h00000002,  "div  x8,  x2, x1  -> 2");
        check_reg(5'd9,  32'h0000000A,  "rem  x9,  x3, x2  -> 10");

        $display("\n[REGISTER CHECKS - RV32C]");
        check_reg(5'd11, 32'h00000008,  "C.LI  x11, 8");
        check_reg(5'd16, 32'h00000010,  "C.LI  x16, 16");
        check_reg(5'd17, 32'h00000001,  "C.LI  x17, 1");
        check_reg(5'd18, 32'h00000010,  "C.MV  x18, x16  -> 16");

        check_reg(5'd15, 32'h00000001,  "C.ADDI x15, 1");

        $display("\n============================================================");
        $display("  PASSED : %0d", pass_count);
        $display("  FAILED : %0d", fail_count);
        if (fail_count == 0)
            $display("  RESULT : ALL TESTS PASSED SUCCESSFULLY");
        else
            $display("  RESULT : SIMULATION FAILED WITH %0d ERROR(S)", fail_count);
        $display("============================================================");

        $finish;
    end

    initial begin
        #(TIMEOUT_NS);
        $display("ERROR: Simulation timeout at %0t ns", $time);
        $finish;
    end

    initial begin
        $dumpfile("riscv_pipeline_tb.vcd");
        $dumpvars(0, RISCV_Testbench);
    end

endmodule