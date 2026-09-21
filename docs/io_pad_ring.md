# RISC-V I/O Pad Ring — Evidence-Derived Record

The chip-level pad ring was reconstructed from the supplied `riscv_chip_top.io` file. The raw `.io` file is intentionally **not** published because it contains PDK-specific pad-cell information.

## Pad inventory

| Pad class | Count |
|---|---:|
| Signal pads | 234 |
| VDD pads (`pvdc`) | 15 |
| VSS pads (`pv0c`) | 16 |
| Clock/reset pads (`pc3d21`) | 2 |
| Digital output pads (`pc3o02`) | 200 |
| Digital input pads (`pc3b02`) | 32 |
| **Total** | **265** |

The signal-pad count is 234; the remaining 31 pads are power/ground.

## Clockwise side distribution

| Side | Signal pads | VDD | VSS | Total |
|---|---:|---:|---:|---:|
| Bottom | 34 | 3 | 3 | 40 |
| Right | 65 | 4 | 4 | 73 |
| Top | 70 | 4 | 5 | 79 |
| Left | 65 | 4 | 4 | 73 |
| **Total** | **234** | **15** | **16** | **265** |

## Signal grouping

- Bottom: `clk`, `rst`, `instr_data[31:0]`
- Right: `instr_addr[31:0]`, `Valid_W`, `PCW[31:0]`
- Top: `InstrW[31:0]`, `RegWriteW`, `RdW[4:0]`, `ResultW[31:0]`
- Left: `MemWriteW`, `ALUResultW[31:0]`, `WriteDataW[31:0]`

The supplied pad-plan note identifies 234 functional top-level pins and states that no bidirectional top-level bus is required for the current design.

**Source:** supplied SCL internship material, chip-level IO file and pad-plan note; report Section 7.5.
