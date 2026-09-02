module alu_tb;

  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0]              operand_a;
  logic [31:0]              operand_b;
  rv32i_pkg::alu_op_t       alu_op;
  logic [31:0]              result;
  int unsigned              test_count;
  int unsigned              error_count;

  alu dut (
    .operand_a (operand_a),
    .operand_b (operand_b),
    .alu_op    (alu_op),
    .result    (result)
  );

  task automatic check_alu(
    input rv32i_pkg::alu_op_t test_op,
    input logic [31:0]        test_a,
    input logic [31:0]        test_b,
    input logic [31:0]        expected,
    input string              test_name
  );
    alu_op = test_op;
    operand_a = test_a;
    operand_b = test_b;

    #1;
    test_count++;

    if (result !== expected) begin
      error_count++;
      $error("FAIL: %s, a=%h, b=%h, expected=%h, actual=%h",
             test_name, test_a, test_b, expected, result);
    end else begin
      $display("PASS: %s, result=%h", test_name, result);
    end
  endtask

  initial begin
    test_count  = 0;
    error_count = 0;

    check_alu(rv32i_pkg::ALU_ADD,
              32'd2,
              32'd3,
              32'd5,
              "ADD: 2 + 3");

    check_alu(rv32i_pkg::ALU_SUB,
              32'd10,
              32'd4,
              32'd6,
              "SUB: 10 - 4");

    check_alu(rv32i_pkg::ALU_SRL,
              32'h8000_0000,
              32'd1,
              32'h4000_0000,
              "SRL: logical right shift");

    check_alu(rv32i_pkg::ALU_SRA,
              32'h8000_0000,
              32'd1,
              32'hc000_0000,
              "SRA: arithmetic right shift");

    check_alu(rv32i_pkg::ALU_AND,
              32'ha5a5_f0f0,
              32'h0ff0_ff00,
              32'h05a0_f000,
              "AND: bitwise pattern");

    check_alu(rv32i_pkg::ALU_OR,
              32'ha5a5_f0f0,
              32'h0ff0_ff00,
              32'haff5_fff0,
              "OR: bitwise pattern");

    check_alu(rv32i_pkg::ALU_XOR,
              32'ha5a5_f0f0,
              32'h0ff0_ff00,
              32'haa55_0ff0,
              "XOR: bitwise pattern");

    check_alu(rv32i_pkg::ALU_SLL,
              32'h0000_0001,
              32'd31,
              32'h8000_0000,
              "SLL: shift into sign bit");

    check_alu(rv32i_pkg::ALU_SLT,
              32'hffff_ffff,
              32'h0000_0001,
              32'd1,
              "SLT: signed -1 less than 1");

    check_alu(rv32i_pkg::ALU_SLTU,
              32'hffff_ffff,
              32'h0000_0001,
              32'd0,
              "SLTU: unsigned max not less than 1");

    check_alu(rv32i_pkg::ALU_ADD,
              32'hffff_ffff,
              32'd1,
              32'h0000_0000,
              "ADD: 32-bit wraparound");

    check_alu(rv32i_pkg::ALU_SUB,
              32'h0000_0000,
              32'd1,
              32'hffff_ffff,
              "SUB: 32-bit wraparound");

    check_alu(rv32i_pkg::ALU_SLL,
              32'h0000_0001,
              32'd32,
              32'h0000_0001,
              "SLL: shift amount uses low 5 bits");

    check_alu(rv32i_pkg::ALU_SRA,
              32'h4000_0000,
              32'd1,
              32'h2000_0000,
              "SRA: positive value fills with zero");

    check_alu(rv32i_pkg::ALU_SLT,
              32'h8000_0000,
              32'h8000_0000,
              32'd0,
              "SLT: equal operands");
            
    $display("Tests: %0d, Passed: %0d, Failed: %0d",
             test_count, test_count - error_count, error_count);

    if (error_count != 0) begin
      $fatal(1, "ALU testbench failed");
    end

    $finish;
  end

endmodule
