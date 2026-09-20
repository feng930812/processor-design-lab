module add_datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic        operand_write_enable,
    input  logic        alu_write_enable,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    output logic [31:0] alu_out
);

    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [31:0] alu_result;

    operand_registers u_operands (
        .clk          (clk),
        .reset        (reset),
        .write_enable (operand_write_enable),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .operand_a    (operand_a),
        .operand_b    (operand_b)
    );

    assign alu_result = operand_a + operand_b;

    alu_result_register u_alu_results (
        .clk          (clk),
        .reset        (reset),
        .write_enable (alu_write_enable),
        .alu_result   (alu_result),
        .alu_out      (alu_out)
    );

endmodule
