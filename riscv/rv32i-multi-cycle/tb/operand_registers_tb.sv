module operand_registers_tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic clk = 0;
    logic reset;
    logic write_enable;
    logic [31:0] rs1_data, rs2_data;
    logic [31:0] operand_a, operand_b;
    int unsigned test_count = 0;

    operand_registers dut (.*);
    always #5 clk = ~clk;

    task automatic check(input logic [31:0] expected_a,
                         input logic [31:0] expected_b,
                         input string label_text);
        test_count++;
        if (operand_a !== expected_a || operand_b !== expected_b)
            $fatal(1, "FAIL: %s: expected A=%h B=%h, actual A=%h B=%h",
                   label_text, expected_a, expected_b, operand_a, operand_b);
        $display("PASS: %s", label_text);
    endtask

    initial begin
        reset = 1;
        write_enable = 1;
        rs1_data = 32'hffff_ffff;
        rs2_data = 32'haaaa_5555;
        @(posedge clk);
        #1;
        check(0, 0, "reset overrides both writes");

        @(negedge clk);
        reset = 0;
        rs1_data = 10;
        rs2_data = 20;
        #1;
        check(0, 0, "operands wait for rising edge");
        @(posedge clk);
        #1;
        check(10, 20, "capture distinct operands in correct order");

        @(negedge clk);
        write_enable = 0;
        rs1_data = 32'h1234_5678;
        rs2_data = 32'h8765_4321;
        #1;
        check(10, 20, "input changes do not change operands");
        repeat (3) begin
            @(posedge clk);
            #1;
            check(10, 20, "hold both operands across execution cycles");
        end

        @(negedge clk);
        write_enable = 1;
        rs1_data = 32'haaaa_5555;
        rs2_data = 32'h5555_aaaa;
        @(posedge clk);
        #1;
        check(32'haaaa_5555, 32'h5555_aaaa, "capture full-width distinct patterns");
        @(negedge clk);
        rs1_data = 32'h5555_aaaa;
        rs2_data = 32'haaaa_5555;
        @(posedge clk);
        #1;
        check(32'h5555_aaaa, 32'haaaa_5555, "update both operands on consecutive cycles");

        @(negedge clk);
        reset = 1;
        write_enable = 0;
        #1;
        check(32'h5555_aaaa, 32'haaaa_5555, "synchronous reset waits for rising edge");
        @(posedge clk);
        #1;
        check(0, 0, "reset clears both operands with writes disabled");
        @(posedge clk);
        #1;
        check(0, 0, "hold zero during reset");

        @(negedge clk);
        reset = 0;
        @(posedge clk);
        #1;
        check(0, 0, "hold after reset release");
        @(negedge clk);
        write_enable = 1;
        rs1_data = 30;
        rs2_data = 40;
        @(posedge clk);
        #1;
        check(30, 40, "resume capture after reset");

        $display("All %0d checks passed", test_count);
        $finish;
    end

    initial begin
        #1000;
        $fatal(1, "Simulation timed out");
    end
endmodule
