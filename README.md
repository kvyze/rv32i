# RV32I Processor

A custom RISC-V RV32I processor implemented in SystemVerilog, targeting the Sipeed Tang Nano 9K FPGA development board.

## Overview

This project implements a custom 32-bit RISC-V processor core using SystemVerilog. The design is intended to run on the Gowin Tang Nano 9K FPGA.

## Architecture

The processor currently consists of the following modules:

- `cpu.sv` — Processor core
- `alu.sv` — Arithmetic Logic Unit
- `control.sv` — Control Unit
- `immediate.sv` — Immediate value generation
- `pc.sv` — Program Counter
- `regfile.sv` — Register File
- `ram.sv` — RAM module
- `rom.sv` — ROM module

## Implementation Status

The core RV32I instruction set has been implemented, with the following instructions still pending:

- `FENCE`
- `ECALL`
- `EBREAK`

The project will be extended with additional functionality, including FPGA deployment, UART communication, and support for running bare-metal software.

## Target Hardware

- **FPGA:** Sipeed Tang Nano 9K
- **HDL:** SystemVerilog
- **Development Tools:** Gowin EDA

## Planned Features

- Complete the remaining RV32I instructions.
- Verify processor behavior through simulation.
- Deploy the processor to the Tang Nano 9K.
- Implement UART communication.
- Develop a bootloader and support for bare-metal programs.
- Explore custom operating system development.
