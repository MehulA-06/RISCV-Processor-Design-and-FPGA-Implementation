`timescale 1ns / 1ps
module Decompressor (
    input  [15:0] c_instr,   // 16-bit compressed instruction
    output reg [31:0] instr32 // semantically-equivalent 32-bit instruction
);

 
    wire [1:0] op     = c_instr[1:0];   
    wire [2:0] funct3 = c_instr[15:13];  
    wire [4:0] rd_p  = {2'b01, c_instr[4:2]};  // destination (prime)
    wire [4:0] rs1_p = {2'b01, c_instr[9:7]};  // source-1   (prime)
    wire [4:0] rs2_p = {2'b01, c_instr[4:2]};  // source-2   (prime) - same bits as rd_p


    wire [4:0] rd_full  = c_instr[11:7];
    wire [4:0] rs2_full = c_instr[6:2];

    wire [11:0] addi4spn_imm = {2'b00,
                                 c_instr[10:7],   // nzuimm[9:6]
                                 c_instr[12:11],  // nzuimm[5:4]
                                 c_instr[5],      // nzuimm[3]
                                 c_instr[6],      // nzuimm[2]
                                 2'b00};          // nzuimm[1:0] = 0

    wire [11:0] lw_imm    = {5'b0,
                              c_instr[5],      // uimm[6]
                              c_instr[12:10],  // uimm[5:3]
                              c_instr[6],      // uimm[2]
                              2'b00};          // uimm[1:0] = 0

    wire [6:0]  sw_imm_hi = {5'b0, c_instr[5], c_instr[12]}; // imm[11:5]
    wire [4:0]  sw_imm_lo = {c_instr[11:10], c_instr[6], 2'b00}; // imm[4:0]

    wire [11:0] addi_imm = {{6{c_instr[12]}}, c_instr[12], c_instr[6:2]};

    wire [11:0] addi16sp_imm = {{2{c_instr[12]}},
                                  c_instr[12],    // nzimm[9]
                                  c_instr[4:3],   // nzimm[8:7]
                                  c_instr[5],     // nzimm[6]
                                  c_instr[2],     // nzimm[5]
                                  c_instr[6],     // nzimm[4]
                                  4'b0000};       // nzimm[3:0] = 0

    wire [19:0] lui_imm = {{14{c_instr[12]}}, c_instr[12], c_instr[6:2]};

    wire [4:0] shamt = c_instr[6:2];
    wire [20:0] j_imm = {{9{c_instr[12]}},   // imm[20:12] - sign extension
                           c_instr[12],        // imm[11]
                           c_instr[8],         // imm[10]
                           c_instr[10:9],      // imm[9:8]
                           c_instr[6],         // imm[7]
                           c_instr[7],         // imm[6]
                           c_instr[2],         // imm[5]
                           c_instr[11],        // imm[4]
                           c_instr[5:3],       // imm[3:1]
                           1'b0};              // imm[0] = 0 (always)


    wire [12:0] b_imm = {{4{c_instr[12]}},  // imm[12:9] - sign extension
                           c_instr[12],      // imm[8]
                           c_instr[6:5],     // imm[7:6]
                           c_instr[2],       // imm[5]
                           c_instr[11:10],   // imm[4:3]
                           c_instr[4:3],     // imm[2:1]
                           1'b0};            // imm[0] = 0 (always)


    wire [11:0] lwsp_imm = {4'b0,
                             c_instr[3:2],  // uimm[7:6]
                             c_instr[12],   // uimm[5]
                             c_instr[6:4],  // uimm[4:2]
                             2'b00};        // uimm[1:0] = 0

    wire [6:0]  swsp_imm_hi = {4'b0, c_instr[8:7], c_instr[12]};  // imm[11:5]
    wire [4:0]  swsp_imm_lo = {c_instr[11:9], 2'b00};              // imm[4:0]


    always @(*) begin
        instr32 = 32'h00000013; // safe default = NOP (addi x0, x0, 0)

        case (op)

            2'b00: begin
                case (funct3)

                    3'b000: instr32 = {addi4spn_imm,       // imm[11:0]
                                        5'd2,               // rs1 = x2 (sp)
                                        3'b000,             // funct3 = ADDI
                                        rd_p,               // rd = x8-x15
                                        7'b0010011};        // I-type ALU opcode

                    3'b010: instr32 = {lw_imm,             // imm[11:0]
                                        rs1_p,              // rs1 = x8-x15
                                        3'b010,             // funct3 = LW
                                        rd_p,               // rd  = x8-x15
                                        7'b0000011};        // Load opcode

                    3'b110: instr32 = {sw_imm_hi,          // imm[11:5]
                                        rs2_p,              // rs2 = x8-x15
                                        rs1_p,              // rs1 = x8-x15
                                        3'b010,             // funct3 = SW
                                        sw_imm_lo,          // imm[4:0]
                                        7'b0100011};        // Store opcode

                    default: instr32 = 32'h00000013; // reserved/illegal ? NOP
                endcase
            end

            2'b01: begin
                case (funct3)

                    3'b000: instr32 = {addi_imm,           // imm[11:0] (sign-ext)
                                        rd_full,            // rs1 = rd (in-place add)
                                        3'b000,             // funct3 = ADDI
                                        rd_full,            // rd
                                        7'b0010011};        // I-type ALU opcode

                    3'b001: instr32 = {j_imm[20],          // imm[20]
                                        j_imm[10:1],        // imm[10:1]
                                        j_imm[11],          // imm[11]
                                        j_imm[19:12],       // imm[19:12]
                                        5'd1,               // rd = x1 (ra)
                                        7'b1101111};        // JAL opcode

                    3'b010: instr32 = {addi_imm,           // imm[11:0] (sign-ext)
                                        5'd0,               // rs1 = x0
                                        3'b000,             // funct3 = ADDI
                                        rd_full,            // rd
                                        7'b0010011};        // I-type ALU opcode

                    3'b011: begin
                        if (rd_full == 5'd2)
                            
                            instr32 = {addi16sp_imm,       // imm[11:0] (sign-ext)
                                        5'd2,               // rs1 = x2 (sp)
                                        3'b000,             // funct3 = ADDI
                                        5'd2,               // rd  = x2 (sp)
                                        7'b0010011};        // I-type ALU opcode
                        else
                            // Load upper immediate into rd
                            instr32 = {lui_imm,             // imm[31:12] (sign-ext 20b)
                                        rd_full,            // rd
                                        7'b0110111};        // LUI opcode
                    end

                    3'b100: begin
                        case (c_instr[11:10])

                            2'b00: instr32 = {7'b0000000,
                                               shamt,       // shamt[4:0]
                                               rs1_p,       // rs1 = rd' = x8-x15
                                               3'b101,      // funct3 = SRL/SRA
                                               rs1_p,       // rd  = rd'
                                               7'b0010011}; // I-type ALU opcode

                            2'b01: instr32 = {7'b0100000,
                                               shamt,
                                               rs1_p,
                                               3'b101,
                                               rs1_p,
                                               7'b0010011};

                            2'b10: instr32 = {addi_imm,    // re-use addi_imm (same bits)
                                               rs1_p,       // rs1 = rd'
                                               3'b111,      // funct3 = AND
                                               rs1_p,       // rd  = rd'
                                               7'b0010011};

                            2'b11: begin
                                case (c_instr[6:5])
                                   
                                    2'b00: instr32 = {7'b0100000,
                                                       rs2_p,   // rs2 = x8-x15
                                                       rs1_p,   // rs1 = rd'
                                                       3'b000,  // funct3 = SUB
                                                       rs1_p,   // rd  = rd'
                                                       7'b0110011};  // R-type opcode
                                  
                                    2'b01: instr32 = {7'b0000000,
                                                       rs2_p,
                                                       rs1_p,
                                                       3'b100,  // funct3 = XOR
                                                       rs1_p,
                                                       7'b0110011};

                                 
                                    2'b10: instr32 = {7'b0000000,
                                                       rs2_p,
                                                       rs1_p,
                                                       3'b110,  // funct3 = OR
                                                       rs1_p,
                                                       7'b0110011};

                                    2'b11: instr32 = {7'b0000000,
                                                       rs2_p,
                                                       rs1_p,
                                                       3'b111,  // funct3 = AND
                                                       rs1_p,
                                                       7'b0110011};
                                endcase
                            end
                        endcase
                    end

                    3'b101: instr32 = {j_imm[20],
                                        j_imm[10:1],
                                        j_imm[11],
                                        j_imm[19:12],
                                        5'd0,               // rd = x0 (no link)
                                        7'b1101111};        // JAL opcode

                    3'b110: instr32 = {b_imm[12],
                                        b_imm[10:5],
                                        5'b00000,           // rs2 = x0
                                        rs1_p,              // rs1 = x8-x15
                                        3'b000,             // funct3 = BEQ
                                        b_imm[4:1],
                                        b_imm[11],
                                        7'b1100011};        // Branch opcode

                    3'b111: instr32 = {b_imm[12],
                                        b_imm[10:5],
                                        5'b00000,           // rs2 = x0
                                        rs1_p,
                                        3'b001,             // funct3 = BNE
                                        b_imm[4:1],
                                        b_imm[11],
                                        7'b1100011};

                    default: instr32 = 32'h00000013;
                endcase
            end

            2'b10: begin
                case (funct3)

                    // C.SLLI ? slli rd, rd, shamt
                    3'b000: instr32 = {7'b0000000,
                                        shamt,
                                        rd_full,            // rs1 = rd
                                        3'b001,             // funct3 = SLL
                                        rd_full,            // rd
                                        7'b0010011};        // I-type ALU opcode

                    3'b010: instr32 = {lwsp_imm,
                                        5'd2,               // rs1 = x2 (sp)
                                        3'b010,             // funct3 = LW
                                        rd_full,            // rd
                                        7'b0000011};        // Load opcode
                    3'b100: begin
                        if (!c_instr[12]) begin
                            if (rs2_full == 5'd0)
                               
                                instr32 = {12'b0,           // imm = 0
                                            rd_full,        // rs1 (source register)
                                            3'b000,
                                            5'd0,           // rd = x0 (no link)
                                            7'b1100111};    // JALR opcode
                            else
                            
                                instr32 = {7'b0000000,
                                            rs2_full,       // rs2
                                            5'd0,           // rs1 = x0
                                            3'b000,         // funct3 = ADD
                                            rd_full,        // rd
                                            7'b0110011};    // R-type opcode
                        end else begin
                            if (rs2_full == 5'd0)
                             
                                instr32 = {12'b0,
                                            rd_full,        // rs1
                                            3'b000,
                                            5'd1,           // rd = x1 (ra)
                                            7'b1100111};    // JALR opcode
                            else
                             
                                instr32 = {7'b0000000,
                                            rs2_full,       // rs2
                                            rd_full,        // rs1 = rd (in-place)
                                            3'b000,         // funct3 = ADD
                                            rd_full,        // rd
                                            7'b0110011};    // R-type opcode
                        end
                    end

                    3'b110: instr32 = {swsp_imm_hi,        // imm[11:5]
                                        rs2_full,           // rs2 (data to store)
                                        5'd2,               // rs1 = x2 (sp)
                                        3'b010,             // funct3 = SW
                                        swsp_imm_lo,        // imm[4:0]
                                        7'b0100011};        // Store opcode

                    default: instr32 = 32'h00000013;
                endcase
            end

            default: instr32 = 32'h00000013;

        endcase
    end

endmodule