# SCL Report — Implementation Evidence Extracts

This file is the public engineering digest of the implementation sections of the supplied SCL internship report. It preserves the report's terminology and page references while removing confidential infrastructure details.

## RTL-to-GDSII methodology — report pages 39–42

The report describes the implementation sequence as RTL development/verification, Cadence Genus synthesis, then Cadence Innovus physical design. The Genus methodology lists RTL loading, elaboration, clock definition, external delays, design checking, generic synthesis, mapping, optimization, timing/power reporting, and export of the gate-level netlist and SDC. The Innovus methodology lists initialization, floorplanning, power planning, placement, CTS, routing, `optDesign` post-route optimization, DRC, and GDSII export.

## RISC-V — report pages 57–64

The report describes a 32-bit RV32I five-stage pipeline with IF/ID/EX/MEM/WB stages, hazard detection, forwarding, branch handling, CSR support, and both core-only and I/O-pad-integrated physical implementation. It states that memory macros and I/O pad cells were integrated in the final implementation.

Reported measurements:

- Genus total power: `1.86221e-03 W`
- Innovus instances: `6525`
- Innovus area: `226623.040`

The RISC-V Innovus power block is excluded from the validated metric set because it contains UART-specific identifiers and values.

## UART — report pages 49–56

The report describes a full-duplex configurable UART with transmitter, receiver, programmable baud generation, oversampling, and frame-error detection. It states that both core-only and I/O-pad-integrated implementations were performed.

Reported measurements:

- Genus total power: `7.39923e-05 W`
- Innovus instances: `339`
- Innovus area: `9994.432`
- Innovus total power: `0.57686031` (unit not stated in the excerpt)

## SPI — report pages 65–70

The report describes a configurable SPI master with clock generation, FSM, shift register, bit counter, programmable divider, and CPOL/CPHA support.

Reported measurements:

- Genus total power: `3.60721e-04 W`
- Innovus instances: `237`
- Innovus area: `6043.072`
- Innovus total power: `0.41032857` (unit not stated in the excerpt)

## Physical-verification evidence

The report explicitly records DRC, connectivity checking and GDSII preparation as stages of the implementation flow. A clean numerical DRC result is directly reproduced in the counter report; no equivalent RISC-V/UART/SPI DRC number is asserted here unless explicitly present in the corresponding source evidence.
