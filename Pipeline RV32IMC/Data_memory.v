`timescale 1ns / 1ps

module Data_memory(
    input             clk,
    input             rst,
    input             MemWrite,
    input      [1:0]  size,      // 00: Byte, 01: Half, 10: Word
    input             sign_ext,  // 1: Signed, 0: Unsigned
    input      [31:0] A,         // Address
    input      [31:0] Wd,        // Write Data
    output reg [31:0] Rd         // Read Data
);

    (* ram_style = "block" *) reg [31:0] memory [0:255];

    wire [7:0] word_idx = A[9:2]; // Word index (0-255)
    wire [1:0] byte_off = A[1:0]; // Offset within the word
  
    reg [31:0] raw_word;

    integer i;
    initial begin
        for(i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000000;
    end

    always @(posedge clk) begin

        if (MemWrite) begin
            case(size)
                2'b00: begin // SB (Store Byte)
                    if      (byte_off == 2'b00) memory[word_idx][7:0]   <= Wd[7:0];
                    else if (byte_off == 2'b01) memory[word_idx][15:8]  <= Wd[7:0];
                    else if (byte_off == 2'b10) memory[word_idx][23:16] <= Wd[7:0];
                    else                        memory[word_idx][31:24] <= Wd[7:0];
                end
                2'b01: begin // SH (Store Halfword)
                    if (byte_off[1] == 1'b0) memory[word_idx][15:0]  <= Wd[15:0];
                    else                     memory[word_idx][31:16] <= Wd[15:0];
                end
                2'b10: begin // SW (Store Word)
                    memory[word_idx] <= Wd;
                end
            endcase
        end

        raw_word <= memory[word_idx];
    end

    always @(*) begin
        case(size)
            2'b00: begin // LB / LBU
                case(byte_off)
                    2'b00: Rd = (sign_ext) ? {{24{raw_word[7]}},  raw_word[7:0]}   : {24'b0, raw_word[7:0]};
                    2'b01: Rd = (sign_ext) ? {{24{raw_word[15]}}, raw_word[15:8]}  : {24'b0, raw_word[15:8]};
                    2'b10: Rd = (sign_ext) ? {{24{raw_word[23]}}, raw_word[23:16]} : {24'b0, raw_word[23:16]};
                    2'b11: Rd = (sign_ext) ? {{24{raw_word[31]}}, raw_word[31:24]} : {24'b0, raw_word[31:24]};
                endcase
            end
            2'b01: begin // LH / LHU
                if (byte_off[1] == 1'b0)
                    Rd = (sign_ext) ? {{16{raw_word[15]}}, raw_word[15:0]} : {16'b0, raw_word[15:0]};
                else
                    Rd = (sign_ext) ? {{16{raw_word[31]}}, raw_word[31:16]} : {16'b0, raw_word[31:16]};
            end
            2'b10: begin // LW
                Rd = raw_word;
            end
            default: Rd = 32'b0;
        endcase
    end

endmodule