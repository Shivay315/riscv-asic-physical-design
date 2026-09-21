==================================================================
data_memory.v -- SYNTHESIS ELABORATION HANG: ROOT CAUSE & FIX
==================================================================

SYMPTOM
-------
Synthesis tool hangs for 2+ hours on "Elaborate Design" when
data_memory.v is included. Removing data_memory.v causes synthesis
to complete instantly. No errors are thrown -- the tool is simply
overwhelmed and never finishes.


==================================================================
ROOT CAUSE 1 (PRIMARY) -- 2-Million Flip-Flop Explosion
==================================================================

OFFENDING LINE:
    reg [31:0] data_mem [0:65535];

OFFENDING BLOCK:
    initial begin
        for (i = 0; i < 65535; i = i + 1) data_mem[i] = 32'h00000000;
        ...
    end

EXPLANATION:
    65,536 words x 32 bits = 2,097,152 individual storage bits.

    When a synthesis tool sees a reg array with an initial block
    that resets every entry, it treats every single bit as a
    flip-flop with:
      - a synchronous or asynchronous reset
      - individual write-enable decode logic
      - a 16-bit address mux to select which word is read/written

    The tool is not frozen -- it is actively trying to elaborate
    and map over 2 million flip-flops plus the combinational
    decode tree connecting them. This is computationally
    impossible to complete in any reasonable time and would
    produce a circuit millions of times larger than intended.

    The initial for-loop is the trigger. It tells the synthesis
    tool that every flip-flop needs a reset condition, which
    forces it to build explicit reset logic for all 2M bits
    instead of inferring a RAM block. This is the direct cause
    of the hang.

    Bottom line: a behavioral reg array with an initial reset
    loop is a simulation construct. It is NEVER a valid way to
    describe RAM for synthesis.


==================================================================
ROOT CAUSE 2 (SECONDARY) -- Simulation-Only System Tasks
==================================================================

OFFENDING LINES:
    reg [1023:0] hexfile;
    initial begin
        ...
        if ($value$plusargs("DATA_HEX=%s", hexfile))
            $readmemh(hexfile, data_mem);
    end

EXPLANATION:
    $value$plusargs and $readmemh are simulation-only system tasks.
    They have no hardware equivalent and cannot be synthesized.
    Some synthesis tools silently ignore them; others stall or
    warn during elaboration when they encounter string arguments
    being passed to $value$plusargs. Either way, they must be
    removed from any file intended for synthesis.


==================================================================
SOLUTION A -- Foundry SRAM Macro (Required for Tapeout)
==================================================================

Use your PDK's memory compiler to generate an SRAM macro of the
correct size (65536 x 32) and replace the behavioral model with
a thin wrapper that instantiates it.

Replace data_memory.v with:

-------------------------------------------------------------------
module data_memory (
    input  [31:0] ALUResultM,
    input  [31:0] WriteDataM,
    input         clk,
    output [31:0] RD,
    input         MemWriteM,
    input         rst,
    input  [2:0]  funct_3M
);
    wire [15:0] widx = (ALUResultM - 32'h80000000) >> 2;

    // Instantiate your foundry SRAM macro here.
    // Port names will vary by PDK -- refer to your memory
    // compiler datasheet and adjust accordingly.
    SRAM_65536x32 u_dmem (
        .CLK (clk),
        .CEN (1'b0),        // chip enable, active low
        .WEN (~MemWriteM),  // write enable, active low
        .A   (widx),
        .D   (WriteDataM),
        .Q   (RD)
    );

endmodule
-------------------------------------------------------------------

WHY THIS IS THE RIGHT APPROACH FOR TAPEOUT:
    - The foundry SRAM macro is a pre-characterised hard macro
      with known area, timing, and power. The synthesis tool
      treats it as a black box and elaborates it instantly.
    - A behavioral reg array, even if it somehow finished
      elaborating, would never pass timing or area signoff --
      the resulting FF-based structure would be 100x larger and
      slower than a real SRAM.
    - Note: byte/halfword write granularity (funct3 = SB/SH)
      requires either a byte-enable port on the SRAM macro (WBE
      or similar) or a read-modify-write wrapper. Check whether
      your memory compiler supports byte write enables and add
      the byte mask logic accordingly.


==================================================================
SOLUTION B -- Inferred Block RAM (FPGA / Pre-Tapeout Prototyping)
==================================================================

If you are targeting an FPGA or want a quick synthesis-safe
behavioral model before your SRAM macro is ready, rewrite
data_memory.v as follows:

-------------------------------------------------------------------
module data_memory (
    input  [31:0] ALUResultM,
    input  [31:0] WriteDataM,
    input         clk,
    output reg [31:0] RD,
    input         MemWriteM,
    input         rst,
    input  [2:0]  funct_3M
);
    reg [31:0] data_mem [0:65535];
    wire [15:0] widx = (ALUResultM - 32'h80000000) >> 2;

    always @(posedge clk) begin
        if (MemWriteM) begin
            case (funct_3M)
                3'b000: data_mem[widx][({30'b0,ALUResultM[1:0]}*8)+:8]
                            <= WriteDataM[7:0];
                3'b001: data_mem[widx][ALUResultM[1]*16+:16]
                            <= WriteDataM[15:0];
                default: data_mem[widx] <= WriteDataM;
            endcase
        end
        // Synchronous (registered) read -- required for BRAM inference
        RD <= rst ? 32'd0 : data_mem[widx];
    end

endmodule
-------------------------------------------------------------------

KEY CHANGES MADE AND WHY:

    1. REMOVED the initial begin...end block entirely.
       The for-loop reset is what caused the 2M FF explosion.
       Without it, the synthesis tool sees a clean RAM access
       pattern and infers a block RAM instead of flip-flops.

    2. REMOVED $value$plusargs and $readmemh.
       Simulation-only constructs removed to keep the file
       synthesis-clean. If you need pre-loaded memory contents
       for simulation, keep a separate simulation-only wrapper
       that includes the $readmemh call and is excluded from
       the synthesis filelist.

    3. MADE the read port synchronous (registered inside always
       @posedge clk instead of a continuous assign).
       Most synthesis tools (Vivado, Design Compiler, Genus)
       require a registered read port to correctly infer a true
       dual-port or single-port block RAM. An asynchronous
       assign read forces the tool to use distributed LUTs or
       FFs instead of a BRAM primitive, which reintroduces the
       area problem.

RESULT:
    Synthesis will complete in seconds. The tool infers a single
    BRAM primitive (e.g. Xilinx RAMB36, or equivalent) instead
    of 2,097,152 flip-flops.


==================================================================
WHICH SOLUTION TO USE
==================================================================

    FPGA / Simulation / Prototyping  -->  Use Solution B
    ASIC / Tapeout                   -->  Use Solution A

    For a tapeout flow, Solution B is only a temporary stand-in.
    It must be replaced with the foundry SRAM macro (Solution A)
    before running synthesis for signoff, place-and-route, or
    any physical implementation step.

    Also note: for simulation purposes, keep a separate copy of
    the original behavioral data_memory.v (with $readmemh) in
    your simulation filelist only. Never include it in the
    synthesis filelist.

==================================================================
SUMMARY TABLE
==================================================================

  Issue                        Cause                  Fix
  ---------------------------  ---------------------  ----------------------
  2-hour elaboration hang      65536x32 reg array     Replace with SRAM macro
                               + initial reset loop   or remove initial block
  Simulation tasks in RTL      $readmemh,             Remove from synthesis
                               $value$plusargs        filelist entirely
  Async read prevents BRAM     assign RD = data_mem   Change to registered
  inference (Solution B only)  (combinational)        read in always block

==================================================================
