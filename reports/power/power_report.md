# Power — RISC-V

**Source:** SCL internship report, Chapter 7.5, Genus power report (PDF pages 61–62).

## Genus

```text
Instance: /riscv
Power Unit: W

Category       Leakage        Internal      Switching        Total
register       3.02823e-06    1.23389e-03   1.43514e-04   1.38043e-03
logic          5.70035e-07    2.66209e-04   2.15002e-04   4.81781e-04
Subtotal       3.59826e-06    1.50010e-03   3.58515e-04   1.86221e-03
```

**Reported Genus total power: `1.86221e-03 W`.**

## Innovus caution

The Innovus power block immediately following the RISC-V Genus section contains the same numerical values and UART-specific identifiers as the UART report section (`tx_inst_tx_reg`, 339 instances). It is therefore treated as a report-copy artifact and is **not published as a validated RISC-V Innovus power result**.

This is intentionally called out because a technically credible repository should not silently promote a suspect report block into a project metric.
