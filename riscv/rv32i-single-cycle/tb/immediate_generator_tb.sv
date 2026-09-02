module immediate_generator_tb;

  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0]          instruction;
  rv32i_pkg::imm_type_t imm_type;
  logic [31:0]          immediate;
  int unsigned          test_count;
  int unsigned          error_count;

  immediate_generator dut (
    .instruction (instruction),
    .imm_type    (imm_type),
    .immediate   (immediate)
  );

  task automatic check_immediate(
    input rv32i_pkg::imm_type_t test_type,
    input logic [31:0]          test_instruction,
    input logic [31:0]          expected,
    input string                test_name
  );
    imm_type    = test_type;
    instruction = test_instruction;

    #1;
    test_count++;

    if (immediate !== expected) begin
      error_count++;
      $error("FAIL: %s, instruction=%h, expected=%h, actual=%h",
             test_name, test_instruction, expected, immediate);
    end else begin
      $display("PASS: %s, immediate=%h", test_name, immediate);
    end
  endtask

  initial begin
    instruction = '0;
    imm_type     = rv32i_pkg::IMM_NONE;
    test_count   = 0;
    error_count  = 0;

    check_immediate(rv32i_pkg::IMM_NONE, 32'hffff_ffff, 32'd0,
                    "NONE produces zero");
    check_immediate(rv32i_pkg::IMM_I, 32'h0000_0000, 32'd0,
                    "I-type zero");
    check_immediate(rv32i_pkg::IMM_I, 32'h0050_0000, 32'd5,
                    "I-type positive five");
    check_immediate(rv32i_pkg::IMM_I, 32'h7ff0_0000, 32'h0000_07ff,
                    "I-type maximum positive value");
    check_immediate(rv32i_pkg::IMM_I, 32'hfff0_0000, 32'hffff_ffff,
                    "I-type negative one");
    check_immediate(rv32i_pkg::IMM_I, 32'h8000_0000, 32'hffff_f800,
                    "I-type minimum negative value");

    check_immediate(rv32i_pkg::IMM_S, 32'h0000_0600, 32'd12,
                    "S-type positive twelve");
    check_immediate(rv32i_pkg::IMM_S, 32'h7e00_0f80, 32'h0000_07ff,
                    "S-type maximum positive value");
    check_immediate(rv32i_pkg::IMM_S, 32'hfe00_0f80, 32'hffff_ffff,
                    "S-type negative one");
    check_immediate(rv32i_pkg::IMM_S, 32'h8000_0000, 32'hffff_f800,
                    "S-type minimum negative value");

    check_immediate(rv32i_pkg::IMM_B, 32'h0000_0200, 32'd4,
                    "B-type positive four");
    check_immediate(rv32i_pkg::IMM_B, 32'hfe00_0e80, 32'hffff_fffc,
                    "B-type negative four");
    check_immediate(rv32i_pkg::IMM_B, 32'h7e00_0f80, 32'h0000_0ffe,
                    "B-type maximum positive value");
    check_immediate(rv32i_pkg::IMM_B, 32'h8000_0000, 32'hffff_f000,
                    "B-type minimum negative value");

    check_immediate(rv32i_pkg::IMM_U, 32'h0000_0fff, 32'h0000_0000,
                    "U-type zero upper immediate");
    check_immediate(rv32i_pkg::IMM_U, 32'h1234_5abc, 32'h1234_5000,
                    "U-type keeps upper twenty bits");
    check_immediate(rv32i_pkg::IMM_U, 32'habcd_efff, 32'habcd_e000,
                    "U-type preserves a set top bit");

    check_immediate(rv32i_pkg::IMM_J, 32'h0040_0000, 32'd4,
                    "J-type positive four");
    check_immediate(rv32i_pkg::IMM_J, 32'hffdff000, 32'hffff_fffc,
                    "J-type negative four");
    check_immediate(rv32i_pkg::IMM_J, 32'h7fff_f000, 32'h000f_fffe,
                    "J-type maximum positive value");
    check_immediate(rv32i_pkg::IMM_J, 32'h8000_0000, 32'hfff0_0000,
                    "J-type minimum negative value");

    $display("Tests: %0d, Passed: %0d, Failed: %0d",
             test_count, test_count - error_count, error_count);

    if (error_count != 0) begin
      $fatal(1, "Immediate generator testbench failed");
    end

    $finish;
  end

endmodule
