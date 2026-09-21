# RISC-V Implementation Results

| Category | Metric | Value | Evidence |
|---|---|---:|---|
| Synthesis | Genus technology library | `tsl18fs120_scl_ss_1` | SCL report Ch. 7.5 |
| Synthesis | Genus total power | `1.86221e-03 W` | SCL report Ch. 7.5 |
| Physical design | Innovus instances | `6525` | Innovus `report_area` in report |
| Physical design | Innovus total area | `226623.040` | Innovus `report_area` in report |
| IO | Functional signal pads | `234` | supplied chip-level IO evidence |
| IO | VDD pads | `15` | supplied chip-level IO evidence |
| IO | VSS pads | `16` | supplied chip-level IO evidence |
| IO | Total pads | `265` | supplied chip-level IO evidence |
| Timing | WNS/TNS | Not available | no clean final RISC-V values supplied |
| Verification | DRC/LVS | Not available | no clean final RISC-V values supplied |

## Engineering interpretation

The strongest publishable evidence is the complete implementation flow, the 6525-instance/226623.040-area Innovus result, the Genus power result, and the concrete 265-pad chip-level IO definition. Timing and signoff numbers are deliberately left open rather than manufactured.
