IVERILOG ?= iverilog
VVP ?= vvp

RTL_DIR := rtl
TB_DIR := tb
BUILD_DIR := build
PROGRAM_DIR := programs

.PHONY: test test-alu test-register-file test-immediate-generator \
	test-branch-comparator test-instruction-decoder test-load-store-unit \
	test-program-counter test-next-pc-logic test-rv32i-core \
	test-instruction-memory test-data-memory test-rv32i-system program clean

test: test-alu test-register-file test-immediate-generator \
	test-branch-comparator test-instruction-decoder test-load-store-unit \
	test-program-counter test-next-pc-logic test-rv32i-core \
	test-instruction-memory test-data-memory test-rv32i-system

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

test-alu: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s alu_tb -o $(BUILD_DIR)/alu_tb \
		$(RTL_DIR)/rv32i_pkg.sv $(RTL_DIR)/alu.sv $(TB_DIR)/alu_tb.sv
	$(VVP) $(BUILD_DIR)/alu_tb

test-register-file: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s register_file_tb -o $(BUILD_DIR)/register_file_tb \
		$(RTL_DIR)/register_file.sv $(TB_DIR)/register_file_tb.sv
	$(VVP) $(BUILD_DIR)/register_file_tb

test-immediate-generator: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s immediate_generator_tb \
		-o $(BUILD_DIR)/immediate_generator_tb $(RTL_DIR)/rv32i_pkg.sv \
		$(RTL_DIR)/immediate_generator.sv $(TB_DIR)/immediate_generator_tb.sv
	$(VVP) $(BUILD_DIR)/immediate_generator_tb

test-branch-comparator: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s branch_comparator_tb \
		-o $(BUILD_DIR)/branch_comparator_tb $(RTL_DIR)/rv32i_pkg.sv \
		$(RTL_DIR)/branch_comparator.sv $(TB_DIR)/branch_comparator_tb.sv
	$(VVP) $(BUILD_DIR)/branch_comparator_tb

test-instruction-decoder: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s instruction_decoder_tb \
		-o $(BUILD_DIR)/instruction_decoder_tb $(RTL_DIR)/rv32i_pkg.sv \
		$(RTL_DIR)/instruction_decoder.sv $(TB_DIR)/instruction_decoder_tb.sv
	$(VVP) $(BUILD_DIR)/instruction_decoder_tb

test-load-store-unit: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s load_store_unit_tb \
		-o $(BUILD_DIR)/load_store_unit_tb $(RTL_DIR)/rv32i_pkg.sv \
		$(RTL_DIR)/load_store_unit.sv $(TB_DIR)/load_store_unit_tb.sv
	$(VVP) $(BUILD_DIR)/load_store_unit_tb

test-program-counter: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s program_counter_tb \
		-o $(BUILD_DIR)/program_counter_tb $(RTL_DIR)/program_counter.sv \
		$(TB_DIR)/program_counter_tb.sv
	$(VVP) $(BUILD_DIR)/program_counter_tb

test-next-pc-logic: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s next_pc_logic_tb \
		-o $(BUILD_DIR)/next_pc_logic_tb $(RTL_DIR)/rv32i_pkg.sv \
		$(RTL_DIR)/next_pc_logic.sv $(TB_DIR)/next_pc_logic_tb.sv
	$(VVP) $(BUILD_DIR)/next_pc_logic_tb

test-rv32i-core: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s rv32i_core_tb \
		-o $(BUILD_DIR)/rv32i_core_tb $(RTL_DIR)/rv32i_pkg.sv \
		$(RTL_DIR)/program_counter.sv $(RTL_DIR)/instruction_decoder.sv \
		$(RTL_DIR)/immediate_generator.sv $(RTL_DIR)/register_file.sv \
		$(RTL_DIR)/alu.sv $(RTL_DIR)/branch_comparator.sv \
		$(RTL_DIR)/load_store_unit.sv $(RTL_DIR)/next_pc_logic.sv \
		$(RTL_DIR)/rv32i_core.sv $(TB_DIR)/rv32i_core_tb.sv
	$(VVP) $(BUILD_DIR)/rv32i_core_tb

test-instruction-memory: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s instruction_memory_tb \
		-o $(BUILD_DIR)/instruction_memory_tb \
		$(RTL_DIR)/instruction_memory.sv $(TB_DIR)/instruction_memory_tb.sv
	$(VVP) $(BUILD_DIR)/instruction_memory_tb

test-data-memory: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s data_memory_tb -o $(BUILD_DIR)/data_memory_tb \
		$(RTL_DIR)/data_memory.sv $(TB_DIR)/data_memory_tb.sv
	$(VVP) $(BUILD_DIR)/data_memory_tb

test-rv32i-system: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s rv32i_system_tb \
		-o $(BUILD_DIR)/rv32i_system_tb $(RTL_DIR)/rv32i_pkg.sv \
		$(RTL_DIR)/program_counter.sv $(RTL_DIR)/instruction_decoder.sv \
		$(RTL_DIR)/immediate_generator.sv $(RTL_DIR)/register_file.sv \
		$(RTL_DIR)/alu.sv $(RTL_DIR)/branch_comparator.sv \
		$(RTL_DIR)/load_store_unit.sv $(RTL_DIR)/next_pc_logic.sv \
		$(RTL_DIR)/rv32i_core.sv $(RTL_DIR)/instruction_memory.sv \
		$(RTL_DIR)/data_memory.sv $(RTL_DIR)/rv32i_system.sv \
		$(TB_DIR)/rv32i_system_tb.sv
	$(VVP) $(BUILD_DIR)/rv32i_system_tb

program: | $(BUILD_DIR)
	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 \
		-o $(BUILD_DIR)/rv32i_integration.o $(PROGRAM_DIR)/rv32i_integration.S
	riscv64-unknown-elf-ld -m elf32lriscv -Ttext=0 -e _start \
		-o $(BUILD_DIR)/rv32i_integration.elf $(BUILD_DIR)/rv32i_integration.o
	riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=4 \
		$(BUILD_DIR)/rv32i_integration.elf $(PROGRAM_DIR)/rv32i_integration.hex

clean:
	rm -r $(BUILD_DIR)
