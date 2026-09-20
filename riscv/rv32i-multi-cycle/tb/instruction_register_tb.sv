module instruction_register_tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic clk = 0;
    logic reset;
    logic write_enable;
    logic [31:0] instruction_in;
    logic [31:0] instruction;
    int unsigned test_count = 0;

    instruction_register dut (.*);
    always #5 clk = ~clk;

    task automatic check(input logic [31:0] expected, input string label_text);
        test_count++;
        if (instruction !== expected)
            $fatal(1, "FAIL: %s: expected=%h actual=%h",
                   label_text, expected, instruction);
        $display("PASS: %s", label_text);
    endtask

    initial begin
        reset = 1;
        write_enable = 1;
        instruction_in = 32'hffff_ffff;
        @(posedge clk);
        #1;
        check(32'h0000_0013, "reset overrides write enable");

        @(negedge clk);
        reset = 0;
        instruction_in = 32'h0020_81b3;
        #1;
        check(32'h0000_0013, "write waits for rising edge");
        @(posedge clk);
        #1;
        check(32'h0020_81b3, "capture ADD instruction");

        @(negedge clk);
        write_enable = 0;
        instruction_in = 32'h0000_0013;
        #1;
        check(32'h0020_81b3, "input changes do not change output");
        repeat (3) begin
            @(posedge clk);
            #1;
            check(32'h0020_81b3, "hold while write disabled");
        end

        @(negedge clk);
        write_enable = 1;
        instruction_in = 32'hffff_ffff;
        @(posedge clk);
        #1;
        check(32'hffff_ffff, "capture all one bits");
        @(negedge clk);
        instruction_in = 32'h0000_0000;
        @(posedge clk);
        #1;
        check(32'h0000_0000, "capture on consecutive enabled cycles");

        @(negedge clk);
        reset = 1;
        write_enable = 0;
        #1;
        check(32'h0000_0000, "synchronous reset waits for rising edge");
        @(posedge clk);
        #1;
        check(32'h0000_0013, "reset works with write disabled");
        @(posedge clk);
        #1;
        check(32'h0000_0013, "reset holds NOP");

        @(negedge clk);
        reset = 0;
        @(posedge clk);
        #1;
        check(32'h0000_0013, "hold NOP after reset release");

        $display("All %0d checks passed", test_count);
        $finish;
    end

    initial begin
        #1000;
        $fatal(1, "Simulation timed out");
    end
endmodule
