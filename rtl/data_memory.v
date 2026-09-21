`timescale 1ns / 1ps
module data_memory(input [31:0]ALUResultM, input [31:0] WriteDataM,input clk,
output [31:0]RD, input MemWriteM,input rst,input [2:0]funct_3M
    );
    reg [31:0] data_mem [0:65535];
    wire [15:0] widx = (ALUResultM - 32'h80000000) >> 2;   // base-relative word index
    integer i;
    reg [1023:0] hexfile;
    initial begin
        for (i = 0; i < 65535; i = i + 1) data_mem[i] = 32'h00000000;
        if ($value$plusargs("DATA_HEX=%s", hexfile))
            $readmemh(hexfile, data_mem);                // pre-load program image (incl. data sections)
    end
    always @ (posedge clk) begin
      if (MemWriteM) begin
        case(funct_3M)
        3'b000: data_mem[widx][({30'b0,ALUResultM[1:0]}*8) +: 8] <= WriteDataM[7:0];
        3'b001: data_mem[widx][ALUResultM[1]*16 +: 16]          <= WriteDataM[15:0];
        3'b010: data_mem[widx]                                   <= WriteDataM;
        default:data_mem[widx]                                   <= WriteDataM;
        endcase
      end
    end
    assign RD = rst ? 32'd0 : data_mem[widx];
endmodule
