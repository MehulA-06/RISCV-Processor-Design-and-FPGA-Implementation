`timescale 1ns / 1ps

module MulDiv (
    input  [31:0] SrcA,
    input  [31:0] SrcB,
    input  [2:0]  funct3,   
    output reg [31:0] Result
);

    // --- Multiply products (64-bit, three flavours) ---
    wire signed [63:0] prod_ss;   // signed   × signed
    wire        [63:0] prod_uu;   // unsigned × unsigned
    wire signed [63:0] prod_su;   // signed   × unsigned (MULHSU)

    assign prod_ss = $signed(SrcA) * $signed(SrcB);
    assign prod_uu = {32'b0, SrcA} * {32'b0, SrcB};  // zero-extend ? no sign confusion
    assign prod_su = $signed(SrcA) * $signed({1'b0, SrcB});

    // --- Division / remainder with RISC-V corner cases ---
    wire div_by_zero   = (SrcB == 32'b0);
    wire overflow      = (SrcA == 32'h80000000) && (SrcB == 32'hFFFFFFFF);

    always @(*) begin
        case (funct3)
            // ---- Multiply ----
            3'b000: Result = prod_ss[31:0];       // MUL
            3'b001: Result = prod_ss[63:32];      // MULH
            3'b010: Result = prod_su[63:32];      // MULHSU
            3'b011: Result = prod_uu[63:32];      // MULHU

            // ---- Divide ----
            3'b100: Result = div_by_zero ? 32'hFFFFFFFF :   // DIV
                             overflow    ? 32'h80000000 :
                             $signed(SrcA) / $signed(SrcB);

            3'b101: Result = div_by_zero ? 32'hFFFFFFFF :   // DIVU
                             SrcA / SrcB;

            // ---- Remainder ----
            3'b110: Result = div_by_zero ? SrcA :           // REM
                             overflow    ? 32'h00000000 :
                             $signed(SrcA) % $signed(SrcB);

            3'b111: Result = div_by_zero ? SrcA :           // REMU
                             SrcA % SrcB;

            default: Result = 32'b0;
        endcase
    end

endmodule
