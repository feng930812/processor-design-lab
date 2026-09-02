module branch_comparator_tb;

  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0]             operand_a;
  logic [31:0]             operand_b;
  rv32i_pkg::branch_op_t   branch_op;
  logic                    branch_taken;
  int unsigned             test_count;
  int unsigned             error_count;

  branch_comparator dut (
    .operand_a    (operand_a),
    .operand_b    (operand_b),
    .branch_op    (branch_op),
    .branch_taken (branch_taken)
  );

  task automatic check_branch(
    input rv32i_pkg::branch_op_t test_op,
    input logic [31:0]           test_a,
    input logic [31:0]           test_b,
    input logic                  expected,
    input string                 test_name
  );
    branch_op = test_op;
    operand_a = test_a;
    operand_b = test_b;

    #1;
    test_count++;

    if (branch_taken !== expected) begin
      error_count++;
      $error("FAIL: %s, a=%h, b=%h, expected=%b, actual=%b",
             test_name, test_a, test_b, expected, branch_taken);
    end else begin
      $display("PASS: %s, taken=%b", test_name, branch_taken);
    end
  endtask

  initial begin
    operand_a   = '0;
    operand_b   = '0;
    branch_op   = rv32i_pkg::BR_NONE;
    test_count  = 0;
    error_count = 0;

    check_branch(rv32i_pkg::BR_NONE, 32'd5, 32'd5, 1'b0,
                 "NONE never takes a branch");
    check_branch(rv32i_pkg::BR_EQ, 32'h1234_5678, 32'h1234_5678, 1'b1,
                 "EQ equal operands");
    check_branch(rv32i_pkg::BR_EQ, 32'd10, 32'd11, 1'b0,
                 "EQ different operands");
    check_branch(rv32i_pkg::BR_NE, 32'd10, 32'd11, 1'b1,
                 "NE different operands");
    check_branch(rv32i_pkg::BR_NE, 32'd10, 32'd10, 1'b0,
                 "NE equal operands");

    check_branch(rv32i_pkg::BR_LT, 32'hffff_ffff, 32'd1, 1'b1,
                 "signed -1 is less than 1");
    check_branch(rv32i_pkg::BR_LT, 32'd1, 32'hffff_ffff, 1'b0,
                 "signed 1 is not less than -1");
    check_branch(rv32i_pkg::BR_GE, 32'hffff_ffff, 32'd1, 1'b0,
                 "signed -1 is not greater than or equal to 1");
    check_branch(rv32i_pkg::BR_GE, 32'h8000_0000, 32'h8000_0000, 1'b1,
                 "signed greater-than-or-equal includes equality");

    check_branch(rv32i_pkg::BR_LTU, 32'hffff_ffff, 32'd1, 1'b0,
                 "unsigned maximum is not less than 1");
    check_branch(rv32i_pkg::BR_LTU, 32'd1, 32'hffff_ffff, 1'b1,
                 "unsigned 1 is less than maximum");
    check_branch(rv32i_pkg::BR_GEU, 32'hffff_ffff, 32'd1, 1'b1,
                 "unsigned maximum is greater than or equal to 1");
    check_branch(rv32i_pkg::BR_GEU, 32'd0, 32'd1, 1'b0,
                 "unsigned 0 is not greater than or equal to 1");

    $display("Tests: %0d, Passed: %0d, Failed: %0d",
             test_count, test_count - error_count, error_count);

    if (error_count != 0) begin
      $fatal(1, "Branch comparator testbench failed");
    end

    $finish;
  end

endmodule
