module alu_result_register (
    input  logic        clk,
    input  logic        reset,
    input  logic        write_enable,
    input  logic [31:0] alu_result,
    output logic [31:0] alu_out
);

    always_ff @(posedge clk) begin
        if (reset) begin
            alu_out <= '0;
        end
        else if (write_enable) begin
            alu_out <= alu_result;
        end
    end

endmodule
