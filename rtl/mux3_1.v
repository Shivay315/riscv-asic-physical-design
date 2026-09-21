`timescale 1ns / 1ps
module forwarding_mux(input [31:0] RD1E,input [31:0]ResultW,
input [31:0] ALUResultM ,input[1:0] ForwardAE,output reg[31:0] SrcAE,
input[31:0] RD2E,input[1:0] ForwardBE ,output reg[31:0] WriteDataE ,
output [31:0] SrcBE ,input  ALUSrcE,
input [31:0]ImmExtE

    );
    always @ (*)begin
    case (ForwardAE)
    2'b00:SrcAE = RD1E;
    2'b01:SrcAE = ResultW;
    2'b10:SrcAE = ALUResultM;
    default: SrcAE = 32'b0;
    endcase
    end
    always @ (*)begin
    case (ForwardBE)
    2'b00:WriteDataE = RD2E;
    2'b01:WriteDataE = ResultW;
    2'b10:WriteDataE = ALUResultM;
    default: WriteDataE = 32'b0;
    endcase
    end
    assign SrcBE = (ALUSrcE)?ImmExtE:WriteDataE;
endmodule
