IVERILOG ?= iverilog
.DEFAULT_GOAL := test
VVP ?= vvp
BUILD_DIR := build

.PHONY: test-rv32i-core
test: test-rv32i-core

test-rv32i-core: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s rv32i_core_tb -o $(BUILD_DIR)/rv32i_core_tb \
		rtl/program_counter.sv rtl/instruction_register.sv rtl/register_file.sv \
		rtl/operand_registers.sv rtl/alu_result_register.sv \
		rtl/add_controller.sv rtl/add_datapath.sv rtl/rv32i_core.sv \
		tb/rv32i_core_tb.sv
	$(VVP) $(BUILD_DIR)/rv32i_core_tb

.PHONY: test test-instruction-register test-program-counter test-operand-registers test-alu-result-register

test: test-instruction-register test-program-counter test-operand-registers test-alu-result-register test-add-datapath test-add-controller

.PHONY: test-add-datapath test-add-controller

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

test-instruction-register: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s instruction_register_tb \
		-o $(BUILD_DIR)/instruction_register_tb \
		rtl/instruction_register.sv tb/instruction_register_tb.sv
	$(VVP) $(BUILD_DIR)/instruction_register_tb

test-program-counter: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s program_counter_tb \
		-o $(BUILD_DIR)/program_counter_tb \
		rtl/program_counter.sv tb/program_counter_tb.sv
	$(VVP) $(BUILD_DIR)/program_counter_tb

test-operand-registers: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s operand_registers_tb \
		-o $(BUILD_DIR)/operand_registers_tb \
		rtl/operand_registers.sv tb/operand_registers_tb.sv
	$(VVP) $(BUILD_DIR)/operand_registers_tb

test-alu-result-register: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s alu_result_register_tb \
		-o $(BUILD_DIR)/alu_result_register_tb \
		rtl/alu_result_register.sv tb/alu_result_register_tb.sv
	$(VVP) $(BUILD_DIR)/alu_result_register_tb

test-add-datapath: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s add_datapath_tb \
		-o $(BUILD_DIR)/add_datapath_tb \
		rtl/operand_registers.sv rtl/alu_result_register.sv \
		rtl/add_datapath.sv tb/add_datapath_tb.sv
	$(VVP) $(BUILD_DIR)/add_datapath_tb

test-add-controller: | $(BUILD_DIR)
	$(IVERILOG) -g2012 -s add_controller_tb \
		-o $(BUILD_DIR)/add_controller_tb \
		rtl/add_controller.sv tb/add_controller_tb.sv
	$(VVP) $(BUILD_DIR)/add_controller_tb
