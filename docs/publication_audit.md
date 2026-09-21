# Public-Repository Audit

## Included

- Supplied RISC-V core RTL snapshot
- Evidence-derived pad-ring summary
- SCL-report-derived implementation and result documentation
- Sanitized physical-design screenshots
- Reconstructed Genus/Innovus reference scripts

## Intentionally omitted

- SCL PDKs and standard-cell libraries
- IO LEF / library databases
- Memory macro LEF/GDS/database files
- Raw `.io` pad-ring files
- Cadence installation files and generated databases
- Internal absolute paths, hostnames and infrastructure identifiers
- GDS/DEF databases not supplied for public redistribution

## Why

These artifacts are either proprietary technology collateral, internal infrastructure details, or generated implementation databases. The repository retains enough public evidence to explain the engineering work without publishing the underlying SCL design environment.

The PDK-specific chip-level wrapper was intentionally omitted because it instantiates technology-specific IO cells directly. The pad-ring is documented textually instead.
