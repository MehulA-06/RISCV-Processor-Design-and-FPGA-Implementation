`timescale 1ns / 1ps

module Data_memory(
    input clk,
    input MemWrite,          
    input [1:0] size,        
    input sign_ext,          
    input [31:0] A,          
    input [31:0] Wd,         
    output reg [31:0] Rd     
);
    (* ram_style="block" *)
    reg [31:0] memory [0:255];  // byte-addressable memory

    wire [7:0] byte_addr;
    wire [7:0] aligned_addr;

    assign byte_addr   = A[7:0];
    assign aligned_addr = {A[7:2],2'b00};   

    // READ 
    always @(*) begin
        if(!MemWrite) begin
            case(size)

                // BYTE 
                2'b00: begin
                    if(sign_ext)
                        Rd = {{24{memory[byte_addr][7]}}, memory[byte_addr]};
                    else
                        Rd = {24'b0, memory[byte_addr]};
                end

                //  HALFWORD
                2'b01: begin
                    if(sign_ext)
                        Rd = {{16{memory[byte_addr+1][7]}},
                               memory[byte_addr+1], memory[byte_addr]};
                    else
                        Rd = {16'b0,
                               memory[byte_addr+1], memory[byte_addr]};
                end

                //  WORD 
                2'b10: begin
                    Rd = {memory[aligned_addr+3],
                          memory[aligned_addr+2],
                          memory[aligned_addr+1],
                          memory[aligned_addr]};
                end

                default: Rd = 32'b0;
            endcase
        end
        else
            Rd = 32'b0;
    end


    // WRITE
    always @(posedge clk) begin
        if(MemWrite) begin
            case(size)

                // store byte (SB)
                2'b00: memory[byte_addr] <= Wd[7:0];

                // store halfword (SH)
                2'b01: begin
                    memory[byte_addr]   <= Wd[7:0];
                    memory[byte_addr+1] <= Wd[15:8];
                end

                // store word (SW)
                2'b10: begin
                    memory[aligned_addr]   <= Wd[7:0];
                    memory[aligned_addr+1] <= Wd[15:8];
                    memory[aligned_addr+2] <= Wd[23:16];
                    memory[aligned_addr+3] <= Wd[31:24];
                end

            endcase
        end
    end

endmodule