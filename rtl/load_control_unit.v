`timescale 1ns / 1ps
module load_control_unit(input [1:0] ALUResultM,input [31:0] RD,output reg [31:0]ReadDataM,
input [2:0]funct_3M 

    );
    always@(*)begin
    case(funct_3M)
    3'b000:begin
    case(ALUResultM)
    2'b00:ReadDataM = {{24{RD[7]}},RD[7:0]};
    2'b01:ReadDataM = {{24{RD[15]}},RD[15:8]};
    2'b10:ReadDataM = {{24{RD[23]}},RD[23:16]};
    2'b11:ReadDataM = {{24{RD[31]}},RD[31:24]};
    default:ReadDataM = RD;
    endcase
    end
    3'b001:begin
    case(ALUResultM)
    2'b00:ReadDataM = {{16{RD[15]}},RD[15:0]};
    2'b10:ReadDataM = {{16{RD[31]}},RD[31:16]};
    default:ReadDataM = RD;
    endcase
    end
    3'b010:ReadDataM = RD;
    3'b100:begin
    case(ALUResultM)
    2'b00:ReadDataM = {24'b0,RD[7:0]};
    2'b01:ReadDataM = {24'b0,RD[15:8]};
    2'b10:ReadDataM = {24'b0,RD[23:16]};
    2'b11:ReadDataM = {24'b0,RD[31:24]};
    default:ReadDataM = RD;
    endcase
    end
    3'b101:begin
    case(ALUResultM)
    2'b00:ReadDataM = {16'b0,RD[15:0]};
    2'b10:ReadDataM = {16'b0,RD[31:16]};
    default:ReadDataM = RD;
    endcase
    end
    default:ReadDataM = RD;
    endcase
    end
endmodule
