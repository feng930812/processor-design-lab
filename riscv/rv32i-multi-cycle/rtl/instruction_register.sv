module instruction_register (
    input  logic        clk,
    input  logic        reset,
    input  logic        write_enable,
    input  logic [31:0] instruction_in,

    output logic [31:0] instruction
);

    always_ff @(posedge clk) begin
        if (reset) begin
            instruction <= 32'h00000013;
        end else if (write_enable) begin
            instruction <= instruction_in;
        end
    end

endmodule
