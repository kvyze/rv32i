BUILD_DIR     	  := build
SIM_DIR	      	  := $(BUILD_DIR)/sim
SRC_DIR       	  := src
CRT0_DIR      	  := crt0
SRC_PROGRAM_DIR   := program
BUILD_PROGRAM_DIR := $(BUILD_DIR)/program

SCRS          := $(wildcard $(SRC_DIR)/*.sv $(SRC_DIR)/uart/*.sv)
SCRS_NO_TYPES := $(filter-out $(SRC_DIR)/types.sv, $(SCRS))
PROGRAM_SRCS  := $(wildcard $(SRC_PROGRAM_DIR)/*.s $(SRC_PROGRAM_DIR)/*.h $(SRC_PROGRAM_DIR)/*.c)

ifeq ($(OS),Windows_NT)
	RM    = rmdir /s /q
	MKDIR = mkdir
	MOVE  = move
else
	RM    = rm -rf
	MKDIR = mkdir -p
	MOVE  = mv -f
endif

.PHONY: all sim hex clean

all: hex sim

hex: $(BUILD_PROGRAM_DIR)/program.hex

$(BUILD_PROGRAM_DIR)/program.hex: $(BUILD_PROGRAM_DIR)/program.elf
	riscv-none-elf-objcopy -O verilog --verilog-data-width=4 $< $@

$(BUILD_PROGRAM_DIR)/program.elf: $(PROGRAM_SRCS) | $(BUILD_PROGRAM_DIR)
	riscv-none-elf-gcc -T $(CRT0_DIR)/linker.ld -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding $(CRT0_DIR)/crt0.s $^ -o $@

$(BUILD_PROGRAM_DIR):
	$(MKDIR) "$@"

sim: wave

wave: $(SIM_DIR)/cpu_wave.vcd
	gtkwave $<

$(SIM_DIR)/cpu_wave.vcd: $(SIM_DIR)/cpu_sim.vvp
	vvp $<
	$(MOVE) cpu_wave.vcd "$(SIM_DIR)"

$(SIM_DIR)/cpu_sim.vvp: $(SCRS) | $(SIM_DIR)
	iverilog -g2012 -Wall -s tb_cpu -o cpu_sim.vvp $(SRC_DIR)/types.sv $(SRC_DIR)/tb/tb_cpu.sv $(SCRS_NO_TYPES)
	$(MOVE) cpu_sim.vvp "$(SIM_DIR)"

$(SIM_DIR):
	$(MKDIR) "$@"

clean:
	$(RM) build
