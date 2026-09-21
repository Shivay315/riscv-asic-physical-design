`timescale 1ns / 1ps 
module EX_MEM( 
input RegWriteE,
input Valid_E, 
input [1:0]ResultSrcE, 
input MemWriteE, 
input [31:0]ALUResultE, 
input [31:0]ImmExtE,
input [31:0]WriteDataE, 
input [4:0]RdE, 
input [31:0]PCPlus4E, 
input clk, 
input [1:0] ALUResultM_selE,
input [31:0] PCTargetE,
input [2:0]funct_3E,
input [31:0] PCE,
input [31:0] InstrE,
output reg Valid_M, 
output reg RegWriteM, 
output reg [1:0]ResultSrcM, 
output reg MemWriteM, 
output reg [31:0]ALUResultM, 
output reg [31:0]WriteDataM, 
output reg [4:0]RdM, 
output reg [31:0]PCPlus4M ,
output reg [2:0]funct_3M,
output reg [31:0] PCM,
output reg [31:0] InstrM,
input rst
    ); 
    always@(posedge clk)begin 
    if (rst)begin
    RegWriteM <= 1'b0; 
    ResultSrcM <= 2'b0; 
    MemWriteM <= 1'b0; 
    ALUResultM <= 32'b0; 
    WriteDataM <= 32'b0; 
    RdM <= 5'b0; 
    PCPlus4M <= 32'b0;
    funct_3M <= 3'b0; 
    Valid_M <= 1'b0;
    PCM <= 32'b0;
    InstrM <= 32'b0;
    end else begin
    RegWriteM <= RegWriteE; 
    ResultSrcM <= ResultSrcE; 
    MemWriteM <= MemWriteE; 
    Valid_M <= Valid_E;
    PCM <= PCE;
    InstrM <= InstrE;
    case(ALUResultM_selE)
    2'b00:ALUResultM <= ALUResultE;
    2'b01:ALUResultM <= ImmExtE;
    2'b10:ALUResultM <= PCTargetE;
    default:ALUResultM <= ALUResultE;
    endcase 
    WriteDataM <= WriteDataE; 
    RdM <= RdE; 
    PCPlus4M <= PCPlus4E;
    funct_3M <= funct_3E; 
    end
    end 
endmodule