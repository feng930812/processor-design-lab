module program_counter_tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic clk = 0;
    logic reset;
    logic write_enable;
    logic [31:0] next_pc;
    logic [31:0] pc;
    int unsigned test_count = 0;

    program_counter dut (.*);
    always #5 clk = ~clk;

    task automatic check(input logic [31:0] expected, input string label_text);
        test_count++;
        if (pc !== expected)
            $fatal(1, "FAIL: %s: expected=%h actual=%h", label_text, expected, pc);
        $display("PASS: %s", label_text);
    endtask

    initial begin
        reset = 1;
        write_enable = 1;
        next_pc = 32'hffff_fffc;
        @(posedge clk);
        #1;
        check(0, "reset overrides enabled update");

        @(negedge clk);
        reset = 0;
        next_pc = 4;
        #1;
        check(0, "update waits for rising edge");
        @(posedge clk);
        #1;
        check(4, "load sequential address");

        @(negedge clk);
        write_enable = 0;
        next_pc = 32'h8000_0100;
        #1;
        check(4, "input changes do not change PC");
        repeat (3) begin
            @(posedge clk);
            #1;
            check(4, "hold PC across instruction stages");
        end

        @(negedge clk);
        write_enable = 1;
        @(posedge clk);
        #1;
        check(32'h8000_0100, "load jump target including upper address bits");
        @(negedge clk);
        next_pc = 32'h0000_0020;
        @(posedge clk);
        #1;
        check(32'h0000_0020, "load lower target on consecutive enabled cycle");

        @(negedge clk);
        reset = 1;
        write_enable = 0;
        #1;
        check(32'h0000_0020, "synchronous reset waits for rising edge");
        @(posedge clk);
        #1;
        check(0, "reset works with updates disabled");
        @(posedge clk);
        #1;
        check(0, "hold zero during reset");

        @(negedge clk);
        reset = 0;
        @(posedge clk);
        #1;
        check(0, "hold zero after reset release");
        @(negedge clk);
        write_enable = 1;
        next_pc = 4;
        @(posedge clk);
        #1;
        check(4, "resume updates after reset");

        $display("All %0d checks passed", test_count);
        $finish;
    end

    initial begin
        #1000;
        $fatal(1, "Simulation timed out");
    end
endmodule
