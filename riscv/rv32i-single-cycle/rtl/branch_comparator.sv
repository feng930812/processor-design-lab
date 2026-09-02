module branch_comparator(
  input logic [31:0]           operand_a,
  input logic [31:0]           operand_b,
  input rv32i_pkg::branch_op_t branch_op,
  output logic                 branch_taken
);

  import rv32i_pkg::*;

  always_comb begin
    branch_taken = '0;

    case (branch_op)
      BR_NONE: branch_taken = '0;
      BR_EQ: branch_taken = operand_a == operand_b;
      BR_NE: branch_taken = operand_a != operand_b;
      BR_LT: branch_taken = $signed(operand_a) < $signed(operand_b);
      BR_GE: branch_taken = $signed(operand_a) >= $signed(operand_b);
      BR_LTU: branch_taken = operand_a < operand_b;
      BR_GEU: branch_taken = operand_a >= operand_b;
      default: branch_taken = '0;
    endcase

  end

endmodule
