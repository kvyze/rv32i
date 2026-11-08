# RV32I Processor

A multi-cycle **RISC-V RV32I** processor written in SystemVerilog, running on the **Sipeed Tang Nano 9K** FPGA board.

This is my first hardware project, and my first project in this field at all. I'm publishing it to share the experience and the path I took to build it, and to show the result: a working CPU that runs C code compiled with a standard RISC-V toolchain and prints `Hello World!` over UART.

> **Status:** work in progress. Not every instruction has been thoroughly tested yet, so bugs are possible. They will be fixed over time.

---

## Features

- RV32I base integer instruction set
- Multi-cycle microarchitecture driven by a finite state machine (FSM)
- Byte, halfword and word loads and stores (with sign/zero extension)
- Unified 32 KB memory (RAM + ROM) with a memory-mapped UART transmitter
- Runs programs written in C (built with `riscv-none-elf-gcc`)
- Simulation with Icarus Verilog and GTKWave
- Runs on real hardware (Sipeed Tang Nano 9K)

## Supported instructions

All RV32I instructions are implemented **except**:

| Instruction | Status |
|-------------|--------|
| `fence`     | not implemented |
| `fence.tso` | not implemented |
| `pause`     | not implemented |
| `ecall`     | not implemented |
| `ebreak`    | not implemented |

Some of the implemented instructions have not been tested yet.

## Architecture

The processor executes each instruction in several clock cycles. There is **no fixed number of cycles per instruction**: different instructions go through different FSM states and therefore take different amounts of time.

The control unit FSM has these states:

```
FETCH -> FETCH2 -> CALC_PC -> EXECUTE -> MEM_LOAD -> WRITEBACK
```

| Instruction class                 | Cycles |
|-----------------------------------|--------|
| Arithmetic, `lui`, stores         | 5      |
| Branches, `auipc`, `jal`, `jalr`  | 4      |
| Loads (`lb`, `lbu`, `lh`, `lhu`, `lw`) | 6 (the longest) |

Writing a byte to the UART transmitter is much slower: it takes **2340 cycles** (10 bits per frame x 234 cycles per bit).

### Modules

| Module            | Description |
|-------------------|-------------|
| `cpu`             | Top-level module that connects everything together |
| `control_unit`    | FSM that sequences fetch / execute / memory / writeback |
| `decoder`         | Decodes the instruction into control signals |
| `immediate`       | Immediate value generator (I, S, B, U, J formats) |
| `alu`             | Arithmetic/logic unit and comparisons |
| `regfile`         | 32 x 32-bit register file (`x0` is hardwired to zero) |
| `internal_regs`   | Internal registers: instruction register (IR), instruction pointer (IP), ALU output register |
| `memory`          | Byte-addressable memory built from four byte lanes |
| `uart_tx`         | UART transmitter |
| `types`           | Package with shared enums and types |

## Memory map

The processor has 32 KB of memory in total, plus a memory-mapped UART transmitter:

| Region   | Address range                | Description |
|----------|------------------------------|-------------|
| RAM      | `0x00000000` - `0x00003FFF`  | Data memory (read/write) |
| ROM      | `0x00004000` - `0x00007FFF`  | Program memory (read-only for stores). The instruction pointer starts at `0x4000` after reset |
| UART_TX  | `0x00008000`                 | Store a byte here to transmit it over UART |

## UART

- Speed: **115200 baud**, 8 data bits, no parity, 1 stop bit (8N1)
- The transmitter generates one tick every **234 CPU clock cycles**
- To send a character, the program stores it to address `0x8000`; the `busy` output signals that a transmission is in progress

## Repository structure

```
src/          SystemVerilog sources of the processor
src/tb/       Testbenches (ALU, decoder, immediate, regfile, UART, CPU, ...)
src/uart/     UART transmitter
crt0/         Startup code / linked program image (main.hex)
program/      C programs that run on the processor (hello_world.c)
asm/          Assembly programs
Makefile      Build and simulation commands
LICENSE       MIT license
```

## Requirements

- [Icarus Verilog](https://github.com/steveicarus/iverilog) - simulation
- [GTKWave](https://gtkwave.sourceforge.net/) - waveform viewer
- `riscv-none-elf-gcc` - RISC-V toolchain for compiling C code
- `make`
- [Gowin EDA](https://www.gowinsemi.com/en/support/download_eda/) - synthesis and flashing for Tang Nano 9K (only needed for hardware)

## Build and simulate

Everything is wrapped into a Makefile:

| Command     | What it does |
|-------------|--------------|
| `make`      | Builds the C code into a `.hex` file, builds the simulation and opens GTKWave |
| `make sim`  | Builds the simulation and opens GTKWave |
| `make hex`  | Builds the C code into a `.hex` file |
| `make clean`| Removes build artifacts |

The processor loads its program from the `.hex` file via `$readmemh` at the start of the simulation.

## Running on the Tang Nano 9K

1. Build the `.hex` file with `make hex`.
2. Create a Gowin EDA project for the **Sipeed Tang Nano 9K** and add the sources from `rtl/` (top module: `cpu`).
3. Assign the pins for the clock, reset and UART `tx`, then synthesize, place & route and program the board.
4. Open a serial terminal at **115200 baud (8N1)** on the board's UART port.

You should see the output of the demo program:

```
Hello World!
```

## Demo program

`program/hello_world.c` prints `Hello World!` over UART by writing characters to the memory-mapped UART address.

## Roadmap

- [ ] Write an operating system for this processor
- [ ] Finish the UART (currently transmit only)
- [ ] Write more testbenches and test every instruction
- [ ] Improve and rewrite the Control Unit, Decoder and the top-level `cpu` module, since the current design is hard to extend
- [ ] Implement the missing instructions (`fence`, `fence.tso`, `pause`, `ecall`, `ebreak`)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
