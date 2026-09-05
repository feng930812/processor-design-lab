module data_memory_tb;

  timeunit 1ns;
  timeprecision 1ps;

  logic        clk;
  logic [31:0] address;
  logic [31:0] write_data;
  logic [3:0]  byte_enable;
  logic        read_enable;
  logic        write_enable;
  logic [31:0] read_data;
  int unsigned test_count;
  int unsigned error_count;

  data_memory #(
    .BYTE_COUNT (16)
  ) dut (
    .clk          (clk),
    .address      (address),
    .write_data   (write_data),
    .byte_enable  (byte_enable),
    .read_enable  (read_enable),
    .write_enable (write_enable),
    .read_data    (read_data)
  );

  always #5 clk = ~clk;

  task automatic check_read(
    input logic [31:0] expected_data,
    input string       test_name
  );
    #1;
    test_count++;
    if (read_data !== expected_data) begin
      error_count++;
      $error("FAIL: %s, expected=%h actual=%h", test_name,
             expected_data, read_data);
    end else begin
      $display("PASS: %s", test_name);
    end
  endtask

  initial begin
    clk          = 1'b0;
    address      = 32'b0;
    write_data   = 32'b0;
    byte_enable  = 4'b0000;
    read_enable  = 1'b0;
    write_enable = 1'b0;
    test_count   = 0;
    error_count  = 0;

    for (int i = 0; i < 16; i++) dut.memory[i] = 8'b0;

    check_read(32'b0, "disabled read returns zero");

    @(negedge clk);
    address      = 32'h0000_0000;
    write_data   = 32'h1234_5678;
    byte_enable  = 4'b1111;
    write_enable = 1'b1;
    @(posedge clk);
    #1;
    write_enable = 1'b0;
    read_enable  = 1'b1;
    check_read(32'h1234_5678, "full-word write and read");

    @(negedge clk);
    address      = 32'h0000_0002;
    write_data   = 32'haabb_0000;
    byte_enable  = 4'b1100;
    write_enable = 1'b1;
    @(posedge clk);
    #1;
    write_enable = 1'b0;
    check_read(32'haabb_5678, "byte enables update selected lanes");

    @(negedge clk);
    address      = 32'h0000_0005;
    write_data   = 32'h0000_cc00;
    byte_enable  = 4'b0010;
    write_enable = 1'b1;
    @(posedge clk);
    #1;
    write_enable = 1'b0;
    check_read(32'h0000_cc00, "address is aligned before lane selection");

    read_enable = 1'b0;
    check_read(32'b0, "read enable gates output");

    address     = 32'h0000_0010;
    read_enable = 1'b1;
    check_read(32'b0, "out-of-range read returns zero");

    $display("Tests: %0d, Passed: %0d, Failed: %0d",
             test_count, test_count - error_count, error_count);
    if (error_count != 0) $fatal(1, "Data memory testbench failed");
    $finish;
  end

endmodule
