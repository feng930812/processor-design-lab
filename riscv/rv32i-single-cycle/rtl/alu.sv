module alu (
  input  logic [31:0]        operand_a,
  input  logic [31:0]        operand_b,
  input  rv32i_pkg::alu_op_t alu_op,
  output logic [31:0]        result
);

  import rv32i_pkg::*;

  always_comb begin
    result = '0;

    case (alu_op)
      ALU_ADD:  result = operand_a + operand_b;
      ALU_SUB:  result = operand_a - operand_b;
      ALU_AND:  result = operand_a & operand_b;
      ALU_OR:   result = operand_a | operand_b;
      ALU_XOR:  result = operand_a ^ operand_b;
      ALU_SLL:  result = operand_a << operand_b[4:0];
      ALU_SRL:  result = operand_a >> operand_b[4:0];
      ALU_SRA:  result = $signed(operand_a) >>> operand_b[4:0];
      ALU_SLT:  result = {31'b0, ($signed(operand_a) < $signed(operand_b))};
      ALU_SLTU: result = {31'b0, (operand_a < operand_b)};
      default:  result = '0;
    endcase
  end

endmodule
