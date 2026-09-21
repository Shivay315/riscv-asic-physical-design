`timescale 1ns / 1ps

module branch_target (
    input  [31:0] PCE,
    input  [31:0] ImmExtE,
    output [31:0] PCTargetE,
    input [31:0]ALUResultE,
    input Branch_Target_selE
);
    
    assign PCTargetE = (Branch_Target_selE) ? (PCE + ImmExtE) : (ALUResultE & ~32'h1);
endmodule
