module next_pc_logic_tb;

  timeunit 1ns;
  timeprecision 1ps;

  import rv32i_pkg::*;

  logic [31:0] pc_plus_4;
  logic [31:0] target_address;
  logic        branch_taken;
  jump_type_t  jump_type;
  logic [31:0] next_pc;
  logic        instruction_address_misaligned;
  int unsigned test_count;
  int unsigned error_count;

  next_pc_logic dut (
    .pc_plus_4                      (pc_plus_4),
    .target_address                 (target_address),
    .branch_taken                   (branch_taken),
    .jump_type                      (jump_type),
    .next_pc                        (next_pc),
    .instruction_address_misaligned (instruction_address_misaligned)
  );

  task automatic check_next_pc(
    input logic [31:0] test_pc_plus_4,
    input logic [31:0] test_target_address,
    input logic        test_branch_taken,
    input jump_type_t  test_jump_type,
    input logic [31:0] expected_next_pc,
    input logic        expected_misaligned,
    input string       test_name
  );
    pc_plus_4      = test_pc_plus_4;
    target_address = test_target_address;
    branch_taken   = test_branch_taken;
    jump_type      = test_jump_type;

    #1;
    test_count++;

    if ((next_pc !== expected_next_pc) ||
        (instruction_address_misaligned !== expected_misaligned)) begin
      error_count++;
      $error("FAIL: %s, expected next_pc=%h misaligned=%b, actual next_pc=%h misaligned=%b",
             test_name, expected_next_pc, expected_misaligned,
             next_pc, instruction_address_misaligned);
    end else begin
      $display("PASS: %s, next_pc=%h misaligned=%b",
               test_name, next_pc, instruction_address_misaligned);
    end
  endtask

  initial begin
    pc_plus_4      = '0;
    target_address = '0;
    branch_taken   = 1'b0;
    jump_type      = JUMP_NONE;
    test_count     = 0;
    error_count    = 0;

    check_next_pc(32'h0000_0104, 32'hdead_beef, 1'b0, JUMP_NONE,
                  32'h0000_0104, 1'b0,
                  "normal instruction selects PC plus 4");

    check_next_pc(32'h0000_0104, 32'h0000_0200, 1'b0, JUMP_NONE,
                  32'h0000_0104, 1'b0,
                  "branch not taken selects PC plus 4");

    check_next_pc(32'h0000_0104, 32'h0000_0200, 1'b1, JUMP_NONE,
                  32'h0000_0200, 1'b0,
                  "taken branch selects aligned target");

    check_next_pc(32'h0000_0104, 32'h0000_0202, 1'b1, JUMP_NONE,
                  32'h0000_0202, 1'b1,
                  "taken branch reports misaligned target");

    check_next_pc(32'h0000_0104, 32'h0000_0300, 1'b0, JUMP_DIRECT,
                  32'h0000_0300, 1'b0,
                  "JAL selects aligned direct target");

    check_next_pc(32'h0000_0104, 32'h0000_0302, 1'b0, JUMP_DIRECT,
                  32'h0000_0302, 1'b1,
                  "JAL reports misaligned direct target");

    check_next_pc(32'h0000_0104, 32'h0000_0100, 1'b0, JUMP_INDIRECT,
                  32'h0000_0100, 1'b0,
                  "JALR keeps aligned even target");

    check_next_pc(32'h0000_0104, 32'h0000_0101, 1'b0, JUMP_INDIRECT,
                  32'h0000_0100, 1'b0,
                  "JALR clears bit zero of odd aligned target");

    check_next_pc(32'h0000_0104, 32'h0000_0102, 1'b0, JUMP_INDIRECT,
                  32'h0000_0102, 1'b1,
                  "JALR reports target with bit one set");

    check_next_pc(32'h0000_0104, 32'h0000_0103, 1'b0, JUMP_INDIRECT,
                  32'h0000_0102, 1'b1,
                  "JALR clears bit zero but still reports bit one");

    check_next_pc(32'h0000_0104, 32'h0000_0203, 1'b1, JUMP_INDIRECT,
                  32'h0000_0203, 1'b1,
                  "taken branch has priority over jump type");

    $display("Tests: %0d, Passed: %0d, Failed: %0d",
             test_count, test_count - error_count, error_count);

    if (error_count != 0) begin
      $fatal(1, "Next-PC logic testbench failed");
    end

    $finish;
  end

endmodule
