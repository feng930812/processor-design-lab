module operand_registers (
    input  logic        clk,
    input  logic        reset,
    input  logic        write_enable,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    output logic [31:0] operand_a,
    output logic [31:0] operand_b
);

    always_ff @(posedge clk) begin
        if (reset) begin
            operand_a <= '0;
            operand_b <= '0;
        end
        else if (write_enable) begin
            operand_a <= rs1_data;
            operand_b <= rs2_data;
        end
    end

endmodule
