module load_store_unit_tb;

  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0]          address;
  logic [31:0]          store_data;
  logic [31:0]          memory_read_data;
  rv32i_pkg::mem_size_t memory_size;
  logic                 load_unsigned;
  logic [31:0]          load_data;
  logic [31:0]          memory_write_data;
  logic [3:0]           memory_byte_enable;
  logic                 misaligned_access;

  int unsigned test_count;
  int unsigned error_count;

  load_store_unit dut (
    .address            (address),
    .store_data         (store_data),
    .memory_read_data   (memory_read_data),
    .memory_size        (memory_size),
    .load_unsigned      (load_unsigned),
    .load_data          (load_data),
    .memory_write_data  (memory_write_data),
    .memory_byte_enable (memory_byte_enable),
    .misaligned_access  (misaligned_access)
  );

  task automatic check_load(
    input rv32i_pkg::mem_size_t test_size,
    input logic [1:0]           address_offset,
    input logic                 test_unsigned,
    input logic [31:0]          expected_data,
    input logic                 expected_misaligned,
    input string                test_name
  );
    memory_size   = test_size;
    address       = {30'b0, address_offset};
    load_unsigned = test_unsigned;

    #1;
    test_count++;

    if ((load_data !== expected_data) ||
        (misaligned_access !== expected_misaligned)) begin
      error_count++;
      $error("FAIL: %s, data expected=%h actual=%h, misaligned expected=%b actual=%b",
             test_name, expected_data, load_data,
             expected_misaligned, misaligned_access);
    end else begin
      $display("PASS: %s", test_name);
    end
  endtask

  task automatic check_store(
    input rv32i_pkg::mem_size_t test_size,
    input logic [1:0]           address_offset,
    input logic [31:0]          expected_data,
    input logic [3:0]           expected_enable,
    input logic                 expected_misaligned,
    input string                test_name
  );
    memory_size = test_size;
    address     = {30'b0, address_offset};

    #1;
    test_count++;

    if ((memory_write_data !== expected_data) ||
        (memory_byte_enable !== expected_enable) ||
        (misaligned_access !== expected_misaligned)) begin
      error_count++;
      $error("FAIL: %s, data expected=%h actual=%h, enable expected=%b actual=%b, misaligned expected=%b actual=%b",
             test_name, expected_data, memory_write_data,
             expected_enable, memory_byte_enable,
             expected_misaligned, misaligned_access);
    end else begin
      $display("PASS: %s", test_name);
    end
  endtask

  initial begin
    address          = '0;
    store_data       = 32'h1234_abcd;
    memory_read_data = 32'ha1b2_c3d4;
    memory_size      = rv32i_pkg::MEM_BYTE;
    load_unsigned    = 1'b0;
    test_count       = 0;
    error_count      = 0;

    check_load(rv32i_pkg::MEM_BYTE, 2'b00, 1'b0,
               32'hffff_ffd4, 1'b0, "LB byte 0 sign extension");
    check_load(rv32i_pkg::MEM_BYTE, 2'b01, 1'b0,
               32'hffff_ffc3, 1'b0, "LB byte 1 sign extension");
    check_load(rv32i_pkg::MEM_BYTE, 2'b10, 1'b1,
               32'h0000_00b2, 1'b0, "LBU byte 2 zero extension");
    check_load(rv32i_pkg::MEM_BYTE, 2'b11, 1'b1,
               32'h0000_00a1, 1'b0, "LBU byte 3 zero extension");

    check_load(rv32i_pkg::MEM_HALF, 2'b00, 1'b0,
               32'hffff_c3d4, 1'b0, "LH lower half sign extension");
    check_load(rv32i_pkg::MEM_HALF, 2'b10, 1'b1,
               32'h0000_a1b2, 1'b0, "LHU upper half zero extension");
    check_load(rv32i_pkg::MEM_HALF, 2'b01, 1'b1,
               32'h0000_b2c3, 1'b1, "misaligned half load");
    check_load(rv32i_pkg::MEM_WORD, 2'b00, 1'b0,
               32'ha1b2_c3d4, 1'b0, "LW aligned word");
    check_load(rv32i_pkg::MEM_WORD, 2'b10, 1'b0,
               32'h0000_a1b2, 1'b1, "misaligned word load");

    check_store(rv32i_pkg::MEM_BYTE, 2'b00,
                32'h0000_00cd, 4'b0001, 1'b0, "SB byte 0");
    check_store(rv32i_pkg::MEM_BYTE, 2'b01,
                32'h0000_cd00, 4'b0010, 1'b0, "SB byte 1");
    check_store(rv32i_pkg::MEM_BYTE, 2'b10,
                32'h00cd_0000, 4'b0100, 1'b0, "SB byte 2");
    check_store(rv32i_pkg::MEM_BYTE, 2'b11,
                32'hcd00_0000, 4'b1000, 1'b0, "SB byte 3");

    check_store(rv32i_pkg::MEM_HALF, 2'b00,
                32'h0000_abcd, 4'b0011, 1'b0, "SH lower half");
    check_store(rv32i_pkg::MEM_HALF, 2'b10,
                32'habcd_0000, 4'b1100, 1'b0, "SH upper half");
    check_store(rv32i_pkg::MEM_HALF, 2'b01,
                32'h00ab_cd00, 4'b0110, 1'b1, "misaligned half store");
    check_store(rv32i_pkg::MEM_WORD, 2'b00,
                32'h1234_abcd, 4'b1111, 1'b0, "SW aligned word");
    check_store(rv32i_pkg::MEM_WORD, 2'b01,
                32'h1234_abcd, 4'b1111, 1'b1, "misaligned word store");

    $display("Tests: %0d, Passed: %0d, Failed: %0d",
             test_count, test_count - error_count, error_count);

    if (error_count != 0)
      $fatal(1, "Load/store unit testbench failed");

    $finish;
  end

endmodule
