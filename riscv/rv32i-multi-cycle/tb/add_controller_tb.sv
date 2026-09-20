module add_controller_tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic clk = 0;
    logic reset;
    logic ir_write_enable, operand_write_enable, alu_write_enable;
    logic reg_write_enable, pc_write_enable;
    int unsigned test_count = 0;
    localparam logic [1:0] FETCH = 0, DECODE = 1, EXECUTE = 2, WRITEBACK = 3;

    add_controller dut (.*);
    always #5 clk = ~clk;

    // Check the public outputs as well as the internal state sequence.
    task automatic check(input logic [1:0] expected, input string label_text);
        logic [4:0] expected_enables;
        test_count++;
        if (dut.state !== expected)
            $fatal(1, "FAIL: %s: expected state=%0d actual=%0d",
                   label_text, expected, dut.state);
        expected_enables = 5'b00000;
        if (!reset) begin
            case (expected)
                FETCH:     expected_enables = 5'b10000;
                DECODE:    expected_enables = 5'b01000;
                EXECUTE:   expected_enables = 5'b00100;
                WRITEBACK: expected_enables = 5'b00011;
            endcase
        end
        if ({ir_write_enable, operand_write_enable, alu_write_enable,
             reg_write_enable, pc_write_enable} !== expected_enables)
            $fatal(1, "FAIL: %s: expected enables=%b actual=%b", label_text,
                   expected_enables, {ir_write_enable, operand_write_enable,
                   alu_write_enable, reg_write_enable, pc_write_enable});
        $display("PASS: %s", label_text);
    endtask

    task automatic step(input logic [1:0] expected);
        @(posedge clk);
        #1;
        check(expected, "state sequence");
        @(negedge clk);
        #1;
        check(expected, "state holds between rising edges");
    endtask

    initial begin
        reset = 1;
        step(FETCH);
        step(FETCH);
        reset = 0;
        #1;
        check(FETCH, "FETCH output enabled after reset release");
        repeat (3) begin
            step(DECODE);
            step(EXECUTE);
            step(WRITEBACK);
            step(FETCH);
        end

        // Reset from each non-FETCH stage and check restart behavior.
        for (int stage = 1; stage <= 3; stage++) begin
            for (int index = 1; index <= stage; index++)
                step(index[1:0]);
            reset = 1;
            #1;
            check(stage[1:0], "synchronous reset waits for rising edge");
            step(FETCH);
            step(FETCH);
            reset = 0;
            #1;
            check(FETCH, "FETCH output restored after reset release");
        end
        step(DECODE);
        $display("All %0d checks passed", test_count);
        $finish;
    end

    initial begin
        #2000;
        $fatal(1, "Simulation timed out");
    end
endmodule
