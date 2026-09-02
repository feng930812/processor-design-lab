module register_file_tb;

  timeunit 1ns;
  timeprecision 1ps;

  logic        clk;
  logic [4:0]  rs1_addr;
  logic [4:0]  rs2_addr;
  logic [4:0]  rd_addr;
  logic [31:0] rd_data;
  logic        write_enable;
  logic [31:0] rs1_data;
  logic [31:0] rs2_data;
  int unsigned test_count;
  int unsigned error_count;

  register_file dut (
    .clk          (clk),
    .rs1_addr     (rs1_addr),
    .rs2_addr     (rs2_addr),
    .rd_addr      (rd_addr),
    .rd_data      (rd_data),
    .write_enable (write_enable),
    .rs1_data     (rs1_data),
    .rs2_data     (rs2_data)
  );

  always #5 clk <= ~clk;

  task automatic write_register(
    input logic [4:0]  address,
    input logic [31:0] data
  );
    @(negedge clk);
    rd_addr      = address;
    rd_data      = data;
    write_enable = 1'b1;

    @(posedge clk);
    #1;

    write_enable = 1'b0;
  endtask

  task automatic check_reads(
    input logic [4:0]  test_rs1_addr,
    input logic [31:0] expected_rs1,
    input logic [4:0]  test_rs2_addr,
    input logic [31:0] expected_rs2,
    input string       test_name
  );
    rs1_addr = test_rs1_addr;
    rs2_addr = test_rs2_addr;

    #1;
    test_count++;

    if ((rs1_data !== expected_rs1) || (rs2_data !== expected_rs2)) begin
      error_count++;
      $error("FAIL: %s, rs1=%0d expected=%h actual=%h, rs2=%0d expected=%h actual=%h",
             test_name,
             test_rs1_addr, expected_rs1, rs1_data,
             test_rs2_addr, expected_rs2, rs2_data);
    end else begin
      $display("PASS: %s", test_name);
    end
  endtask

  initial begin
    clk          = 1'b0;
    rs1_addr     = 5'd0;
    rs2_addr     = 5'd0;
    rd_addr      = 5'd0;
    rd_data      = '0;
    write_enable = 1'b0;
    test_count   = 0;
    error_count  = 0;

    check_reads(5'd0, 32'd0, 5'd0, 32'd0,
                "x0 reads as zero");

    write_register(5'd1, 32'h1234_5678);
    write_register(5'd2, 32'hdead_beef);
    check_reads(5'd1, 32'h1234_5678, 5'd2, 32'hdead_beef,
                "two read ports read different registers");

    @(negedge clk);
    rd_addr      = 5'd1;
    rd_data      = 32'haaaa_5555;
    write_enable = 1'b0;
    @(posedge clk);
    #1;
    check_reads(5'd1, 32'h1234_5678, 5'd2, 32'hdead_beef,
                "write_enable blocks a write");

    write_register(5'd0, 32'hffff_ffff);
    check_reads(5'd0, 32'd0, 5'd1, 32'h1234_5678,
                "writes to x0 are ignored");

    write_register(5'd3, 32'h1111_1111);
    @(negedge clk);
    rd_addr      = 5'd3;
    rd_data      = 32'h2222_2222;
    write_enable = 1'b1;
    check_reads(5'd3, 32'h1111_1111, 5'd0, 32'd0,
                "write does not occur before rising edge");
    @(posedge clk);
    #1;
    write_enable = 1'b0;
    check_reads(5'd3, 32'h2222_2222, 5'd0, 32'd0,
                "write occurs on rising edge");

    $display("Tests: %0d, Passed: %0d, Failed: %0d",
             test_count, test_count - error_count, error_count);

    if (error_count != 0) begin
      $fatal(1, "Register file testbench failed");
    end

    $finish;
  end

endmodule
