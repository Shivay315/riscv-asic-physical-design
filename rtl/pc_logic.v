`timescale 1ns / 1ps
module pc_logic(input clk,input StallF,input PCSrcE,
output reg [31:0]PCF,input[31:0] PCTargetE
,input rst ,input mret_redirect,input [31:0] mepc,input trap_redirect,
input [31:0] mtvec
    );
    always @(posedge clk)begin
    if (rst )begin
    PCF <= 32'h80000000;
    end else if (trap_redirect)
    PCF <= mtvec;
    else if (mret_redirect)
    PCF <= mepc;
    else if(~StallF)begin
    if (PCSrcE)
    PCF <= PCTargetE;
    else
    PCF <= PCF+4;
    end
    end
endmodule
