`timescale 1ns / 1ps
module hazard_unit(input [4:0]Rs1E,input [4:0]Rs2E, input [4:0]Rs1D,input [4:0]Rs2D,
input ResultSrcE0,
input RegWriteW, input RegWriteM,input [4:0]RdW,input [4:0]RdM,input [4:0]RdE ,input PCSrcE,input mret_redirect,input trap_take,
output reg StallF,output reg StallD,output reg FlushD,
output reg FlushE, output reg [1:0]ForwardAE,output reg [1:0]ForwardBE


    );
    reg lwstall;
    
    

    always@(*)begin
    if ((Rs1E == RdM) && RegWriteM && (Rs1E != 0))begin
    ForwardAE = 2'b10;
    end else if (((Rs1E == RdW)&RegWriteW)&(Rs1E != 0))begin
    ForwardAE = 2'b01;
    end else begin 
    ForwardAE = 2'b00;
    end
    if ((Rs2E == RdM) && RegWriteM  && (Rs2E != 0))begin
    ForwardBE = 2'b10;
    end else if (((Rs2E == RdW)&RegWriteW)&(Rs2E != 0))begin
    ForwardBE = 2'b01;
    end else begin 
    ForwardBE = 2'b00;
    end
    lwstall = (ResultSrcE0 & ((Rs1D == RdE) | (Rs2D == RdE)) & (RdE != 0));
    if(lwstall & ~trap_take & ~mret_redirect)begin
    StallF = 1'b1;
    StallD = 1'b1;
    end else begin
    StallF = 1'b0;
    StallD = 1'b0;
    end
    FlushD = PCSrcE|mret_redirect|trap_take;
    FlushE = PCSrcE|lwstall|mret_redirect|trap_take;
    end
endmodule


