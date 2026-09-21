`timescale 1ns / 1ps
module csr_file(
  input         clk,
  input         rst,
  input  [11:0] csr_addr,
  output reg [31:0] csr_rdata,
  input  [31:0] csr_wdata,
  input         csr_we,
  output [31:0] mepc_o,
  output [31:0] mtvec_o,
  output [31:0]mstatus_o,
  input trap_set,
  input mret_set,
  input [31:0] trap_mepc,
  input [31:0] trap_mtval,
  input [31:0] trap_mcause
);
  // ---- machine-mode CSRs (extend this list when traps land) ----
  reg [31:0] mscratch;            // 0x340
  reg [31:0] mstatus;
  reg [31:0] mie;
  reg [31:0] mtvec;
  reg [31:0] misa;
  reg [31:0] mepc;
  reg [31:0] mcause;
  reg [31:0] mtval;
  reg [31:0] mhartid;
  
  assign mepc_o = mepc;
  assign mtvec_o = mtvec;
  assign mstatus_o = mstatus;
 
  
  
  always@(*) begin
  case(csr_addr)
  12'h300:csr_rdata = mstatus;
  12'h301:csr_rdata = misa;
  12'h304:csr_rdata = mie;
  12'h305:csr_rdata = mtvec;
  12'h340:csr_rdata = mscratch;
  12'h341:csr_rdata = mepc;
  12'h342:csr_rdata = mcause;
  12'h343:csr_rdata = mtval;
  12'hf14:csr_rdata = mhartid;
    default: csr_rdata = 32'h0;
  endcase
  end
  
  // synchronous write
  always @(posedge clk) begin
    if (rst) begin
      mscratch <= 32'h0;
      mstatus <= 32'h0;
      misa <= 32'h40000100;
      mie <= 32'h0;
      mtvec <= 32'h0;
      mepc <=32'h0;
      mcause <=32'h0;
      mtval <= 32'h0;
      mhartid <=32'h0;
      end
      else if (trap_set)begin
      mepc <= trap_mepc;
      mtval <= trap_mtval;
      mcause <= trap_mcause;
      mstatus[7] <= mstatus[3];
      mstatus[3] <= 0;
      mstatus[12:11] <= 2'b11;
      end
      else if (mret_set)begin
      mstatus[3] <= mstatus[7];
      mstatus[7] <= 1'b1;
      end
    else if (csr_we) begin
    case(csr_addr)
    12'h300:{mstatus[3],mstatus[7],mstatus[12:11]}<={csr_wdata[3],csr_wdata[7],2'b11};
  12'h304:mie <= csr_wdata;
  12'h305:mtvec <={ csr_wdata[31:2],2'b00};
  12'h340:mscratch <= csr_wdata;
  12'h341:mepc <= {csr_wdata[31:2],2'b00};
  12'h342:mcause <= csr_wdata;
  12'h343:mtval <= csr_wdata;
    endcase
    end
  end
endmodule
