module rv32i_core
  import rv32i_pkg::*;
(
  input  logic        clk,
  input  logic        reset,
  input  logic [31:0] instruction_read_data,
  input  logic [31:0] data_read_data,

  output logic [31:0] instruction_address,
  output logic [31:0] data_address,
  output logic [31:0] data_write_data,
  output logic [3:0]  data_byte_enable,
  output logic        data_read_enable,
  output logic        data_write_enable,
  output logic        data_address_misaligned,
  output logic        instruction_address_misaligned,
  output logic        illegal_instruction,
  output logic        environment_call,
  output logic        breakpoint
);

  logic [31:0] pc;
  logic [31:0] pc_plus_4;
  logic [31:0] next_pc;
  logic [31:0] immediate;
  logic [31:0] rs1_data;
  logic [31:0] rs2_data;
  logic [31:0] alu_operand_a;
  logic [31:0] alu_operand_b;
  logic [31:0] alu_result;
  logic [31:0] writeback_data;
  logic [31:0] load_data;
  logic [31:0] lsu_write_data;
  logic [3:0]  lsu_byte_enable;

  logic [4:0] rd_addr;
  logic [4:0] rs1_addr;
  logic [4:0] rs2_addr;

  alu_a_sel_t alu_a_sel;
  alu_b_sel_t alu_b_sel;
  alu_op_t    alu_op;
  imm_type_t  imm_type;
  branch_op_t branch_op;
  mem_size_t  memory_size;
  wb_sel_t    writeback_sel;
  jump_type_t jump_type;

  logic register_write_enable;
  logic memory_read_enable;
  logic memory_write_enable;
  logic load_unsigned;
  logic register_file_write_enable;
  logic branch_taken;
  logic lsu_misaligned;

  assign pc_plus_4           = pc + 32'd4;
  assign instruction_address = pc;
  
  assign rd_addr  = instruction_read_data[11:7];
  assign rs1_addr = instruction_read_data[19:15];
  assign rs2_addr = instruction_read_data[24:20];

  assign register_file_write_enable = register_write_enable
                                    && !illegal_instruction
                                    && !instruction_address_misaligned
                                    && !(memory_read_enable && lsu_misaligned)
                                    && !reset;

  assign data_address            = alu_result;
  assign data_write_data         = lsu_write_data;
  assign data_read_enable        = memory_read_enable
                                 && !illegal_instruction
                                 && !lsu_misaligned
                                 && !reset;
  assign data_write_enable       = memory_write_enable
                                 && !illegal_instruction
                                 && !lsu_misaligned
                                 && !reset;
  assign data_byte_enable        = data_write_enable ? lsu_byte_enable : 4'b0000;
  assign data_address_misaligned = (memory_read_enable || memory_write_enable)
                                 && lsu_misaligned;

  always_comb begin
    case (alu_a_sel)
      ALU_A_RS1:  alu_operand_a = rs1_data;
      ALU_A_PC:   alu_operand_a = pc;
      ALU_A_ZERO: alu_operand_a = 32'b0;
      default:    alu_operand_a = 32'b0;
    endcase
  end

  always_comb begin
    case (alu_b_sel)
      ALU_B_RS2: alu_operand_b = rs2_data;
      ALU_B_IMM: alu_operand_b = immediate;
      default:   alu_operand_b = 32'b0;
    endcase
  end

  always_comb begin
    case (writeback_sel)
      WB_ALU:       writeback_data = alu_result;
      WB_MEMORY:    writeback_data = load_data;
      WB_PC_PLUS_4: writeback_data = pc_plus_4;
      default:      writeback_data = 32'b0;
    endcase
  end

  program_counter u_pc (
    .clk     (clk),
    .reset   (reset),
    .next_pc (next_pc),
    .pc      (pc)
  );

  instruction_decoder u_decoder (
    .instruction           (instruction_read_data),
    .alu_a_sel             (alu_a_sel),
    .alu_b_sel             (alu_b_sel),
    .alu_op                (alu_op),
    .imm_type              (imm_type),
    .branch_op             (branch_op),
    .memory_size           (memory_size),
    .writeback_sel         (writeback_sel),
    .jump_type             (jump_type),
    .register_write_enable (register_write_enable),
    .memory_read_enable    (memory_read_enable),
    .memory_write_enable   (memory_write_enable),
    .load_unsigned         (load_unsigned),
    .environment_call      (environment_call),
    .breakpoint            (breakpoint),
    .illegal_instruction   (illegal_instruction)
  );

  immediate_generator u_immediate_generator (
    .instruction (instruction_read_data),
    .imm_type    (imm_type),
    .immediate   (immediate)
  );

  register_file u_register_file (
    .clk          (clk),
    .rs1_addr     (rs1_addr),
    .rs2_addr     (rs2_addr),
    .rd_addr      (rd_addr),
    .rd_data      (writeback_data),
    .write_enable (register_file_write_enable),
    .rs1_data     (rs1_data),
    .rs2_data     (rs2_data)
  );

  alu u_alu (
    .operand_a (alu_operand_a),
    .operand_b (alu_operand_b),
    .alu_op    (alu_op),
    .result    (alu_result)
  );

  branch_comparator u_branch_comparator (
    .operand_a   (rs1_data),
    .operand_b   (rs2_data),
    .branch_op   (branch_op),
    .branch_taken(branch_taken)
  );

  load_store_unit u_load_store_unit (
    .address            (alu_result),
    .store_data         (rs2_data),
    .memory_read_data   (data_read_data),
    .memory_size        (memory_size),
    .load_unsigned      (load_unsigned),
    .load_data          (load_data),
    .memory_write_data  (lsu_write_data),
    .memory_byte_enable (lsu_byte_enable),
    .misaligned_access  (lsu_misaligned)
  );

  next_pc_logic u_next_pc (
    .pc_plus_4                      (pc_plus_4),
    .target_address                 (alu_result),
    .branch_taken                   (branch_taken),
    .jump_type                      (jump_type),
    .next_pc                        (next_pc),
    .instruction_address_misaligned (instruction_address_misaligned)
  );

endmodule
