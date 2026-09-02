IVERILOG ?= iverilog
VVP ?= vvp

RTL_DIR := rtl
TB_DIR := tb
BUILD_DIR := build

.PHONY: test test-alu test-register-file test-immediate-generator \
	test-branch-comparator test-instruction-decoder clean

test: test-alu test-register-file test-immediate-generator \
	test-branch-comparator test-instruction-decoder

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

clean:
	rm -r $(BUILD_DIR)

