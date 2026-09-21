`timescale 1ns / 1ps
//==================================================================
// chip_top.v
//
// Chip-level wrapper for the riscv core. Instantiates I/O pad cells
// for every signal that crosses the chip boundary, per IO_Pad_Plan.txt.
//
// IMPORTANT: The pad cell modules below (CLK_PAD, RST_PAD, IN_PAD,
// OUT_PAD, BIDIR_PAD) are GENERIC PLACEHOLDERS. Replace their
// internal instantiation with your actual PDK/IO-library cells
// (e.g. PCLKIN, PDIDGZ, PDO04CDG, PDB04DGZ, or whatever your
// foundry's IO library calls them). The port-level wiring and
// pad-per-signal mapping here will not change when you swap them in.
//
// USE_MUX_BUS parameter:
//   0 (default) = instr_addr[31:0] and instr_data[31:0] brought out
//                 as two separate 32-bit buses (66 functional pins)
//   1           = instr_addr/instr_data multiplexed onto a single
//                 32-bit bidirectional bus (the "optional recommended"
//                 addition from IO_Pad_Plan.txt section 4), using an
//                 added ale/mem_oe phase-control pin.
//==================================================================

//------------------------------------------------------------------
// Generic placeholder pad cells -- swap these for real PDK pad cells
//------------------------------------------------------------------

// Dedicated clock input pad (low-skew, low-jitter buffer to clock tree)
module CLK_PAD (input PAD, output C);
    assign C = PAD;
endmodule

// Digital input pad, Schmitt trigger, optional internal pull-up/down
module RST_PAD (input PAD, output C);
    assign C = PAD;
endmodule

// Plain digital input pad (standard CMOS input buffer)
module IN_PAD (input PAD, output C);
    assign C = PAD;
endmodule

// Digital output pad, slew-rate controlled, programmable drive strength
module OUT_PAD (input C, output PAD);
    assign PAD = C;
endmodule

// Bidirectional pad: tri-statable output + input, with output-enable
module BIDIR_PAD (
    input  C,    // data to drive out
    input  OE,   // output enable (1 = drive PAD from C, 0 = high-Z / read)
    output Y,    // data read in from PAD
    inout  PAD
);
    assign PAD = OE ? C : 1'bz;
    assign Y   = PAD;
endmodule

//------------------------------------------------------------------
// chip_top
//------------------------------------------------------------------
module chip_top #(
    parameter USE_MUX_BUS = 0
) (
    // Functional pins
    input  wire        clk_pad,
    input  wire        rst_pad,

    // Separate-bus mode pins (USE_MUX_BUS = 0)
    output wire [31:0] instr_addr_pad,
    input  wire [31:0] instr_data_pad,

    // Multiplexed-bus mode pins (USE_MUX_BUS = 1)
    inout  wire [31:0] instr_addr_data_pad,
    output wire        mem_ale_pad,        // address-phase strobe

    // Debug / writeback bus pins
    output wire        Valid_W_pad,
    output wire [31:0] PCW_pad,
    output wire [31:0] InstrW_pad,
    output wire        RegWriteW_pad,
    output wire [4:0]  RdW_pad,
    output wire [31:0] ResultW_pad,
    output wire        MemWriteW_pad,
    output wire [31:0] ALUResultW_pad,
    output wire [31:0] WriteDataW_pad
);

    //--------------------------------------------------------------
    // Core-side wires (pre-pad, on-die signals)
    //--------------------------------------------------------------
    wire        clk;
    wire        rst;
    wire [31:0] instr_addr;
    wire [31:0] instr_data;
    wire        Valid_W;
    wire [31:0] PCW;
    wire [31:0] InstrW;
    wire        RegWriteW;
    wire [4:0]  RdW;
    wire [31:0] ResultW;
    wire        MemWriteW;
    wire [31:0] ALUResultW;
    wire [31:0] WriteDataW;

    //--------------------------------------------------------------
    // [1] clk -- Dedicated Clock Input Pad
    //--------------------------------------------------------------
    CLK_PAD u_clk_pad (.PAD(clk_pad), .C(clk));

    //--------------------------------------------------------------
    // [2] rst -- Digital Input Pad, Schmitt Trigger
    //--------------------------------------------------------------
    RST_PAD u_rst_pad (.PAD(rst_pad), .C(rst));

    //--------------------------------------------------------------
    // [3]/[4] instr_addr / instr_data
    //   - USE_MUX_BUS = 0: separate Input/Output pad buses
    //   - USE_MUX_BUS = 1: shared Bidirectional bus + ale phase ctrl
    //--------------------------------------------------------------
    genvar i;

    generate
    if (USE_MUX_BUS == 0) begin : g_separate_bus

        // instr_addr[31:0] -- Digital Output Pads, slew-rate controlled
        for (i = 0; i < 32; i = i + 1) begin : g_addr_out
            OUT_PAD u_addr_pad (.C(instr_addr[i]), .PAD(instr_addr_pad[i]));
        end

        // instr_data[31:0] -- Digital Input Pads
        for (i = 0; i < 32; i = i + 1) begin : g_data_in
            IN_PAD u_data_pad (.PAD(instr_data_pad[i]), .C(instr_data[i]));
        end

        // Multiplexed-bus pins unused in this mode -- tie off safely
        assign mem_ale_pad = 1'b0;

    end else begin : g_mux_bus

        //----------------------------------------------------------
        // Address/data mux wrapper (8051-style):
        //   ale = 1 : drive instr_addr out on instr_addr_data_pad
        //   ale = 0 : read instr_data in from instr_addr_data_pad
        // Toggles every clk cycle. Two-cycle fetch: 1 addr phase +
        // 1 data phase per instruction fetch.
        //----------------------------------------------------------
        reg ale_r;
        reg [31:0] instr_data_latched;
        wire [31:0] bidir_bus_in; // internal read-back from the bidirectional pads

        always @(posedge clk or posedge rst) begin
            if (rst) begin
                ale_r <= 1'b1;
            end else begin
                ale_r <= ~ale_r;
            end
        end

        always @(posedge clk or posedge rst) begin
            if (rst)
                instr_data_latched <= 32'b0;
            else if (~ale_r)
                instr_data_latched <= bidir_bus_in; // capture during data phase
        end

        assign instr_data = instr_data_latched;

        // mem_ale_pad -- Digital Output Pad, standard drive
        OUT_PAD u_ale_pad (.C(ale_r), .PAD(mem_ale_pad));

        // instr_addr_data[31:0] -- Bidirectional Pads, slew-rate controlled
        for (i = 0; i < 32; i = i + 1) begin : g_addr_data_bidir
            BIDIR_PAD u_addr_data_pad (
                .C   (instr_addr[i]),
                .OE  (ale_r),                 // drive bus only during address phase
                .Y   (bidir_bus_in[i]),       // captured into instr_data_latched above
                .PAD (instr_addr_data_pad[i])
            );
        end

        // instr_addr_pad / instr_data_pad not used in this mode
        assign instr_addr_pad = 32'b0;

    end
    endgenerate

    //--------------------------------------------------------------
    // [5]-[13] Writeback/debug bus -- Digital Output Pads
    //          (slew-rate controlled for the multi-bit buses)
    //--------------------------------------------------------------

    // Valid_W -- standard drive
    OUT_PAD u_valid_w_pad (.C(Valid_W), .PAD(Valid_W_pad));

    // PCW[31:0] -- slew-rate controlled
    for (i = 0; i < 32; i = i + 1) begin : g_pcw_out
        OUT_PAD u_pcw_pad (.C(PCW[i]), .PAD(PCW_pad[i]));
    end

    // InstrW[31:0] -- slew-rate controlled
    for (i = 0; i < 32; i = i + 1) begin : g_instrw_out
        OUT_PAD u_instrw_pad (.C(InstrW[i]), .PAD(InstrW_pad[i]));
    end

    // RegWriteW -- standard drive
    OUT_PAD u_regwritew_pad (.C(RegWriteW), .PAD(RegWriteW_pad));

    // RdW[4:0] -- standard drive
    for (i = 0; i < 5; i = i + 1) begin : g_rdw_out
        OUT_PAD u_rdw_pad (.C(RdW[i]), .PAD(RdW_pad[i]));
    end

    // ResultW[31:0] -- slew-rate controlled
    for (i = 0; i < 32; i = i + 1) begin : g_resultw_out
        OUT_PAD u_resultw_pad (.C(ResultW[i]), .PAD(ResultW_pad[i]));
    end

    // MemWriteW -- standard drive
    OUT_PAD u_memwritew_pad (.C(MemWriteW), .PAD(MemWriteW_pad));

    // ALUResultW[31:0] -- slew-rate controlled
    for (i = 0; i < 32; i = i + 1) begin : g_aluresultw_out
        OUT_PAD u_aluresultw_pad (.C(ALUResultW[i]), .PAD(ALUResultW_pad[i]));
    end

    // WriteDataW[31:0] -- slew-rate controlled
    for (i = 0; i < 32; i = i + 1) begin : g_writedataw_out
        OUT_PAD u_writedataw_pad (.C(WriteDataW[i]), .PAD(WriteDataW_pad[i]));
    end

    //--------------------------------------------------------------
    // Core instance
    //--------------------------------------------------------------
    riscv u_riscv (
        .clk         (clk),
        .rst         (rst),
        .instr_addr  (instr_addr),
        .instr_data  (instr_data),
        .Valid_W     (Valid_W),
        .PCW         (PCW),
        .InstrW      (InstrW),
        .RegWriteW   (RegWriteW),
        .RdW         (RdW),
        .ResultW     (ResultW),
        .MemWriteW   (MemWriteW),
        .ALUResultW  (ALUResultW),
        .WriteDataW  (WriteDataW)
    );

endmodule
