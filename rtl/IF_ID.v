`timescale 1ns / 1ps
module IF_ID(input StallD,input FlushD,input clk,input [31:0]PCF,
input [31:0]PCPlus4F,input Valid_F,
input[31:0] InstrF,output
reg [31:0]InstrD,output reg[31:0]PCD,output reg[31:0] PCPlus4D,input rst,output reg Valid_D

    );
    always@(posedge clk )begin
    if (rst)begin
    PCD <= 32'b0;
    PCPlus4D <= 32'b0;
    InstrD <= 32'h00000013;
    Valid_D <= 1'b0;
    end
    else if (FlushD)begin
    PCD <= 32'b0;
    PCPlus4D <= 32'b0;
    InstrD <= 32'h00000013;
    Valid_D <= 1'b0;
    end
    else if (~StallD)begin
    PCD <= PCF;
    PCPlus4D <= PCPlus4F;
    InstrD<=InstrF;
    Valid_D <= Valid_F;
    end
    end
endmodule
