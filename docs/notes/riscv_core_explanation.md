==================================================================
RISC-V CORE -- COMPLETE DESIGN EXPLANATION
==================================================================
Based on source files: riscv.v, pc_logic.v, IF_ID.v, register_file.v,
control_unit.v, ALUDecoder.v, Extend.v, ID_EX.v, forwarding_mux (mux3_1.v),
ALU.v, branch_comparator.v, branch_target.v, csr_file.v, EX_MEM.v,
data_memory.v, load_control_unit.v, MEM_WB.v, result_mux.v, hazard_unit.v


==================================================================
SECTION 1 -- WHAT KIND OF CORE IS THIS?
==================================================================

This is a 5-stage pipelined RISC-V RV32I processor. It implements
the base 32-bit integer instruction set, plus Machine-mode
privileged extensions (CSR instructions, traps, ECALL, MRET).

The five pipeline stages are:

    IF  -->  ID  -->  EX  -->  MEM  -->  WB
  Fetch   Decode  Execute  Memory  Writeback

The key extra features beyond a basic textbook pipeline:
  - Full data forwarding (EX-EX and MEM-EX paths)
  - Load-use hazard detection and stalling
  - Branch resolution in the EX stage with pipeline flush
  - CSR (Control and Status Register) file
  - Trap handling: ECALL, misaligned memory, misaligned branches
  - MRET (machine-mode return from trap)
  - Sub-word memory access: LB, LH, LBU, LHU, SB, SH, SW

Reset address: 0x80000000 (standard Linux/RISC-V base address)


==================================================================
SECTION 2 -- PIPELINE STAGE BY STAGE
==================================================================

------------------------------------------------------------------
STAGE 1: IF -- Instruction Fetch
Modules: pc_logic (k1), riscv.v assignments, IF_ID (k2)
------------------------------------------------------------------

The PC register lives inside pc_logic. On every clock edge it
decides what address to fetch next. Priority order (highest first):

  1. rst=1               --> PC = 0x80000000 (hard reset)
  2. trap_redirect=1     --> PC = mtvec (jump to trap handler)
  3. mret_redirect=1     --> PC = mepc  (return from trap)
  4. PCSrcE=1            --> PC = PCTargetE (branch/jump taken)
  5. StallF=1            --> PC stays the same (hold for load-use)
  6. default             --> PC = PC + 4 (normal sequential fetch)

The current PC (PCF) is sent directly out of the chip as
instr_addr, and instruction memory responds with instr_data which
becomes InstrF. These are both top-level ports.

PCPlus4F = PCF + 4 is computed combinationally here so it can
be passed down the pipeline for JAL/JALR link-address writeback.

Valid_F is simply (~rst). When reset is active no valid
instruction is in the pipeline, so Valid_F=0 prevents any
instruction that slips through from committing.

IF_ID pipeline register (k2):
  - Stores PCF, PCPlus4F, InstrF, Valid_F for the next stage.
  - On FlushD: writes NOP (0x00000013 = ADDI x0,x0,0) and
    Valid=0. This kills the instruction in decode when a
    branch/jump is resolved or a trap fires.
  - On StallD: holds its values (stops moving forward).
  - On rst: same as FlushD.

------------------------------------------------------------------
STAGE 2: ID -- Instruction Decode
Modules: Register_file (k3), control_unit (k4),
         ALUDecoder (f1 inside k4), Extend (k5), ID_EX (k6)
------------------------------------------------------------------

Three things happen in parallel in the decode stage:

  A) REGISTER FILE READ (register_file / k3)
     Reads two source registers simultaneously:
       Rs1 = InstrD[19:15]  --> RD1 (source A)
       Rs2 = InstrD[24:20]  --> RD2 (source B)
     Register x0 is hardwired to 0 (handled by the ternary
     assign, not by a special physical register).

     IMPORTANT: The register file writes on the NEGATIVE clock
     edge (negedge clk). This is a deliberate design choice
     so that during the same clock cycle, the WB stage can write
     a result in the first half of the clock and the ID stage
     can read it back in the second half -- effectively giving
     "free" WB-to-ID forwarding without needing an extra
     forwarding path for that case.

  B) CONTROL UNIT (control_unit / k4 + ALUDecoder / f1)
     Decodes the opcode (InstrD[6:0]) into all the control
     signals the rest of the pipeline needs. The instructions
     it handles:

     Opcode 0110011 : R-type  (ADD, SUB, AND, OR, XOR, SLL,
                               SRL, SRA, SLT, SLTU)
     Opcode 0010011 : I-type  (ADDI, ANDI, ORI, XORI, SLLI,
                               SRLI, SRAI, SLTI, SLTIU)
     Opcode 0000011 : Load    (LB, LH, LW, LBU, LHU)
     Opcode 0100011 : Store   (SB, SH, SW)
     Opcode 1100011 : Branch  (BEQ, BNE, BLT, BGE, BLTU, BGEU)
     Opcode 1101111 : JAL
     Opcode 1100111 : JALR
     Opcode 0110111 : LUI
     Opcode 0010111 : AUIPC
     Opcode 1110011 : SYSTEM  (CSRRW/S/C + I variants, ECALL,
                               MRET)

     Key control signals produced:
       RegWriteD      : 1 = write result to register file in WB
       MemWriteD      : 1 = write to data memory in MEM
       ALUSrcD        : 0 = SrcB from register, 1 = from immediate
       BranchD        : 1 = this is a branch instruction
       JumpD          : 1 = this is JAL/JALR
       ResultSrcD     : selects what goes back to the register
                        (00=ALU result, 01=memory read, 10=PC+4)
       ALUControlD    : 4-bit code telling the ALU what operation
       ImmSrcD        : 3-bit code telling Extend which format
       ALUResultM_selD: overrides the ALU result for LUI/AUIPC
       Branch_Target_selD: 1=PC+imm, 0=rs1+imm (for JALR)
       IsCsrD         : 1 = CSR instruction
       mret_D         : 1 = MRET instruction
       exc_D          : 1 = ECALL exception
       exc_cause_D    : exception cause code (11 for ECALL)

     The ALUDecoder is a sub-module inside control_unit. It takes
     the 2-bit ALUOp from the main decoder and the funct3/funct7
     fields and produces the final 4-bit ALUControlD. This
     two-level decode is the standard Harris & Harris approach.

  C) IMMEDIATE EXTENSION (Extend / k5)
     RISC-V encodes immediates in 5 different scrambled formats
     across the instruction word. Extend reassembles and
     sign-extends them into a full 32-bit value:
       ImmSrc 000 : I-type  (12-bit signed)
       ImmSrc 001 : S-type  (12-bit signed, split field)
       ImmSrc 010 : B-type  (13-bit signed, branch offset)
       ImmSrc 011 : J-type  (21-bit signed, JAL offset)
       ImmSrc 100 : U-type  (upper 20 bits, for LUI/AUIPC)

ID_EX pipeline register (k6):
  - Captures all decode outputs: control signals, RD1, RD2, PC,
    Rs1, Rs2, Rd, ImmExt, PCPlus4, funct3, and the new fields
    IsCsr, mret, exc, exc_cause.
  - On FlushE or rst: inserts a bubble (all control signals = 0,
    Valid = 0). This kills the instruction in EX when a
    branch/jump is taken, a load-use stall fires, or a trap.

------------------------------------------------------------------
STAGE 3: EX -- Execute
Modules: forwarding_mux (k7), ALU (k8), branch_comparator (k14),
         branch_target (k9), csr_file (u_csr), EX_MEM (k10)
------------------------------------------------------------------

This is the most complex stage. Several things happen here:

  A) DATA FORWARDING (forwarding_mux / k7)
     Before the ALU can operate, it needs the latest values of
     Rs1 and Rs2. But a previous instruction might still be in
     MEM or WB and hasn't written its result back yet. The
     forwarding mux solves this:

       ForwardAE = 00 : SrcAE = RD1E        (register file read)
       ForwardAE = 01 : SrcAE = ResultW     (forward from WB)
       ForwardAE = 10 : SrcAE = ALUResultM  (forward from MEM)

     Same 3-way choice for SrcBE (ForwardBE). The hazard unit
     (k19) sets ForwardAE/ForwardBE based on register number
     comparisons.

     SrcBE then has one more mux: if ALUSrcE=1, use the
     sign-extended immediate instead of the (forwarded) register
     value. This is how I-type instructions work.

  B) ALU (k8)
     Takes SrcAE and SrcBE and performs the operation selected
     by the 4-bit ALUControlE:
       0000 : ADD        0001 : SUB
       0010 : AND        0011 : OR
       0100 : SLL        0101 : SRL
       0110 : SRA        0111 : SLT (signed less-than)
       1000 : SLTU       1001 : XOR
     Also produces ZeroE (1 when result == 0), though note that
     branch decisions are NOT made with ZeroE in this design --
     see branch_comparator below.

  C) LUI / AUIPC SPECIAL HANDLING
     LUI and AUIPC do not need the ALU at all. Instead:
       ALUResultM_selE = 01 : pass ImmExtE directly (LUI)
       ALUResultM_selE = 10 : pass PCTargetE = PC+Imm (AUIPC)
       ALUResultM_selE = 00 : normal ALU result
     This selection happens in EX_MEM (see below) so the right
     value arrives in the MEM stage as ALUResultM.

  D) CSR INSTRUCTIONS (csr_file / u_csr)
     When IsCsrE=1, the instruction is a CSR read-modify-write.
     The logic in riscv.v first computes what to write:
       csr_op=01 (CSRRW) : write operand directly
       csr_op=10 (CSRRS) : write csr_rdata | operand (set bits)
       csr_op=11 (CSRRC) : write csr_rdata & ~operand (clear bits)
     csr_useimm (InstrE[14]) selects between rs1 and the 5-bit
     zero-extended immediate as the operand (for the I variants).

     The CSR file holds these machine-mode registers:
       mstatus (0x300) : MIE, MPIE, MPP fields
       misa    (0x301) : ISA register, reset to 0x40000100
       mie     (0x304) : interrupt enable (written but not used
                         for actual interrupt control here)
       mtvec   (0x305) : trap vector base address
       mscratch(0x340) : scratch register for trap handler
       mepc    (0x341) : exception program counter
       mcause  (0x342) : exception cause
       mtval   (0x343) : trap value (bad address, etc.)
       mhartid (0xf14) : hardware thread ID (hardwired 0)

     When a trap fires (trap_set):
       mepc   <= PCE  (save the faulting PC)
       mcause <= cause code
       mtval  <= bad address or 0
       mstatus[7] (MPIE) <= mstatus[3] (MIE)
       mstatus[3] (MIE)  <= 0 (disable interrupts)
       mstatus[12:11] (MPP) <= 11 (came from M-mode)

     When MRET fires (mret_set):
       mstatus[3] (MIE) <= mstatus[7] (MPIE)
       mstatus[7] (MPIE) <= 1

     The final result for the register file comes from:
       ex_result = IsCsrE ? csr_rdata : ALUResultE
     (CSR instructions return the OLD value of the CSR to rd)

  E) BRANCH COMPARATOR (branch_comparator / k14)
     This is separate from the ALU. It directly compares SrcAE
     and SrcBE using the funct3 field to decide if a branch
     should be taken:
       funct3=000 : BEQ  (SrcAE == SrcBE)
       funct3=001 : BNE  (SrcAE != SrcBE)
       funct3=100 : BLT  (signed less than)
       funct3=101 : BGE  (signed greater or equal)
       funct3=110 : BLTU (unsigned less than)
       funct3=111 : BGEU (unsigned greater or equal)

     This is a cleaner design than using the ALU's ZeroE flag for
     branches because it handles all 6 branch types natively
     without needing the ALU to produce a subtraction result.

  F) BRANCH TARGET (branch_target / k9)
     Computes the jump destination:
       Branch_Target_selE=1 : PCTargetE = PCE + ImmExtE
                              (used for branches and JAL)
       Branch_Target_selE=0 : PCTargetE = ALUResultE & ~1
                              (used for JALR: rs1+imm, LSB cleared)

     PCSrcE = Branch | JumpE (either branch taken OR it's a jump)
     When PCSrcE=1, pc_logic redirects to PCTargetE next cycle.

  G) EXCEPTION / MISALIGNMENT DETECTION
     After the branch target is known, the core checks:
       - instr_misaligned_E: branch/jump to a non-4-byte-aligned
         address (PCTargetE[1:0] != 00 when PCSrcE=1)
       - mem_misaligned_E: unaligned word/halfword memory access
         (e.g. LW to address 0x81000001)

     Final exception signals:
       exc_E_final = exc_E | mem_misaligned_E | instr_misaligned_E
       exc_cause is selected: 11=ECALL, 0=instr misaligned,
                              6=store misaligned, 4=load misaligned

     If misalignment is detected, RegWriteE_safe and
     MemWriteE_safe are forced to 0 to prevent the bad
     instruction from writing anything.

EX_MEM pipeline register (k10):
  - Captures ALUResultM (with LUI/AUIPC override applied here),
    WriteDataM (the store data), RdM, PCPlus4M, funct3M, etc.
  - This is also where the ALUResultM_sel mux lives, choosing
    between: normal ALU result, immediate (LUI), or PC+imm (AUIPC).

------------------------------------------------------------------
STAGE 4: MEM -- Memory Access
Modules: data_memory (k11), load_control_unit (k20), MEM_WB (k12)
------------------------------------------------------------------

  A) DATA MEMORY (data_memory / k11)
     For store instructions (MemWriteM=1), writes to memory at
     address ALUResultM. The funct3 field selects width:
       funct3=000 (SB) : write 1 byte
       funct3=001 (SH) : write 2 bytes (halfword)
       funct3=010 (SW) : write 4 bytes (word)
     For loads, simply reads 32 bits from address ALUResultM.
     (Sub-word extraction for loads happens in load_control_unit.)

  B) LOAD CONTROL UNIT (load_control_unit / k20)
     The raw 32-bit memory read (RD) needs to be trimmed and
     sign/zero-extended for sub-word loads. It uses
     ALUResultM[1:0] (byte offset within the word) and funct3:
       funct3=000 (LB)  : sign-extend 1 byte
       funct3=001 (LH)  : sign-extend 2 bytes
       funct3=010 (LW)  : full 32-bit word, no change
       funct3=100 (LBU) : zero-extend 1 byte
       funct3=101 (LHU) : zero-extend 2 bytes

MEM_WB pipeline register (k12):
  - Captures ALUResultM, ReadDataM (processed load data),
    PCPlus4M, RdM, RegWriteM, ResultSrcM, and the debug signals
    (PCM, InstrM, MemWriteM, WriteDataM) that appear as chip
    outputs.

------------------------------------------------------------------
STAGE 5: WB -- Writeback
Modules: result_mux (k13), register_file (k3, write port)
------------------------------------------------------------------

  A) RESULT MUX (result_mux / k13)
     Selects what value gets written back to the register file:
       ResultSrcW=00 : ALUResultW  (R/I-type result, LUI, AUIPC)
       ResultSrcW=01 : ReadDataW   (load result from memory)
       ResultSrcW=10 : PCPlus4W    (PC+4, return address for
                                    JAL/JALR)

  B) REGISTER FILE WRITE (register_file / k3, write port)
     If RegWriteW=1 and RdW!=0, ResultW is written to
     register[RdW] on the falling edge of the clock.


==================================================================
SECTION 3 -- HAZARD UNIT (hazard_unit / k19)
==================================================================

The hazard unit is the "traffic controller" of the pipeline. It
runs purely combinationally and produces stall/flush/forward
signals every cycle based on what instructions are in each stage.

DATA HAZARDS -- FORWARDING:
  If an instruction in EX needs a value that is being produced
  by the instruction currently in MEM (one cycle ahead in WB):
    Rs1E == RdM and RegWriteM --> ForwardAE = 10 (from MEM)
    Rs1E == RdW and RegWriteW --> ForwardAE = 01 (from WB)
    otherwise                 --> ForwardAE = 00 (from regfile)
  Same logic for ForwardBE.

DATA HAZARDS -- LOAD-USE STALL:
  A load instruction produces its result one cycle later than
  an ALU instruction because it has to wait for the memory read.
  If the instruction right after a load tries to use the loaded
  value, forwarding alone cannot save it (the data isn't ready
  yet). So:
    lwstall = ResultSrcE[0] & ((Rs1D==RdE) | (Rs2D==RdE)) & (RdE!=0)
  When lwstall=1:
    StallF=1, StallD=1  --> PC and IF_ID freeze for one cycle
    FlushE=1            --> ID_EX gets a bubble (kills the
                           instruction that tried to use the
                           load result too early)

CONTROL HAZARDS -- BRANCH/JUMP FLUSH:
  Branches and jumps are resolved in EX. By then, two
  instructions that shouldn't execute have already entered IF
  and ID. So when PCSrcE=1:
    FlushD=1 --> kills the instruction in IF/ID register
    FlushE=1 --> kills the instruction in ID/EX register
  This is a 2-cycle branch penalty, which is normal for a
  pipeline that resolves branches in EX.

TRAP / MRET FLUSH:
  When trap_take=1 or mret_redirect=1, the same FlushD and
  FlushE are asserted to drain the wrong-path instructions
  before jumping to mtvec or mepc.

  Note: lwstall is suppressed (not applied) when a trap or
  mret is simultaneously active, since the pipeline is being
  redirected anyway and the stall would be pointless.


==================================================================
SECTION 4 -- VALID BIT TRACKING
==================================================================

Every pipeline register carries a Valid bit (Valid_F, Valid_D,
Valid_E, Valid_M, Valid_W). This bit is 0 for bubbles
(NOPs inserted by flush) and 1 for real instructions.

Key uses:
  - mret_redirect = mret_E & Valid_E
    (MRET only actually redirects the PC if it's a real instr)
  - trap_take = exc_E_final & Valid_E
    (exceptions only fire for valid instructions)
  - CsrWriteE gated by Valid_E
    (CSRs are only modified by real instructions)
  - The debug outputs (Valid_W, PCW, InstrW, etc.) let external
    hardware track exactly which instructions have committed.


==================================================================
SECTION 5 -- INSTRUCTIONS SUPPORTED (COMPLETE LIST)
==================================================================

R-TYPE (opcode 0110011):
  ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU

I-TYPE ARITHMETIC (opcode 0010011):
  ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU

LOAD (opcode 0000011):
  LB, LH, LW, LBU, LHU

STORE (opcode 0100011):
  SB, SH, SW

BRANCH (opcode 1100011):
  BEQ, BNE, BLT, BGE, BLTU, BGEU

JUMP:
  JAL  (opcode 1101111)
  JALR (opcode 1100111)

UPPER IMMEDIATE:
  LUI  (opcode 0110111) -- load upper immediate
  AUIPC(opcode 0010111) -- add upper immediate to PC

SYSTEM (opcode 1110011):
  CSRRW, CSRRS, CSRRC       -- CSR read-write/set/clear
  CSRRWI, CSRRSI, CSRRCI    -- immediate forms
  ECALL                     -- environment call (cause 11)
  MRET                      -- return from machine-mode trap


==================================================================
SECTION 6 -- DATA PATH SUMMARY (signal flow)
==================================================================

  [External Instr Memory]
         |
         | instr_data (32-bit)
         v
  [pc_logic] --PCF--> [IF_ID] --InstrD, PCD--> [Register_file]
                                              --> [control_unit]
                                              --> [Extend]
                                                     |
                                              [ID_EX register]
                                                     |
                            [forwarding_mux] <--RD1E, RD2E
                                    |
                              SrcAE, SrcBE
                                    |
                                  [ALU] ---------> ALUResultE
                                    |
                         [branch_comparator] ---> Branch
                         [branch_target]     ---> PCTargetE
                         [csr_file]          ---> csr_rdata
                                    |
                              [EX_MEM register]
                                    |
                         ALUResultM, WriteDataM
                                    |
                           [data_memory] -----> RD
                           [load_control_unit]-> ReadDataM
                                    |
                              [MEM_WB register]
                                    |
                             [result_mux] -----> ResultW
                                    |
                           [Register_file] <---- write port
                                    |
                           (also forwarded back to
                            forwarding_mux in EX)


==================================================================
SECTION 7 -- WHAT MAKES THIS CORE NOTABLE
==================================================================

1. SEPARATE BRANCH COMPARATOR
   Most textbook cores reuse the ALU (subtract and check zero)
   for branches. This core has a dedicated branch_comparator
   that handles all 6 RISC-V branch conditions natively. This
   is slightly more hardware but cleaner and avoids misusing
   the ZeroE flag.

2. NEGATIVE-EDGE REGISTER WRITE
   Writing the register file on negedge clk while reading on
   combinational paths effectively gives a half-cycle write then
   read, which reduces WB-to-ID hazards without an extra
   forwarding path. This is intentional and correct as long as
   the register file setup/hold is met.

3. ALUResultM_sel MUX
   Instead of routing LUI and AUIPC through the ALU (which would
   require special ALU opcodes), this core routes their results
   through a 3-way mux in the EX_MEM register: the ALU result,
   the immediate (for LUI), or PC+imm (for AUIPC). Clean and
   efficient.

4. FULL M-MODE TRAP INFRASTRUCTURE
   For a student/academic core this is quite advanced. It has a
   proper CSR file with mstatus, mtvec, mepc, mcause, mtval,
   and correctly handles mstatus.MIE/MPIE save-restore across
   traps and MRET. Misaligned instruction and memory access
   exceptions are detected and cause codes set per the RISC-V
   privileged spec.

5. VALID BIT GATING
   Every trap and CSR write is gated by Valid_E. This prevents
   pipeline bubbles (NOPs inserted during stalls or flushes)
   from accidentally triggering traps or writing CSRs. This is
   exactly the right way to handle it.

==================================================================
END OF DOCUMENT
==================================================================
