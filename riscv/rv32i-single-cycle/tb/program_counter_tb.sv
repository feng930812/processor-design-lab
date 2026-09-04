module program_counter_tb;

  timeunit 1ns;
  timeprecision 1ps;

  logic        clk;
  logic        reset;
  logic [31:0] next_pc;
  logic [31:0] pc;
  int unsigned test_count;
  int unsigned error_count;

  program_counter dut (
    .clk     (clk),
    .reset   (reset),
    .next_pc (next_pc),
    .pc      (pc)
  );

  always #5 clk = ~clk;

  task automatic check_pc(
    input logic [31:0] expected_pc,
    input string       test_name
  );
    test_count++;

    if (pc !== expected_pc) begin
      error_count++;
      $error("FAIL: %s, expected=%h actual=%h",
             test_name, expected_pc, pc);
    end else begin
      $display("PASS: %s, pc=%h", test_name, pc);
    end
  endtask

  initial begin
    clk         = 1'b0;
    reset       = 1'b1;
    next_pc     = 32'h1234_5678;
    test_count  = 0;
    error_count = 0;

    // Reset is synchronous and must take priority over next_pc.
    @(posedge clk);
    #1;
    check_pc(32'h0000_0000, "reset initializes PC to zero");

    next_pc = 32'hffff_ffff;
    @(posedge clk);
    #1;
    check_pc(32'h0000_0000, "reset holds PC at zero");

    // Once reset is released, PC captures next_pc on each rising edge.
    @(negedge clk);
    reset   = 1'b0;
    next_pc = 32'h0000_0004;
    #1;
    check_pc(32'h0000_0000, "PC does not update before rising edge");

    @(posedge clk);
    #1;
    check_pc(32'h0000_0004, "PC captures next_pc on rising edge");

    // Changing next_pc between rising edges must not change PC.
    @(negedge clk);
    next_pc = 32'h8000_0000;
    #1;
    check_pc(32'h0000_0004, "PC remains stable between rising edges");

    @(posedge clk);
    #1;
    check_pc(32'h8000_0000, "PC accepts a value with the top bit set");

    // Assert reset while PC is nonzero; it takes effect at the next edge.
    @(negedge clk);
    reset   = 1'b1;
    next_pc = 32'hdead_beef;
    #1;
    check_pc(32'h8000_0000, "synchronous reset waits for rising edge");

    @(posedge clk);
    #1;
    check_pc(32'h0000_0000, "reset overrides next_pc");

    $display("Tests: %0d, Passed: %0d, Failed: %0d",
             test_count, test_count - error_count, error_count);

    if (error_count != 0) begin
      $fatal(1, "Program counter testbench failed");
    end

    $finish;
  end

endmodule
