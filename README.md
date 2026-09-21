# RISC-V ASIC Physical Design

A public-facing engineering record of ASIC implementation and physical-design work on a **32-bit, five-stage pipelined RISC-V processor** using Cadence Genus and Cadence Innovus during the SCL internship.

> **Scope note:** The supplied material contains the processor RTL plus implementation evidence. This repository therefore distinguishes the supplied/upstream RTL from the ASIC implementation activity. It does not claim authorship of the original processor RTL unless that is directly established by the supplied material.

## Overview

The SCL internship report describes a five-stage pipelined RISC-V processor based on the RV32I instruction-set architecture. The reported implementation flow covered synthesis in Cadence Genus and physical implementation in Cadence Innovus, including floorplanning, placement, clock-tree synthesis, routing, post-route optimization, area/power analysis, memory-macro integration, I/O pad integration, and preparation for GDSII generation.

The report describes both a core-only implementation and a later chip-level configuration with memory macros and I/O pads.

## Objective

The implementation exercise was used to gain practical exposure to ASIC realization of a non-trivial pipelined processor and to the transition from verified RTL to a physically implemented design.

## Design Under Test

- Architecture: RV32I
- Datapath: 32-bit
- Pipeline: IF / ID / EX / MEM / WB
- Functional blocks visible in the supplied RTL include:
  - ALU / ALU decoder
  - register file
  - control logic
  - branch comparator / target logic
  - hazard detection and forwarding
  - pipeline registers
  - CSR file
  - data-memory interface
  - write-back/result selection

The supplied RTL snapshot contains these modules under `rtl/`.

## Tools & Technology

| Item | Evidence |
|---|---|
| Cadence Genus | SCL report |
| Cadence Innovus | SCL report and supplied screenshots |
| Synopsys Design Compiler | Mentioned in the SCL report as part of internship exposure |
| Technology library | `tsl18fs120_scl_ss_1` appears in the reported Genus RISC-V area/power section |
| Process context | SCL report describes a 180 nm CMOS process |

The public repository intentionally does **not** contain the PDK, standard-cell libraries, IO libraries, memory macros, or EDA installation assets.

## ASIC Flow

![RTL-to-GDSII flow](docs/rtl-to-gdsii.svg)

1. RTL
2. Functional verification
3. Logic synthesis
4. Floorplanning
5. Placement
6. Clock-tree synthesis
7. Routing
8. Post-route optimization
9. Physical verification / timing analysis
10. GDSII preparation or export

The report explicitly describes Genus synthesis followed by Innovus backend implementation.

## 1. RTL

The supplied RTL snapshot is retained under `rtl/`. The original filenames are preserved.

No attempt has been made to rewrite the RTL to make it look like a newly authored design.

## 2. Synthesis

Cadence Genus was used to map the processor RTL to the SCL standard-cell technology library.

The report identifies:
- library: `tsl18fs120_scl_ss_1`
- operating condition: `_nominal_ (balanced_tree)`
- wireload mode: `enclosed`
- area mode: `timing library`

A reported Genus total power value is included in `results/summary.md`.

## 3. Floorplanning

The report states that the synthesized processor was imported into Innovus and physically implemented. The supplied screenshots include core/chip-level Innovus views.

## 4. Placement

Standard-cell placement formed part of the reported backend flow.

## 5. CTS

Clock-tree synthesis was part of the reported Innovus implementation flow.

## 6. Routing

Routing was performed as part of the reported backend flow, followed by post-route optimization.

## 7. Post-Route Optimization

The SCL report states that `optDesign` was used where required to improve timing performance.

## 8. Timing Analysis

The report describes timing-constrained implementation, but the supplied report section does **not** provide a clean numerical RISC-V WNS/TNS/setup/hold result that can be safely published here.

Accordingly:
- WNS: not available in the supplied evidence
- TNS: not available in the supplied evidence
- setup violations: not available
- hold violations: not available
- clock period: not available as a final RISC-V result

No timing number has been invented.

## 9. Physical Verification

The report states that DRC was part of the ASIC implementation methodology. A numerical RISC-V DRC result is not clearly supplied in the RISC-V result section.

Therefore this repository does not claim a numerical RISC-V DRC count.

## 10. GDSII

The report states that completed layouts were prepared for GDSII generation. No GDSII database was supplied with the public-source package, so no GDS file is included here.

## Memory Macro Integration

The report explicitly states that the final RISC-V implementation incorporated memory macros.

However, the supplied Innovus area excerpt shows:

- `k11` / `data_memory`: **0 instances** in the displayed area table.

This is retained as a source discrepancy rather than being silently reconciled. The repository therefore documents **reported memory-macro integration**, but does not claim a specific macro count, macro name, or macro area from the available evidence.

The supplied `data_memory_synthesis_issue` note also documents a behavioral memory-array synthesis problem and recommends replacing a large behavioral array with a foundry SRAM macro for tapeout. That note is included under `docs/notes/`.

## I/O Pad Integration

The supplied `riscv_chip_top.io` file provides a concrete chip-level pad-ring definition.

### Extracted pad-ring facts

| Item | Supplied evidence |
|---|---:|
| Total pads | 265 |
| Signal pads | 234 |
| VDD pads | 15 |
| VSS pads | 16 |
| Clock input pads | 1 |
| Reset input pads | 1 |
| Instruction-data input bus | 32 |
| Instruction-address output bus | 32 |
| Other output/debug signals | 169 |

### Clockwise side distribution

| Side | Signal pads | Power/ground pads | Total |
|---|---:|---:|---:|
| Bottom | 34 | 6 | 40 |
| Right | 65 | 8 | 73 |
| Top | 70 | 9 | 79 |
| Left | 65 | 8 | 73 |
| **Total** | **234** | **31** | **265** |

The raw `.io` files and PDK-specific pad-cell source are intentionally omitted from this public package. The values above are extracted from them.

## Results

### Published implementation snapshot

| Metric | Value | Notes |
|---|---:|---|
| Reported Genus library | `tsl18fs120_scl_ss_1` | RISC-V report section |
| Genus total power | `1.86221e-03 W` | Directly reported |
| Innovus instance count | `6525` | `report_area` |
| Innovus total area | `226623.040` | `report_area` |
| `k11` / `data_memory` instances | `0` | Displayed area excerpt |
| WNS/TNS | Not available | Not reported cleanly |
| DRC count | Not available | Not reported cleanly for RISC-V |
| LVS | Not available | No numerical/status evidence supplied |

### Important report-integrity note

The Innovus power block printed in the RISC-V section is numerically identical to the UART section and includes UART-specific identifiers such as `tx_inst_tx_reg`. It is therefore treated as a likely report-copy artifact and **is not used as a validated RISC-V power result** in this repository.

## Screenshots

Sanitized screenshots are stored under `images/physical_design/` and `images/io_memory/`.

The supplied screenshots were cropped to remove visible SCL workstation paths/hostnames from title bars and console regions. Original screenshots are intentionally not redistributed.

## Repository Structure

```text
riscv-asic-physical-design/
├── README.md
├── LICENSE
├── .gitignore
├── rtl/
├── docs/
│   ├── rtl-to-gdsii.svg
│   ├── source_reference.md
│   ├── publication_audit.md
│   └── notes/
├── images/
│   ├── physical_design/
│   └── io_memory/
├── reports/
│   ├── synthesis/
│   ├── timing/
│   ├── area/
│   ├── power/
│   └── physical_verification/
├── scripts/
│   └── README.md
└── results/
    └── summary.md
```

## Reproduction / Usage

A full rerun cannot be performed from this public repository alone because the supplied implementation depended on SCL infrastructure, proprietary technology libraries/PDKs, and Cadence installation assets that are not redistributed.

The intended conceptual order is:

```text
source RTL
   ↓
Genus setup + constraints
   ↓
synthesis / reports / gate-level netlist
   ↓
Innovus initialization
   ↓
floorplan → power plan → placement
   ↓
CTS → routing → post-route optimization
   ↓
timing / area / power / physical verification
   ↓
GDSII preparation
```

Actual Genus/Innovus command scripts were **not** supplied in the uploaded material, so this repository does not fabricate runnable scripts.

## Limitations

- Proprietary SCL/PDK material is excluded.
- PDK-specific IO wrapper RTL is excluded.
- Raw `.io` files are excluded from the public package.
- No GDSII database was supplied.
- No final WNS/TNS/setup/hold values were supplied for RISC-V.
- No clean numerical RISC-V DRC/LVS signoff result was supplied.
- SPI RTL/scripts are not relevant to this repository and are therefore not included.

## Credits / Source

The implementation evidence comes from the supplied SCL internship report and the source/screenshot material provided for this repository build.

The report describes the internship work in the Digital Design and Verification Group at SCL and identifies the RISC-V implementation as part of the Cadence Genus/Innovus ASIC-flow work.
