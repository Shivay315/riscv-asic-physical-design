`timescale 1ns / 1ps
module ID_EX(input RegWriteD,input [1:0]ResultSrcD,input MemWriteD,input JumpD,input BranchD,input mret_D,output reg mret_E,
input [3:0]ALUControlD,input ALUSrcD,input [31:0] RD1,input [31:0] RD2,input [31:0] PCD,input exc_D,output reg exc_E,input [3:0] exc_cause_D,output reg [3:0] exc_cause_E,
input [4:0]Rs1D,input [4:0] Rs2D,input [4:0] RdD,input [31:0] ImmExtD,input [31:0] PCPlus4D,
input [1:0] ALUResultM_selD,input Branch_Target_selD,input Valid_D,input [31:0] InstrD,
output reg RegWriteE,output reg  [1:0]ResultSrcE,output reg  MemWriteE,output reg  JumpE,
output reg  BranchE,output reg [31:0] InstrE,
output reg  [3:0]ALUControlE,output reg  ALUSrcE,output reg  [31:0] RD1E,
output reg  [31:0] RD2E,output reg  [31:0] PCE,
output reg  [4:0]Rs1E,output reg  [4:0] Rs2E,output reg  [4:0] RdE,
output reg  [31:0] ImmExtE,output reg  [31:0] PCPlus4E,input clk,input FlushE,input rst,
input [2:0]funct_3D,output reg [2:0]funct_3E,output reg [1:0] ALUResultM_selE,output reg Branch_Target_selE
,output reg Valid_E ,input IsCsrD, output reg IsCsrE   );
    always @(posedge clk)begin
    if (rst)begin
    RegWriteE <= 1'b0;
    ResultSrcE <= 2'b0;
    MemWriteE <= 1'b0;
    JumpE <= 1'b0;
    BranchE <= 1'b0;
    ALUControlE <= 4'b0;
    ALUSrcE <= 1'b0;
    RD1E <= 32'b0;
    RD2E <= 32'b0;
    PCE <= 32'b0;
    Rs1E <= 5'b0;
    Rs2E <= 5'b0;
    RdE <= 5'b0;
    ImmExtE <= 32'b0;
    PCPlus4E <= 32'b0;
    funct_3E <= 3'b0;
    ALUResultM_selE <= 2'b00;
    Branch_Target_selE <= 1'b0;
    Valid_E <= 1'b0;
    InstrE <= 1'b0;
    IsCsrE <= 1'b0;
    mret_E <= 1'b0;
    exc_E <= 1'b0;
    exc_cause_E <= 4'b0;
    end
    else if (FlushE)begin
    RegWriteE <= 1'b0;
    ResultSrcE <= 2'b0;
    MemWriteE <= 1'b0;
    JumpE <= 1'b0;
    BranchE <= 1'b0;
    ALUControlE <= 4'b0;
    ALUSrcE <= 1'b0;
    RD1E <= 32'b0;
    RD2E <= 32'b0;
    PCE <= 32'b0;
    Rs1E <= 5'b0;
    Rs2E <= 5'b0;
    RdE <= 5'b0;
    ImmExtE <= 32'b0;
    PCPlus4E <= 32'b0;
    funct_3E <= 3'b0;
    ALUResultM_selE <= 2'b00;
    Branch_Target_selE <= 1'b0;
    Valid_E <= 1'b0;
    InstrE <= 32'b0;
    IsCsrE <= 1'b0;
    mret_E <= 1'b0;
    exc_E <= 1'b0;
    exc_cause_E <= 4'b0;
    end
    else begin
    RegWriteE <= RegWriteD;
    ResultSrcE <= ResultSrcD;
    MemWriteE <= MemWriteD;
    JumpE <= JumpD;
    BranchE <= BranchD;
    ALUControlE <= ALUControlD;
    ALUSrcE <= ALUSrcD;
    RD1E <= RD1;
    RD2E <= RD2;
    PCE <= PCD;
    Rs1E <= Rs1D;
    Rs2E <= Rs2D;
    RdE <= RdD;
    ImmExtE <= ImmExtD;
    PCPlus4E <= PCPlus4D;
    funct_3E <= funct_3D; 
    ALUResultM_selE <= ALUResultM_selD; 
    Branch_Target_selE <= Branch_Target_selD;
    Valid_E <= Valid_D;
    InstrE <= InstrD;
    IsCsrE <= IsCsrD;
    mret_E <= mret_D;
    exc_E <= exc_D;
    exc_cause_E <= exc_cause_D;
    end
      
    end
endmodule


