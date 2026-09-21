# Architecture Notes

The supplied report describes the processor as a 32-bit RV32I five-stage pipeline:

`IF → ID → EX → MEM → WB`

The RTL snapshot includes the ALU, ALU decoder, register file, control unit, branch logic, hazard unit, pipeline registers, CSR file, data-memory interface and result selection logic.

The architecture diagram in the root README is intentionally a conceptual documentation diagram; the RTL under `rtl/` remains the authoritative implementation artifact supplied for this repository.
