`timescale 1ns / 1ps

module RISCV_Top(
`ifdef SYNTHESIS
    input        sys_clk_p,
    input        sys_clk_n,
`else
    input        clk,           // simulation clock
`endif
    input        rst,
    output reg [7:0] led_out   // CHANGED: reg for procedural assignment
);

    wire clk_int;

`ifdef SYNTHESIS

    wire clk_200_ibuf;
    IBUFDS #(
        .DIFF_TERM   ("FALSE"),
        .IBUF_LOW_PWR("TRUE")
    ) clk_buf (
        .O  (clk_200_ibuf),
        .I  (sys_clk_p),
        .IB (sys_clk_n)
    );

    wire clk_25_unbuf;
    wire clk_fb_out, clk_fb_in;
    wire mmcm_locked;

    MMCME2_BASE #(
        .CLKIN1_PERIOD     (5.0),    // 200 MHz input ? 5 ns period
        .CLKFBOUT_MULT_F   (5.0),    // VCO = 1000 MHz
        .DIVCLK_DIVIDE     (1),
        .CLKOUT0_DIVIDE_F  (40.0),   // CLKOUT0 = 25 MHz
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT0_PHASE     (0.0),
        .BANDWIDTH         ("OPTIMIZED"),
        .CLKFBOUT_PHASE    (0.0),
        .REF_JITTER1       (0.0),
        .STARTUP_WAIT      ("FALSE")
    ) mmcm_inst (
        .CLKIN1   (clk_200_ibuf),
        .CLKFBIN  (clk_fb_in),
        .CLKOUT0  (clk_25_unbuf),
        .CLKFBOUT (clk_fb_out),
        .LOCKED   (mmcm_locked),
        .PWRDWN   (1'b0),
        .RST      (1'b0)          // MMCM self-manages reset; tie low
    );

    // 3. Global buffer on the feedback path (mandatory for MMCME2_BASE)
    BUFG fb_bufg (
        .I (clk_fb_out),
        .O (clk_fb_in)
    );

    // 4. Global buffer on the 25 MHz output
    BUFG clk_bufg (
        .I (clk_25_unbuf),
        .O (clk_int)
    );

`else
    // Simulation: pass-through
    assign clk_int     = clk;
    wire   mmcm_locked = 1'b1;  // always locked in simulation
`endif

    reg rst_sync_0, rst_sync_1;
    wire rst_int = rst_sync_1;   // active-high, synchronous to clk_int

    always @(posedge clk_int or posedge rst) begin
        if (rst) begin
            rst_sync_0 <= 1'b1;
            rst_sync_1 <= 1'b1;
        end else begin
            rst_sync_0 <= ~mmcm_locked;   // deassert only when MMCM locked
            rst_sync_1 <= rst_sync_0;
        end
    end

    wire PCSrcE, FlushE, FlushD, StallF, StallD;
    wire RegWriteW, RegWriteE, ALUSrcE, MemWriteE, BranchE, JumpE;
    wire RegWriteM, MemWriteM;
    wire [1:0] ResultSrcM, ResultSrcW;
    wire [1:0] ResultSrcE;
    wire [2:0] Funct3_E, Funct3_M;
    wire [3:0] ALUControlE;
    wire [4:0] RD_E, RD_M, RDW;
    wire [31:0] PCTargetE, InstrD, PCD, PCPlus4D, ResultW;
    wire [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E;
    wire [31:0] PCPlus4M, WriteDataM, ALU_ResultM;
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;
    wire [4:0]  RS1_E, RS2_E;
    wire [1:0]  ForwardAE, ForwardBE;
    wire        IsMExtE;

    reg [31:0] captured [0:19];  // stores first 20 write-back results
    reg [4:0]  cap_idx;          // how many values captured so far (0-20)
    reg [4:0]  show_idx;         // which captured value is on LEDs
    reg [24:0] led_cnt;          // 25-bit counter (max 33 554 431 > 24 999 999)
    reg        show_mode;        // 0=capturing, 1=displaying

    always @(posedge clk_int or posedge rst) begin
        if (rst) begin
            cap_idx   <= 5'd0;
            show_idx  <= 5'd0;
            led_cnt   <= 25'd0;
            show_mode <= 1'b0;
            led_out   <= 8'b0;
        end else begin

            if (!show_mode) begin
                // ---- Capture phase ----
                // Record every non-x0 write-back until we have 20 results
                if (RegWriteW && (RDW != 5'd0) && (cap_idx < 5'd20)) begin
                    captured[cap_idx] <= ResultW;
                    cap_idx <= cap_idx + 5'd1;
                end

                // Switch to display mode once all 20 writes are captured
                if (cap_idx == 5'd20) begin
                    show_mode <= 1'b1;
                    show_idx  <= 5'd0;
                    led_cnt   <= 25'd0;
                    led_out   <= captured[0][7:0];
                end

            end else begin
                if (led_cnt == 25'd49_999_999) begin
                    led_cnt <= 25'd0;

                    if (show_idx == 5'd19)
                        show_idx <= 5'd0;
                    else
                        show_idx <= show_idx + 5'd1;

                    led_out <= captured[show_idx][7:0];
                end else begin
                    led_cnt <= led_cnt + 25'd1;
                end
            end

        end
    end

    fetch_cycle Fetch (
        .clk       (clk_int),
        .rst       (rst_int),
        .PCSrcE    (PCSrcE),
        .PCTargetE (PCTargetE),
        .StallF    (StallF),
        .StallD    (StallD),
        .FlushD    (FlushD),
        .InstrD    (InstrD),
        .PCD       (PCD),
        .PCPlus4D  (PCPlus4D)
    );

    decode_cycle Decode (
        .clk        (clk_int),
        .rst        (rst_int),
        .InstrD     (InstrD),
        .PCD        (PCD),
        .PCPlus4D   (PCPlus4D),
        .RegWriteW  (RegWriteW),
        .RDW        (RDW),
        .ResultW    (ResultW),
        .FlushE     (FlushE),
        .RegWriteE  (RegWriteE),
        .ALUSrcE    (ALUSrcE),
        .MemWriteE  (MemWriteE),
        .ResultSrcE (ResultSrcE),
        .BranchE    (BranchE),
        .JumpE      (JumpE),
        .ALUControlE(ALUControlE),
        .RD1_E      (RD1_E),
        .RD2_E      (RD2_E),
        .Imm_Ext_E  (Imm_Ext_E),
        .RD_E       (RD_E),
        .PCE        (PCE),
        .PCPlus4E   (PCPlus4E),
        .RS1_E      (RS1_E),
        .RS2_E      (RS2_E),
        .Funct3_E   (Funct3_E),
        .IsMExtE    (IsMExtE)
    );

    execute_cycle Execute (
        .clk           (clk_int),
        .rst           (rst_int),
        .RegWriteE     (RegWriteE),
        .ALUSrcE       (ALUSrcE),
        .MemWriteE     (MemWriteE),
        .ResultSrcE    (ResultSrcE),
        .BranchE       (BranchE),
        .JumpE         (JumpE),
        .ALUControlE   (ALUControlE),
        .Funct3_E      (Funct3_E),
        .RD1_E         (RD1_E),
        .RD2_E         (RD2_E),
        .Imm_Ext_E     (Imm_Ext_E),
        .RD_E          (RD_E),
        .PCE           (PCE),
        .PCPlus4E      (PCPlus4E),
        .PCSrcE        (PCSrcE),
        .PCTargetE     (PCTargetE),
        .RegWriteM     (RegWriteM),
        .MemWriteM     (MemWriteM),
        .ResultSrcM    (ResultSrcM),
        .RD_M          (RD_M),
        .PCPlus4M      (PCPlus4M),
        .WriteDataM    (WriteDataM),
        .ALU_ResultM_out(ALU_ResultM),
        .ResultW       (ResultW),
        .ForwardA_E    (ForwardAE),
        .ForwardB_E    (ForwardBE),
        .Funct3_M      (Funct3_M),
        .IsMExtE       (IsMExtE)
    );

    memory_cycle Memory (
        .clk        (clk_int),
        .rst        (rst_int),
        .RegWriteM  (RegWriteM),
        .MemWriteM  (MemWriteM),
        .ResultSrcM (ResultSrcM),
        .RD_M       (RD_M),
        .PCPlus4M   (PCPlus4M),
        .WriteDataM (WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .Funct3_M   (Funct3_M),
        .RegWriteW  (RegWriteW),
        .ResultSrcW (ResultSrcW),
        .RD_W       (RDW),
        .PCPlus4W   (PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW  (ReadDataW)
    );

    writeback_cycle WriteBack (
        .ResultSrcW  (ResultSrcW),
        .PCPlus4W    (PCPlus4W),
        .ALU_ResultW (ALU_ResultW),
        .ReadDataW   (ReadDataW),
        .ResultW     (ResultW)
    );

    forwarding_unit Forwarding_block (
        .RegWriteM (RegWriteM),
        .RegWriteW (RegWriteW),
        .RD_M      (RD_M),
        .RDW       (RDW),
        .RS1_E     (RS1_E),
        .RS2_E     (RS2_E),
        .ForwardA_E(ForwardAE),
        .ForwardB_E(ForwardBE)
    );

    hazard_unit HazardUnit (
        .RS1_D     (InstrD[19:15]),
        .RS2_D     (InstrD[24:20]),
        .RD_E      (RD_E),
        .ResultSrcE(ResultSrcE),
        .PCSrcE    (PCSrcE),
        .StallF    (StallF),
        .StallD    (StallD),
        .FlushE    (FlushE),
        .FlushD    (FlushD)
    );

endmodule