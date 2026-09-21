`timescale 1ns / 1ps
module ALUDecoder(input [2:0]funct3,input funct7_5,input op_5,input [1:0]ALUOp,
output reg [3:0]ALUControlD
    );
    always @(*)begin
    case(ALUOp)
    2'b00:ALUControlD = 4'b0000;
    2'b01:ALUControlD = 4'b0001;
    2'b10:begin
    case(funct3)
    3'b000:begin if(op_5&funct7_5) 
    ALUControlD = 4'b0001;
    else
    ALUControlD = 4'b0000;
    end
    3'b111:ALUControlD = 4'b0010;
    3'b110:ALUControlD = 4'b0011; 
    3'b001:ALUControlD = 4'b0100;
    3'b101:begin if(funct7_5) 
    ALUControlD = 4'b0110;
    else
    ALUControlD = 4'b0101;
    end
    3'b010:ALUControlD = 4'b0111;
    3'b011:ALUControlD = 4'b1000;
    3'b100:ALUControlD = 4'b1001;
    default:ALUControlD = 4'b0000; 
    endcase
    end
    default:ALUControlD = 4'b0000;
    endcase
    end
endmodule
