module alu_result_register_tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic clk = 0;
    logic reset;
    logic write_enable;
    logic [31:0] alu_result;
    logic [31:0] alu_out;
    int unsigned test_count = 0;

    alu_result_register dut (.*);
    always #5 clk = ~clk;

    task automatic check(input logic [31:0] expected, input string label_text);
        test_count++;
        if (alu_out !== expected)
            $fatal(1, "FAIL: %s: expected=%h actual=%h", label_text, expected, alu_out);
        $display("PASS: %s", label_text);
    endtask

    initial begin
        reset = 1;
        write_enable = 1;
        alu_result = 32'hffff_ffff;
        @(posedge clk);
        #1;
        check(0, "reset overrides result capture");

        @(negedge clk);
        reset = 0;
        alu_result = 30;
        #1;
        check(0, "capture waits for rising edge");
        @(posedge clk);
        #1;
        check(30, "capture execution result");

        @(negedge clk);
        write_enable = 0;
        alu_result = 99;
        #1;
        check(30, "ALU input changes do not change saved result");
        repeat (3) begin
            @(posedge clk);
            #1;
            check(30, "preserve result while capture disabled");
        end

        @(negedge clk);
        write_enable = 1;
        alu_result = 32'haaaa_5555;
        @(posedge clk);
        #1;
        check(32'haaaa_5555, "capture full-width pattern");
        @(negedge clk);
        alu_result = 32'h5555_aaaa;
        @(posedge clk);
        #1;
        check(32'h5555_aaaa, "capture complementary pattern on next cycle");

        @(negedge clk);
        reset = 1;
        write_enable = 0;
        #1;
        check(32'h5555_aaaa, "synchronous reset waits for rising edge");
        @(posedge clk);
        #1;
        check(0, "reset works with capture disabled");
        @(posedge clk);
        #1;
        check(0, "hold zero during reset");

        @(negedge clk);
        reset = 0;
        @(posedge clk);
        #1;
        check(0, "hold after reset release");
        @(negedge clk);
        write_enable = 1;
        alu_result = 42;
        @(posedge clk);
        #1;
        check(42, "resume capture after reset");

        $display("All %0d checks passed", test_count);
        $finish;
    end

    initial begin
        #1000;
        $fatal(1, "Simulation timed out");
    end
endmodule
