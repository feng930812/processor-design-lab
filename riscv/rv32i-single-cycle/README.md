# RV32I Single-Cycle Processor

A from-scratch RV32I processor implemented in SystemVerilog. Each component
is developed separately and checked with a self-checking testbench before CPU
integration.

## Current status

Implemented and tested:

- ALU
- Register file
- Immediate generator
- Branch comparator
- Instruction decoder

Still to implement:

- Load/store unit
- Program counter and next-PC logic
- CPU datapath integration
- Instruction and data memory models
- End-to-end CPU testbench

The current scope covers the core RV32I integer instructions. `FENCE`, system
instructions, CSRs, exceptions, and interrupts are not included yet.

## Run tests

Requirements:

- Icarus Verilog with SystemVerilog support

Run every testbench:

```sh
make test
```

