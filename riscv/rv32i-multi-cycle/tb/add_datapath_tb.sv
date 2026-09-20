module add_datapath_tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic clk = 0;
    logic reset;
    logic operand_write_enable, alu_write_enable;
    logic [31:0] rs1_data, rs2_data, alu_out;
    int unsigned test_count = 0;

    add_datapath dut (.*);
    always #5 clk = ~clk;

    task automatic check(input logic [31:0] expected, input string label_text);
        test_count++;
        if (alu_out !== expected)
            $fatal(1, "FAIL: %s: expected=%h actual=%h", label_text, expected, alu_out);
        $display("PASS: %s", label_text);
    endtask

    task automatic run_add(input logic [31:0] a, b, expected);
        logic [31:0] previous_result;
        previous_result = alu_out;
        @(negedge clk);
        operand_write_enable = 1;
        alu_write_enable = 0;
        rs1_data = a;
        rs2_data = b;
        @(posedge clk);
        #1;
        check(previous_result, "DECODE preserves previous ALUOut");

        @(negedge clk);
        operand_write_enable = 0;
        alu_write_enable = 1;
        // Execution must use saved operands, not these new input values.
        rs1_data = 99;
        rs2_data = 100;
        #1;
        check(previous_result, "EXECUTE waits for rising edge");
        @(posedge clk);
        #1;
        check(expected, "EXECUTE adds saved operands");

        @(negedge clk);
        alu_write_enable = 0;
        repeat (2) begin
            @(posedge clk);
            #1;
            check(expected, "hold result for WRITEBACK and idle cycles");
        end
    endtask

    initial begin
        reset = 1;
        operand_write_enable = 1;
        alu_write_enable = 1;
        rs1_data = 10;
        rs2_data = 20;
        @(posedge clk);
        #1;
        check(0, "reset overrides enabled captures");
        @(negedge clk);
        reset = 0;
        operand_write_enable = 0;
        // Capture the sum of reset A/B to verify their reset wiring too.
        @(posedge clk);
        #1;
        check(0, "reset cleared saved operands");

        run_add(10, 20, 30);
        run_add(32'hffff_ffff, 1, 0);
        run_add(32'h7fff_ffff, 1, 32'h8000_0000);
        run_add(32'h8000_0000, 32'h8000_0000, 0);
        run_add(0, 42, 42);

        @(negedge clk);
        reset = 1;
        #1;
        check(42, "synchronous reset waits for rising edge");
        @(posedge clk);
        #1;
        check(0, "reset clears nonzero result");

        $display("All %0d checks passed", test_count);
        $finish;
    end

    initial begin
        #2000;
        $fatal(1, "Simulation timed out");
    end
endmodule
