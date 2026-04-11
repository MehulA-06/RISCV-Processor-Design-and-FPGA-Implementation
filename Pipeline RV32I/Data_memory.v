`timescale 1ns / 1ps
module Data_memory(
    input clk,
    input rst,
    input MemWrite,
    input [1:0] size,
    input sign_ext,
    input [31:0] A,
    input [31:0] Wd,
    output reg [31:0] Rd
);

(* ram_style="block" *)
reg [7:0] memory [0:1023]; // Byte-addressable memory, 1024 bytes (256 words * 4 bytes/word)

// Internal signals for byte addressing
wire [9:0] byte_addr; // Address for byte memory
wire [9:0] word_addr; // Word-aligned address

assign byte_addr = A[9:0]; // Use lower bits for byte address
assign word_addr = {A[9:2], 2'b00}; // Word-aligned address

integer i;
initial begin
    for(i=0; i<1024; i=i+1)
        memory[i] = 8'h00; // Initialize data memory to 0
end

// READ Logic
always @(*) begin
    if(!MemWrite) begin
        case(size)
            // BYTE (LB, LBU)
            2'b00: begin
                if(sign_ext) // LB
                    Rd = {{24{memory[byte_addr][7]}}, memory[byte_addr]};
                else // LBU
                    Rd = {24'b0, memory[byte_addr]};
            end
            // HALFWORD (LH, LHU)
            2'b01: begin
                if(sign_ext) // LH
                    Rd = {{16{memory[byte_addr+1][7]}}, memory[byte_addr+1], memory[byte_addr]};
                else // LHU
                    Rd = {16'b0, memory[byte_addr+1], memory[byte_addr]};
            end
            // WORD (LW)
            2'b10: begin
                Rd = {memory[word_addr+3],
                      memory[word_addr+2],
                      memory[word_addr+1],
                      memory[word_addr]};
            end
            default: Rd = 32'b0;
        endcase
    end
    else
        Rd = 32'b0; // Output 0 during write operation
end

// WRITE Logic
always @(posedge clk) begin
    if(rst) begin
        // No specific reset for memory content, it's initialized once
    end
    else if(MemWrite) begin
        case(size)
            // store byte (SB)
            2'b00: memory[byte_addr] <= Wd[7:0];
            // store halfword (SH)
            2'b01: begin
                memory[byte_addr] <= Wd[7:0];
                memory[byte_addr+1] <= Wd[15:8];
            end
            // store word (SW)
            2'b10: begin
                memory[word_addr] <= Wd[7:0];
                memory[word_addr+1] <= Wd[15:8];
                memory[word_addr+2] <= Wd[23:16];
                memory[word_addr+3] <= Wd[31:24];
            end
            default: ;
        endcase
    end
end

endmodule
