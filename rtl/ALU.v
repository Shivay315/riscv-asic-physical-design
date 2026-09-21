`timescale 1ns / 1ps
module ALU(input [31:0] SrcAE,input [31:0] SrcBE,input [3:0] ALUControlE,
output reg [31:0] ALUResultE
,output reg ZeroE
    );
    always@(*)begin
    case(ALUControlE)
    4'b0000:ALUResultE = SrcAE + SrcBE;
    4'b0001:begin 
    ALUResultE = SrcAE - SrcBE;
    end
    4'b0010:ALUResultE = SrcAE & SrcBE;
    4'b0011:ALUResultE = SrcAE | SrcBE;
    4'b0100:ALUResultE = SrcAE << SrcBE[4:0];
    4'b0101:ALUResultE = SrcAE >> SrcBE[4:0];
    4'b0110:ALUResultE = $signed(SrcAE) >>> SrcBE[4:0];
    4'b0111:ALUResultE = ($signed(SrcAE) < $signed(SrcBE));
    4'b1000:ALUResultE = (SrcAE < SrcBE);
    4'b1001:ALUResultE = (SrcAE ^ SrcBE);
    default:ALUResultE = 32'b0;   
    endcase
    if (ALUResultE == 32'b0) ZeroE = 1'b1;
    else ZeroE = 1'b0;
    end
endmodule
