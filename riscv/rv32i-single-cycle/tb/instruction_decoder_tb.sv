module instruction_decoder_tb;

  timeunit 1ns;
  timeprecision 1ps;

  import rv32i_pkg::*;

  logic [31:0] instruction;
  alu_a_sel_t alu_a_sel;
  alu_b_sel_t alu_b_sel;
  alu_op_t alu_op;
  imm_type_t imm_type;
  branch_op_t branch_op;
  mem_size_t memory_size;
  wb_sel_t writeback_sel;
  jump_type_t jump_type;
  logic register_write_enable;
  logic memory_read_enable;
  logic memory_write_enable;
  logic load_unsigned;
  logic environment_call;
  logic breakpoint;
  logic illegal_instruction;

  int tests_run;
  int tests_failed;

  instruction_decoder dut (
    .instruction,
    .alu_a_sel,
    .alu_b_sel,
    .alu_op,
    .imm_type,
    .branch_op,
    .memory_size,
    .writeback_sel,
    .jump_type,
    .register_write_enable,
    .memory_read_enable,
    .memory_write_enable,
    .load_unsigned,
    .environment_call,
    .breakpoint,
    .illegal_instruction
  );

  function automatic logic [31:0] make_r(
    input logic [6:0] test_funct7,
    input logic [2:0] test_funct3
  );
    return {test_funct7, 5'd2, 5'd1, test_funct3, 5'd3, OPCODE_OP};
  endfunction

  function automatic logic [31:0] make_i(
    input logic [11:0] test_imm,
    input logic [2:0] test_funct3,
    input logic [6:0] test_opcode
  );
    return {test_imm, 5'd1, test_funct3, 5'd3, test_opcode};
  endfunction

  function automatic logic [31:0] make_s(
    input logic [11:0] test_imm,
    input logic [2:0] test_funct3
  );
    return {
      test_imm[11:5], 5'd2, 5'd1, test_funct3,
      test_imm[4:0], OPCODE_STORE
    };
  endfunction

  function automatic logic [31:0] make_b(
    input logic [12:0] test_imm,
    input logic [2:0] test_funct3
  );
    return {
      test_imm[12], test_imm[10:5], 5'd2, 5'd1, test_funct3,
      test_imm[4:1], test_imm[11], OPCODE_BRANCH
    };
  endfunction

  function automatic logic [31:0] make_u(
    input logic [19:0] test_imm,
    input logic [6:0] test_opcode
  );
    return {test_imm, 5'd3, test_opcode};
  endfunction

  function automatic logic [31:0] make_j(
    input logic [20:0] test_imm
  );
    return {
      test_imm[20], test_imm[10:1], test_imm[11],
      test_imm[19:12], 5'd3, OPCODE_JAL
    };
  endfunction

  task automatic check_decode(
    input string test_name,
    input logic [31:0] test_instruction,
    input alu_a_sel_t expected_alu_a,
    input alu_b_sel_t expected_alu_b,
    input alu_op_t expected_alu_op,
    input imm_type_t expected_imm_type,
    input branch_op_t expected_branch_op,
    input mem_size_t expected_memory_size,
    input wb_sel_t expected_writeback_sel,
    input jump_type_t expected_jump_type,
    input logic expected_register_write,
    input logic expected_memory_read,
    input logic expected_memory_write,
    input logic expected_load_unsigned
  );
    instruction = test_instruction;
    #1;
    tests_run++;

    if ({alu_a_sel, alu_b_sel, alu_op, imm_type, branch_op,
         memory_size, writeback_sel, jump_type,
         register_write_enable, memory_read_enable,
         memory_write_enable, load_unsigned, environment_call,
         breakpoint, illegal_instruction} !==
        {expected_alu_a, expected_alu_b, expected_alu_op,
         expected_imm_type, expected_branch_op, expected_memory_size,
         expected_writeback_sel, expected_jump_type,
         expected_register_write, expected_memory_read,
         expected_memory_write, expected_load_unsigned,
         1'b0, 1'b0, 1'b0}) begin
      tests_failed++;
      $display("FAIL: %s", test_name);
      $display("  instruction = %08h", test_instruction);
      $display("  actual:   A=%0d B=%0d ALU=%0d IMM=%0d BR=%0d MEM=%0d WB=%0d JUMP=%0d RW=%0b MR=%0b MW=%0b U=%0b ILL=%0b",
               alu_a_sel, alu_b_sel, alu_op, imm_type, branch_op,
               memory_size, writeback_sel, jump_type,
               register_write_enable, memory_read_enable,
               memory_write_enable, load_unsigned, illegal_instruction);
      $display("  expected: A=%0d B=%0d ALU=%0d IMM=%0d BR=%0d MEM=%0d WB=%0d JUMP=%0d RW=%0b MR=%0b MW=%0b U=%0b ILL=0",
               expected_alu_a, expected_alu_b, expected_alu_op,
               expected_imm_type, expected_branch_op, expected_memory_size,
               expected_writeback_sel, expected_jump_type,
               expected_register_write, expected_memory_read,
               expected_memory_write, expected_load_unsigned);
    end else begin
      $display("PASS: %s", test_name);
    end
  endtask

  task automatic check_illegal(
    input string test_name,
    input logic [31:0] test_instruction
  );
    instruction = test_instruction;
    #1;
    tests_run++;

    if (illegal_instruction !== 1'b1 ||
        register_write_enable !== 1'b0 ||
        memory_read_enable !== 1'b0 ||
        memory_write_enable !== 1'b0 ||
        branch_op !== BR_NONE || jump_type !== JUMP_NONE ||
        environment_call !== 1'b0 || breakpoint !== 1'b0) begin
      tests_failed++;
      $display("FAIL: %s did not produce safe illegal controls", test_name);
    end else begin
      $display("PASS: %s", test_name);
    end
  endtask

  task automatic check_environment_instruction(
    input string       test_name,
    input logic [31:0] test_instruction,
    input logic        expected_environment_call,
    input logic        expected_breakpoint
  );
    instruction = test_instruction;
    #1;
    tests_run++;

    if ((environment_call !== expected_environment_call) ||
        (breakpoint !== expected_breakpoint) ||
        (illegal_instruction !== 1'b0) ||
        register_write_enable || memory_read_enable || memory_write_enable) begin
      tests_failed++;
      $display("FAIL: %s", test_name);
    end else begin
      $display("PASS: %s", test_name);
    end
  endtask

  initial begin
    instruction = '0;
    tests_run = 0;
    tests_failed = 0;

    check_decode("ADD",  make_r(7'b0000000, 3'b000), ALU_A_RS1, ALU_B_RS2, ALU_ADD,  IMM_NONE, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SUB",  make_r(7'b0100000, 3'b000), ALU_A_RS1, ALU_B_RS2, ALU_SUB,  IMM_NONE, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SLL",  make_r(7'b0000000, 3'b001), ALU_A_RS1, ALU_B_RS2, ALU_SLL,  IMM_NONE, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SLT",  make_r(7'b0000000, 3'b010), ALU_A_RS1, ALU_B_RS2, ALU_SLT,  IMM_NONE, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SLTU", make_r(7'b0000000, 3'b011), ALU_A_RS1, ALU_B_RS2, ALU_SLTU, IMM_NONE, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("XOR",  make_r(7'b0000000, 3'b100), ALU_A_RS1, ALU_B_RS2, ALU_XOR,  IMM_NONE, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SRL",  make_r(7'b0000000, 3'b101), ALU_A_RS1, ALU_B_RS2, ALU_SRL,  IMM_NONE, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SRA",  make_r(7'b0100000, 3'b101), ALU_A_RS1, ALU_B_RS2, ALU_SRA,  IMM_NONE, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("OR",   make_r(7'b0000000, 3'b110), ALU_A_RS1, ALU_B_RS2, ALU_OR,   IMM_NONE, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("AND",  make_r(7'b0000000, 3'b111), ALU_A_RS1, ALU_B_RS2, ALU_AND,  IMM_NONE, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_illegal("illegal R funct7", make_r(7'b1111111, 3'b000));

    check_decode("ADDI",  make_i(12'ha55, 3'b000, OPCODE_OP_IMM), ALU_A_RS1, ALU_B_IMM, ALU_ADD,  IMM_I, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SLTI",  make_i(12'ha55, 3'b010, OPCODE_OP_IMM), ALU_A_RS1, ALU_B_IMM, ALU_SLT,  IMM_I, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SLTIU", make_i(12'ha55, 3'b011, OPCODE_OP_IMM), ALU_A_RS1, ALU_B_IMM, ALU_SLTU, IMM_I, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("XORI",  make_i(12'ha55, 3'b100, OPCODE_OP_IMM), ALU_A_RS1, ALU_B_IMM, ALU_XOR,  IMM_I, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("ORI",   make_i(12'ha55, 3'b110, OPCODE_OP_IMM), ALU_A_RS1, ALU_B_IMM, ALU_OR,   IMM_I, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("ANDI",  make_i(12'ha55, 3'b111, OPCODE_OP_IMM), ALU_A_RS1, ALU_B_IMM, ALU_AND,  IMM_I, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SLLI",  make_i({SHIFT_LOGICAL, 5'd7}, 3'b001, OPCODE_OP_IMM), ALU_A_RS1, ALU_B_IMM, ALU_SLL, IMM_I, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SRLI",  make_i({SHIFT_LOGICAL, 5'd7}, 3'b101, OPCODE_OP_IMM), ALU_A_RS1, ALU_B_IMM, ALU_SRL, IMM_I, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("SRAI",  make_i({SHIFT_ARITHMETIC, 5'd7}, 3'b101, OPCODE_OP_IMM), ALU_A_RS1, ALU_B_IMM, ALU_SRA, IMM_I, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_illegal("illegal SLLI funct7", make_i({7'b1111111, 5'd7}, 3'b001, OPCODE_OP_IMM));
    check_illegal("illegal right shift funct7", make_i({7'b1111111, 5'd7}, 3'b101, OPCODE_OP_IMM));

    check_decode("LUI",   make_u(20'habcde, OPCODE_LUI),   ALU_A_ZERO, ALU_B_IMM, ALU_ADD, IMM_U, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);
    check_decode("AUIPC", make_u(20'habcde, OPCODE_AUIPC), ALU_A_PC,   ALU_B_IMM, ALU_ADD, IMM_U, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 1, 0, 0, 0);

    check_decode("BEQ",  make_b(13'h100, 3'b000), ALU_A_PC, ALU_B_IMM, ALU_ADD, IMM_B, BR_EQ,  MEM_WORD, WB_ALU, JUMP_NONE, 0, 0, 0, 0);
    check_decode("BNE",  make_b(13'h100, 3'b001), ALU_A_PC, ALU_B_IMM, ALU_ADD, IMM_B, BR_NE,  MEM_WORD, WB_ALU, JUMP_NONE, 0, 0, 0, 0);
    check_decode("BLT",  make_b(13'h100, 3'b100), ALU_A_PC, ALU_B_IMM, ALU_ADD, IMM_B, BR_LT,  MEM_WORD, WB_ALU, JUMP_NONE, 0, 0, 0, 0);
    check_decode("BGE",  make_b(13'h100, 3'b101), ALU_A_PC, ALU_B_IMM, ALU_ADD, IMM_B, BR_GE,  MEM_WORD, WB_ALU, JUMP_NONE, 0, 0, 0, 0);
    check_decode("BLTU", make_b(13'h100, 3'b110), ALU_A_PC, ALU_B_IMM, ALU_ADD, IMM_B, BR_LTU, MEM_WORD, WB_ALU, JUMP_NONE, 0, 0, 0, 0);
    check_decode("BGEU", make_b(13'h100, 3'b111), ALU_A_PC, ALU_B_IMM, ALU_ADD, IMM_B, BR_GEU, MEM_WORD, WB_ALU, JUMP_NONE, 0, 0, 0, 0);
    check_illegal("illegal branch funct3", make_b(13'h100, 3'b010));

    check_decode("LB",  make_i(12'h010, 3'b000, OPCODE_LOAD), ALU_A_RS1, ALU_B_IMM, ALU_ADD, IMM_I, BR_NONE, MEM_BYTE, WB_MEMORY, JUMP_NONE, 1, 1, 0, 0);
    check_decode("LH",  make_i(12'h010, 3'b001, OPCODE_LOAD), ALU_A_RS1, ALU_B_IMM, ALU_ADD, IMM_I, BR_NONE, MEM_HALF, WB_MEMORY, JUMP_NONE, 1, 1, 0, 0);
    check_decode("LW",  make_i(12'h010, 3'b010, OPCODE_LOAD), ALU_A_RS1, ALU_B_IMM, ALU_ADD, IMM_I, BR_NONE, MEM_WORD, WB_MEMORY, JUMP_NONE, 1, 1, 0, 0);
    check_decode("LBU", make_i(12'h010, 3'b100, OPCODE_LOAD), ALU_A_RS1, ALU_B_IMM, ALU_ADD, IMM_I, BR_NONE, MEM_BYTE, WB_MEMORY, JUMP_NONE, 1, 1, 0, 1);
    check_decode("LHU", make_i(12'h010, 3'b101, OPCODE_LOAD), ALU_A_RS1, ALU_B_IMM, ALU_ADD, IMM_I, BR_NONE, MEM_HALF, WB_MEMORY, JUMP_NONE, 1, 1, 0, 1);
    check_illegal("illegal load funct3", make_i(12'h010, 3'b011, OPCODE_LOAD));

    check_decode("SB", make_s(12'h010, 3'b000), ALU_A_RS1, ALU_B_IMM, ALU_ADD, IMM_S, BR_NONE, MEM_BYTE, WB_ALU, JUMP_NONE, 0, 0, 1, 0);
    check_decode("SH", make_s(12'h010, 3'b001), ALU_A_RS1, ALU_B_IMM, ALU_ADD, IMM_S, BR_NONE, MEM_HALF, WB_ALU, JUMP_NONE, 0, 0, 1, 0);
    check_decode("SW", make_s(12'h010, 3'b010), ALU_A_RS1, ALU_B_IMM, ALU_ADD, IMM_S, BR_NONE, MEM_WORD, WB_ALU, JUMP_NONE, 0, 0, 1, 0);
    check_illegal("illegal store funct3", make_s(12'h010, 3'b011));

    check_decode("JAL", make_j(21'h01000), ALU_A_PC, ALU_B_IMM, ALU_ADD, IMM_J, BR_NONE, MEM_WORD, WB_PC_PLUS_4, JUMP_DIRECT, 1, 0, 0, 0);
    check_decode("JALR", make_i(12'h010, 3'b000, OPCODE_JALR), ALU_A_RS1, ALU_B_IMM, ALU_ADD, IMM_I, BR_NONE, MEM_WORD, WB_PC_PLUS_4, JUMP_INDIRECT, 1, 0, 0, 0);
    check_illegal("illegal JALR funct3", make_i(12'h010, 3'b001, OPCODE_JALR));

    check_decode("FENCE", 32'h0330_000f, ALU_A_RS1, ALU_B_RS2,
                 ALU_ADD, IMM_NONE, BR_NONE, MEM_WORD, WB_ALU,
                 JUMP_NONE, 0, 0, 0, 0);
    check_illegal("illegal FENCE funct3", 32'h0000_100f);
    check_illegal("unsupported FENCE fm", 32'h8000_000f);
    check_environment_instruction("ECALL", 32'h0000_0073, 1'b1, 1'b0);
    check_environment_instruction("EBREAK", 32'h0010_0073, 1'b0, 1'b1);
    check_illegal("unsupported SYSTEM instruction", 32'h0020_0073);
    check_illegal("unknown opcode", 32'hffff_ffff);

    if (tests_failed == 0)
      $display("ALL TESTS PASSED (%0d/%0d)", tests_run, tests_run);
    else
      $display("TESTS FAILED: %0d failed out of %0d", tests_failed, tests_run);

    $finish;
  end

endmodule
