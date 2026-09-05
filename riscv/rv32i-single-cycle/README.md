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
- Load/store unit
- Program counter and next-PC logic
- CPU datapath integration
- Instruction and data memory models
- End-to-end CPU testbench

The core implements all 40 RV32I base instructions. The end-to-end integration
program covers the arithmetic, logical, branch, jump, load, store, upper-
immediate, and FENCE instructions. It reports completion by writing a pass/fail
signature to data memory.

`FENCE` is a legal no-op in this single-cycle in-order memory system. `ECALL`,
`EBREAK`, illegal instructions, and address-misalignment conditions are exposed
as exception-request outputs for the execution environment. They do not yet
redirect execution to a privileged trap handler.

Still to implement:

- Privileged trap handling and exception redirection
- System instructions and CSRs
- Interrupts

CSR instructions, privileged execution, and interrupts are not included yet.

## Architecture

```text
                 +--------------------+
 PC/address ---->| Instruction memory |---- instruction ----+
                 +--------------------+                     |
                                                            v
 +-----------------------------------------------------------------------+
 | RV32I core                                                            |
 |                                                                       |
 |  PC -> decoder/immediate -> register file -> operand muxes -> ALU     |
 |   ^                              |                         |           |
 |   |                              +-> branch comparator     |           |
 |   |                                                        v           |
 |   +---------------- next-PC logic <---------------- branch/jump target |
 |                                                            |           |
 |                  register file <- writeback mux <- LSU <----+           |
 +-----------------------------------------------------------------------+
                               |                      ^
                               | address/write/BE     | read data
                               v                      |
                         +-------------------+
                         | Data memory       |
                         +-------------------+
```

The program counter, register file, and data memory are the architectural
state. The decoder, immediate generator, ALU, comparators, multiplexers, LSU,
and next-PC logic are combinational in this implementation.

## Memory timing model

- Instruction memory uses zero-wait-state combinational reads.
- Data memory uses zero-wait-state combinational reads.
- Data-memory writes occur on the rising clock edge.
- Store byte lanes are selected by a four-bit byte-enable signal.
- The LSU performs subword selection, store-data alignment, and load extension.
- The supplied memory models do not provide ready/valid handshaking.

These assumptions make every instruction complete in one clock cycle. They are
appropriate for simulation and small FPGA memories, but are not a general
external-memory bus protocol.

## Current limitations

- No stalls or variable-latency memory transactions.
- No privileged modes, CSRs, interrupts, or trap-vector redirection.
- Misaligned accesses are rejected rather than emulated.
- Exception requests are reported to the execution environment; execution is
  not redirected to a handler.
- No compressed, multiply/divide, atomic, or other optional ISA extensions.

## Run tests

Requirements:

- Icarus Verilog with SystemVerilog support

Regenerating the integration-program image also requires the GNU RISC-V
bare-metal assembler, linker, and objcopy tools.

Run every testbench:

```sh
make test
```

Regenerate the checked-in integration-program image:

```sh
make program
```
