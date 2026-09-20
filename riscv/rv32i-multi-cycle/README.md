# RV32I Multi-Cycle Processor

A learning project for building an RV32I multi-cycle processor in SystemVerilog.

## Status

Instruction register, program counter, operand register, and ALU result register RTL and their
self-checking testbenches are implemented.
The ADD datapath connects the operand registers, adder, and result register.
Its testbench checks staged capture, result retention, and 32-bit wraparound.
The ADD controller state sequence and write-enable outputs are implemented
and tested, including reset suppression and repeated
FETCH/DECODE/EXECUTE/WRITEBACK cycles.

`rv32i_core` directly integrates PC, IR, register file, ADD controller, and ADD
datapath. The first milestone supports ADD only, with a combinational external
instruction-memory interface. PC advances by four at the WRITEBACK edge.
Unsupported instructions assert `unsupported_instruction` during WRITEBACK,
skip register writes, and advance PC; architectural trap handling is not yet
implemented. Register file contents are not reset (x0 always reads zero).

The core test initializes registers in the testbench and checks dependent ADDs,
x0 protection, overflow, IR retention, writeback timing, unsupported instructions,
and reset cancellation.

## Simulation

Install Icarus Verilog (includes `iverilog` and `vvp`) and Make on Ubuntu:

```sh
sudo apt-get update
sudo apt-get install -y iverilog make
```

From this directory, run:

```sh
make test
```

The register tests check synchronous reset, reset priority,
enabled writes, and data retention when writes are disabled. Failures stop
simulation with a nonzero exit status.

## Layout

- `rtl/`: processor modules
- `tb/`: testbenches
- `programs/`: assembly test programs and memory images

## First milestone

Implement ADD using four states: FETCH, DECODE, EXECUTE, and WRITEBACK.
