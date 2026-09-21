# Innovus Area — RISC-V

**Source:** SCL internship report, Chapter 7.5, Innovus area report (PDF page 64).

```text
innovus 12> report_area

Hinst Name          Module Name       Inst Count       Total Area
-------------------------------------------------------------------
riscv                                6525             226623.040
  k11               data_memory          0                  0.000
```

## Published values

| Metric | Value |
|---|---:|
| Innovus instance count | **6525** |
| Innovus total area | **226623.040** |
| Displayed `data_memory` instance count | **0** |

The displayed `data_memory = 0` entry is preserved exactly rather than interpreted as proof that no memory macro was integrated, because the surrounding report narrative separately states that memory macros were integrated in the final chip-level implementation.
