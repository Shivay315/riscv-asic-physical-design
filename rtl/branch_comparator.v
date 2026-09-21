`timescale 1ns / 1ps

module branch_comparator(input BranchE,input [2:0]funct_3E,output reg Branch,input [31:0]SrcAE,
input [31:0]SrcBE 

    );
    always@(*)begin
    if (BranchE)begin
    case(funct_3E)
    3'b000: Branch = (SrcAE == SrcBE);
    3'b001: Branch = (SrcAE != SrcBE);
    3'b100: Branch = ($signed(SrcAE) < $signed(SrcBE));
    3'b101: Branch = ($signed(SrcAE) >= $signed(SrcBE));
    3'b110: Branch = (SrcAE < SrcBE);
    3'b111: Branch = (SrcAE >= SrcBE);
    default: Branch = 1'b0;    
    endcase
    end else
    Branch =1'b0;
    end
endmodule
