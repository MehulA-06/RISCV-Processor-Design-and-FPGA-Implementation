module ALU_decoder(

    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] ALUControl
);

    always @(*) begin
        case(ALUOp)
            2'b00: ALUControl = 4'b0000; // ADD (Load/Store/Jumps)
            2'b01: ALUControl = 4'b0001; // SUB (Branch)
            2'b10: begin // R-type & I-type
                case(funct3)
                    3'b000: begin
                        if (funct7[5]) ALUControl = 4'b0001; // SUB
                        else ALUControl = 4'b0000;           // ADD
                    end
                    3'b001: ALUControl = 4'b0101; //SLL
                    3'b110: ALUControl = 4'b0011; // OR
                    3'b111: ALUControl = 4'b0010; // AND
                    3'b010: ALUControl = 4'b1000; // SLT
                    default: ALUControl = 4'b0000;
                endcase
            end
            2'b11: ALUControl = 4'b1010; // Pass B (LUI)
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule