`timescale 1ns / 1ps
module Register_file( input [4:0]A1,input [4:0] A2,input clk , input [31:0] ResultW , input [4:0] RdW,
input RegWriteW,output [31:0] RD1,output [31:0]RD2

    );
    reg [31:0] register [31:0];
    integer i;
    
    assign RD1 = (A1[4:0] == 0)?32'b0:register [A1[4:0]]; 
    assign RD2 = (A2[4:0] == 0)?32'b0:register [A2[4:0]];
    always@(negedge clk)begin
    if (RegWriteW && RdW != 0)
    register [RdW] <= ResultW;    
    end   
endmodule
