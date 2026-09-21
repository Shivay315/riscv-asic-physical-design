`timescale 1ns / 1ps 
module MEM_WB(input clk,input RegWriteM ,input [1:0]ResultSrcM,input [31:0]ALUResultM, 
input [31:0]ReadDataM,input [31:0]PCPlus4M,output reg RegWriteW , input Valid_M,
input [31:0] PCM,input [31:0] InstrM,input  MemWriteM,input [31:0] WriteDataM,
output reg [1:0]ResultSrcW,output reg [31:0]ALUResultW, 
output reg [31:0]ReadDataW,output reg[31:0]PCPlus4W ,input[4:0] RdM,output reg  [4:0]RdW,
input rst,output reg Valid_W,output reg [31:0] PCW,output reg [31:0] InstrW,output reg MemWriteW 
 ,output reg [31:0] WriteDataW
    ); 
    always @ ( posedge clk)begin 
    if (rst)begin
    RegWriteW <= 1'b0; 
    ResultSrcW <= 2'b0; 
    ALUResultW <= 32'b0; 
    ReadDataW <= 32'b0; 
    PCPlus4W <= 32'b0;
    RdW <= 5'b0;   
    Valid_W <= 1'b0;
    PCW <= 32'b0;
    InstrW <= 32'b0;
    MemWriteW <= 1'b0;
    WriteDataW <= 32'b0;
    end else begin  
    RegWriteW <= RegWriteM; 
    ResultSrcW <= ResultSrcM; 
    ALUResultW <= ALUResultM; 
    ReadDataW <= ReadDataM; 
    PCPlus4W <= PCPlus4M;
    RdW <= RdM;   
    Valid_W <= Valid_M;
    PCW <= PCM;
    InstrW <= InstrM;
    MemWriteW <= MemWriteM;
    WriteDataW <= WriteDataM;
    end 
    end
endmodule 
