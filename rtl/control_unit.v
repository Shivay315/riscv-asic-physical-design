`timescale 1ns / 1ps
module control_unit(input [6:0]op,input [2:0] funct3,input funct7_5,output reg RegWriteD,input [11:0] funct12,output reg mret_D,
output reg[1:0]ResultSrcD,output reg MemWriteD,output reg JumpD,output reg BranchD,output reg exc_D,output reg [3:0]exc_cause_D,
output [3:0]ALUControlD,output reg ALUSrcD,output reg [2:0]ImmSrcD,output reg [1:0] ALUResultM_selD,
output reg Branch_Target_selD,output reg IsCsrD);
reg [1:0]ALUOp ;
wire op_5;
always@(*)begin
IsCsrD = 1'b0;
mret_D = 1'b0;
exc_D = 1'b0;
exc_cause_D = 4'b0;
case(op)
7'b0110011:begin   // R type
RegWriteD = 1'b1;
ResultSrcD = 2'b00;
MemWriteD=1'b0;
JumpD=1'b0;
BranchD=1'b0;
ALUSrcD=1'b0;
ImmSrcD = 3'bxxx;
ALUOp = 2'b10;
ALUResultM_selD = 2'b00;
Branch_Target_selD = 1'bx ;
end
7'b0000011:begin     // lw 
RegWriteD = 1'b1;
ResultSrcD = 2'b01;
MemWriteD=1'b0;
JumpD=1'b0;
BranchD=1'b0;
ALUSrcD=1'b1;
ImmSrcD = 3'b000;
ALUOp = 2'b00;
ALUResultM_selD = 2'b00;
Branch_Target_selD =1'bx ;
end
7'b0100011:begin       //sw 
RegWriteD = 1'b0;
ResultSrcD = 2'bxx;
MemWriteD=1'b1;
JumpD=1'b0;
BranchD=1'b0;
ALUSrcD=1'b1;
ImmSrcD = 3'b001;
ALUOp = 2'b00;
ALUResultM_selD = 2'b00;
Branch_Target_selD =1'bx ;
end
7'b1100011:begin         // branch
RegWriteD = 1'b0;
ResultSrcD = 2'bxx;
MemWriteD=1'b0;
JumpD=1'b0;
BranchD=1'b1;
ALUSrcD=1'b0;
ImmSrcD = 3'b010;
ALUOp = 2'b01;
ALUResultM_selD = 2'b00;
Branch_Target_selD = 1'b1;
end
7'b0010011:begin              // I type
RegWriteD = 1'b1;
ResultSrcD = 2'b00;
MemWriteD=1'b0;
JumpD=1'b0;
BranchD=1'b0;
ALUSrcD=1'b1;
ImmSrcD = 3'b000;
ALUOp = 2'b10;
ALUResultM_selD = 2'b00;
Branch_Target_selD = 1'bx;
end
7'b1101111:begin      // Jump
RegWriteD = 1'b1;
ResultSrcD = 2'b10;
MemWriteD=1'b0;
JumpD=1'b1;
BranchD=1'b0;
ALUSrcD=1'bx;
ImmSrcD = 3'b011;
ALUOp = 2'bxx;
ALUResultM_selD = 2'b00;
Branch_Target_selD = 1'b1;
end
7'b0110111:begin      // lui
RegWriteD = 1'b1;
ResultSrcD = 2'b00;
MemWriteD=1'b0;
JumpD=1'b0;
BranchD=1'b0;
ALUSrcD=1'bx;
ImmSrcD = 3'b100;
ALUOp = 2'bxx;
ALUResultM_selD = 2'b01;
Branch_Target_selD = 1'bx;
end
7'b0010111:begin     //  aupic
RegWriteD = 1'b1;
ResultSrcD = 2'b00;
MemWriteD=1'b0;
JumpD=1'b0;
BranchD=1'b0;
ALUSrcD=1'bX;
ImmSrcD = 3'b100;
ALUOp = 2'bxx;
ALUResultM_selD = 2'b10;
Branch_Target_selD = 1'b1;
end
7'b1100111:begin     //  jalr
RegWriteD = 1'b1;
ResultSrcD = 2'b10;
MemWriteD=1'b0;
JumpD=1'b1;
BranchD=1'b0;
ALUSrcD=1'b1;
ImmSrcD = 3'b000;
ALUOp = 2'b00;
ALUResultM_selD = 2'bxx;
Branch_Target_selD = 1'b0;
end
7'b1110011: begin   // SYSTEM (CSR + ECALL/EBREAK)
  ResultSrcD         = 2'b00;
  MemWriteD          = 1'b0;
  JumpD              = 1'b0;
  BranchD            = 1'b0;
  ALUSrcD            = 1'b0;
  ImmSrcD            = 3'b000;
  ALUOp              = 2'b00;
  ALUResultM_selD    = 2'b00;     // old CSR value rides the ALU-result port
  Branch_Target_selD = 1'b0;
  if (funct3[1:0] != 2'b00) begin // CSRRW/S/C and their immediate forms
    IsCsrD    = 1'b1;
    RegWriteD = 1'b1;
    
  end else begin                  // ECALL / EBREAK: inert for now
    IsCsrD    = 1'b0;
    RegWriteD = 1'b0;
    mret_D = (funct12 == 12'h302);
    exc_D = (funct12 == 12'h000);
    exc_cause_D = (funct12 == 12'h000)?4'd11:exc_cause_D;
  end
end
default:begin
RegWriteD = 1'b0;
ResultSrcD = 2'b00;
MemWriteD=1'b0;
JumpD=1'b0;
BranchD=1'b0;
ALUSrcD=1'b0;
ImmSrcD = 3'b000;
ALUOp = 2'b00;
ALUResultM_selD = 2'b00;
Branch_Target_selD = 1'bx;
end
endcase
end
assign op_5 = op[5];
ALUDecoder f1(.funct3(funct3),.funct7_5(funct7_5),.op_5(op_5),.ALUOp(ALUOp),
.ALUControlD(ALUControlD)
    );

endmodule
