module instruction_memory_tb;

  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] address;
  logic [31:0] read_data;
  int unsigned test_count;
  int unsigned error_count;

  instruction_memory #(
    .WORD_COUNT (4)
  ) dut (
    .address   (address),
    .read_data (read_data)
  );

  task automatic check_read(
    input logic [31:0] test_address,
    input logic [31:0] expected_data,
    input string       test_name
  );
    address = test_address;
    #1;
    test_count++;

    if (read_data !== expected_data) begin
      error_count++;
      $error("FAIL: %s, address=%h expected=%h actual=%h",
             test_name, test_address, expected_data, read_data);
    end else begin
      $display("PASS: %s", test_name);
    end
  endtask

  initial begin
    address     = 32'b0;
    test_count  = 0;
    error_count = 0;

    dut.memory[0] = 32'h0050_0093;
    dut.memory[1] = 32'h0030_0113;
    dut.memory[2] = 32'h0020_81b3;
    dut.memory[3] = 32'h0000_006f;

    check_read(32'h0000_0000, 32'h0050_0093, "read first instruction");
    check_read(32'h0000_0004, 32'h0030_0113, "word address selects second instruction");
    check_read(32'h0000_000c, 32'h0000_006f, "read last instruction");
    check_read(32'h0000_0002, 32'h0000_0013, "misaligned address returns NOP");
    check_read(32'h0000_0010, 32'h0000_0013, "out-of-range address returns NOP");

    $display("Tests: %0d, Passed: %0d, Failed: %0d",
             test_count, test_count - error_count, error_count);
    if (error_count != 0) $fatal(1, "Instruction memory testbench failed");
    $finish;
  end

endmodule
