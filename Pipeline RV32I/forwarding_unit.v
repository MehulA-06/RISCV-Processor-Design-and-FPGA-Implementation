`timescale 1ns / 1ps
module forwarding_unit (
    input [4:0] RS1_E, RS2_E,
    input [4:0] RD_M, RDW,
    input RegWriteM, RegWriteW,
    output reg [1:0] ForwardA_E,
    output reg [1:0] ForwardB_E
);

always @(*) begin
    // Default to no forwarding
    ForwardA_E = 2'b00;
    ForwardB_E = 2'b00;

    // Forward A (RS1_E)
    // EX/MEM hazard: RD_M == RS1_E and RD_M is a valid destination
    if (RegWriteM && (RD_M != 5'b0) && (RD_M == RS1_E)) begin
        ForwardA_E = 2'b10; // Forward from EX/MEM stage
    end
    // MEM/WB hazard: RDW == RS1_E and RDW is a valid destination
    else if (RegWriteW && (RDW != 5'b0) && (RDW == RS1_E)) begin
        ForwardA_E = 2'b01; // Forward from MEM/WB stage
    end

    // Forward B (RS2_E)
    // EX/MEM hazard: RD_M == RS2_E and RD_M is a valid destination
    if (RegWriteM && (RD_M != 5'b0) && (RD_M == RS2_E)) begin
        ForwardB_E = 2'b10; // Forward from EX/MEM stage
    end
    // MEM/WB hazard: RDW == RS2_E and RDW is a valid destination
    else if (RegWriteW && (RDW != 5'b0) && (RDW == RS2_E)) begin
        ForwardB_E = 2'b01; // Forward from MEM/WB stage
    end
end

endmodule
