# Public-Repository Publication Audit

## Included
- Supplied RISC-V core RTL snapshot.
- Generic-placeholder `chip_top.v`.
- Sanitized implementation screenshots.
- Documentation derived from the supplied SCL report.
- Extracted, non-proprietary pad-count and side-distribution summary.
- The supplied memory-synthesis engineering note.

## Intentionally omitted
- `riscv_chip_top.v`: directly instantiates PDK-specific IO cells.
- Raw `riscv.io`, `riscv1.io`, and `riscv_chip_top.io`: contain PDK-specific implementation details and pad-cell mappings.
- LEF/DEF/GDS/OASIS/technology files: none supplied, and such artifacts are not appropriate for a public repository without explicit redistribution rights.
- Standard-cell and IO libraries.
- Cadence/Synopsys installation databases and generated working directories.
- Full SCL internship report PDF.
- Original screenshots: visible workstation paths/hostnames were present.

## Verification note

The screenshots were inspected for obvious workstation paths/hostnames. Public copies are cropped to remove those regions. This is a portfolio-oriented sanitization step, not a legal/NDA determination; SCL/employer publication permission should still be confirmed before public release.
