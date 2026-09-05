module rv32i_core_tb;

  timeunit 1ns;
  timeprecision 1ps;

  logic        clk;
  logic        reset;
  logic [31:0] instruction_read_data;
  logic [31:0] data_read_data;
  logic [31:0] instruction_address;
  logic [31:0] data_address;
  logic [31:0] data_write_data;
  logic [3:0]  data_byte_enable;
  logic        data_read_enable;
  logic        data_write_enable;
  logic        data_address_misaligned;
  logic        instruction_address_misaligned;
  logic        illegal_instruction;
  logic        environment_call;
  logic        breakpoint;
  int unsigned test_count;
  int unsigned error_count;

  rv32i_core dut (
    .clk                   (clk),
    .reset                 (reset),
    .instruction_read_data (instruction_read_data),
    .data_read_data        (data_read_data),
    .instruction_address   (instruction_address),
    .data_address          (data_address),
    .data_write_data       (data_write_data),
    .data_byte_enable      (data_byte_enable),
    .data_read_enable      (data_read_enable),
    .data_write_enable     (data_write_enable),
    .data_address_misaligned (data_address_misaligned),
    .instruction_address_misaligned (instruction_address_misaligned),
    .illegal_instruction   (illegal_instruction),
    .environment_call      (environment_call),
    .breakpoint            (breakpoint)
  );

  always #5 clk = ~clk;

  task automatic check_instruction_address(
    input logic [31:0] expected_address,
    input string       test_name
  );
    test_count++;

    if (instruction_address !== expected_address) begin
      error_count++;
      $error("FAIL: %s, expected=%h actual=%h",
             test_name, expected_address, instruction_address);
    end else begin
      $display("PASS: %s, instruction_address=%h",
               test_name, instruction_address);
    end
  endtask

  task automatic check_exceptions(
    input logic expected_instruction_misaligned,
    input logic expected_illegal,
    input logic expected_environment_call,
    input logic expected_breakpoint,
    input string test_name
  );
    #1;
    test_count++;

    if ((instruction_address_misaligned !== expected_instruction_misaligned) ||
        (illegal_instruction !== expected_illegal) ||
        (environment_call !== expected_environment_call) ||
        (breakpoint !== expected_breakpoint)) begin
      error_count++;
      $error("FAIL: %s, imisaligned=%b illegal=%b ecall=%b ebreak=%b",
             test_name, instruction_address_misaligned, illegal_instruction,
             environment_call, breakpoint);
    end else begin
      $display("PASS: %s", test_name);
    end
  endtask

  task automatic check_data_interface(
    input logic [31:0] expected_address,
    input logic [31:0] expected_write_data,
    input logic [3:0]  expected_byte_enable,
    input logic        expected_read_enable,
    input logic        expected_write_enable,
    input logic        expected_misaligned,
    input string       test_name
  );
    test_count++;

    if ((data_address !== expected_address) ||
        (data_write_data !== expected_write_data) ||
        (data_byte_enable !== expected_byte_enable) ||
        (data_read_enable !== expected_read_enable) ||
        (data_write_enable !== expected_write_enable) ||
        (data_address_misaligned !== expected_misaligned)) begin
      error_count++;
      $error("FAIL: %s, addr=%h wdata=%h be=%b re=%b we=%b misaligned=%b",
             test_name, data_address, data_write_data, data_byte_enable,
             data_read_enable, data_write_enable, data_address_misaligned);
    end else begin
      $display("PASS: %s", test_name);
    end
  endtask

  task automatic check_register(
    input logic [4:0]  register_index,
    input logic [31:0] expected_value,
    input string       test_name
  );
    test_count++;

    if (dut.u_register_file.registers[register_index] !== expected_value) begin
      error_count++;
      $error("FAIL: %s, x%0d expected=%h actual=%h",
             test_name, register_index, expected_value,
             dut.u_register_file.registers[register_index]);
    end else begin
      $display("PASS: %s, x%0d=%h", test_name, register_index,
               dut.u_register_file.registers[register_index]);
    end
  endtask

  initial begin
    clk                   = 1'b0;
    reset                 = 1'b1;
    instruction_read_data = 32'h0000_0013; // ADDI x0, x0, 0 (NOP)
    data_read_data        = 32'b0;
    test_count            = 0;
    error_count           = 0;

    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0000,
                              "reset initializes instruction address");

    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0000,
                              "reset holds instruction address at zero");

    @(negedge clk);
    reset = 1'b0;
    #1;
    check_instruction_address(32'h0000_0000,
                              "releasing reset does not update PC immediately");

    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0004,
                              "first sequential instruction address");

    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0008,
                              "second sequential instruction address");

    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_000c,
                              "third sequential instruction address");

    @(negedge clk);
    #1;
    check_instruction_address(32'h0000_000c,
                              "instruction address is stable at falling edge");

    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0010,
                              "fourth sequential instruction address");

    @(negedge clk);
    reset = 1'b1;
    #1;
    check_instruction_address(32'h0000_0010,
                              "synchronous reset does not act before rising edge");

    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0000,
                              "reset returns instruction address to zero");

    // Execute a short ADDI sequence through the integrated datapath.
    @(negedge clk);
    reset                 = 1'b0;
    instruction_read_data = 32'h0050_0093; // ADDI x1, x0, 5
    @(posedge clk);
    #1;
    check_register(5'd1, 32'd5, "ADDI writes a positive immediate to x1");

    @(negedge clk);
    instruction_read_data = 32'hffe0_8113; // ADDI x2, x1, -2
    @(posedge clk);
    #1;
    check_register(5'd2, 32'd3, "ADDI reads x1 and sign-extends -2");

    @(negedge clk);
    instruction_read_data = 32'h8000_0193; // ADDI x3, x0, -2048
    @(posedge clk);
    #1;
    check_register(5'd3, 32'hffff_f800,
                   "ADDI handles the minimum I-type immediate");

    @(negedge clk);
    instruction_read_data = 32'h0090_0213; // ADDI x4, x0, 9
    @(posedge clk);
    #1;
    check_register(5'd4, 32'd9, "ADDI initializes x4");

    @(negedge clk);
    instruction_read_data = 32'h0000_027f; // Unknown opcode with rd=x4
    @(posedge clk);
    #1;
    check_register(5'd4, 32'd9, "illegal instruction does not write a register");

    // PC is 0x14 here. Since x1=5 and x2=3, BNE jumps forward by 8.
    @(negedge clk);
    instruction_read_data = 32'h0020_9463; // BNE x1, x2, +8
    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_001c,
                              "taken BNE selects forward branch target");

    // At PC 0x1c, BEQ is not taken and therefore advances to 0x20.
    @(negedge clk);
    instruction_read_data = 32'h0020_8463; // BEQ x1, x2, +8
    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0020,
                              "untaken BEQ selects PC plus 4");

    // Equal operands take a backward branch from 0x20 to 0x1c.
    @(negedge clk);
    instruction_read_data = 32'hfe10_8ee3; // BEQ x1, x1, -4
    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_001c,
                              "taken BEQ supports a negative offset");

    // x3 is -2048 signed, so BLT x3,x1 is taken from 0x1c to 0x24.
    @(negedge clk);
    instruction_read_data = 32'h0011_c463; // BLT x3, x1, +8
    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0024,
                              "signed BLT treats x3 as negative");

    // The same x3 value is large unsigned, so BLTU is not taken.
    @(negedge clk);
    instruction_read_data = 32'h0011_e463; // BLTU x3, x1, +8
    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0028,
                              "unsigned BLTU does not treat x3 as negative");

    // Build a data-memory base address in x5.
    @(negedge clk);
    instruction_read_data = 32'h1000_0293; // ADDI x5, x0, 0x100
    @(posedge clk);
    #1;
    check_register(5'd5, 32'h0000_0100, "ADDI initializes data base address");

    // The memory supplies the aligned word containing the requested address.
    @(negedge clk);
    instruction_read_data = 32'h0002_a303; // LW x6, 0(x5)
    data_read_data        = 32'hdead_beef;
    #1;
    check_data_interface(32'h0000_0100, 32'h0000_0000, 4'b0000,
                         1'b1, 1'b0, 1'b0, "aligned LW requests a read");
    @(posedge clk);
    #1;
    check_register(5'd6, 32'hdead_beef, "LW writes memory data to x6");

    @(negedge clk);
    instruction_read_data = 32'h0012_8383; // LB x7, 1(x5)
    data_read_data        = 32'h0000_8000;
    @(posedge clk);
    #1;
    check_register(5'd7, 32'hffff_ff80, "LB sign-extends the selected byte");

    @(negedge clk);
    instruction_read_data = 32'h0012_c403; // LBU x8, 1(x5)
    data_read_data        = 32'h0000_8000;
    @(posedge clk);
    #1;
    check_register(5'd8, 32'h0000_0080, "LBU zero-extends the selected byte");

    // Preserve x9 when a misaligned halfword load is attempted.
    @(negedge clk);
    instruction_read_data = 32'h0070_0493; // ADDI x9, x0, 7
    @(posedge clk);
    #1;
    check_register(5'd9, 32'd7, "ADDI initializes x9 before faulting load");

    @(negedge clk);
    instruction_read_data = 32'h0012_9483; // LH x9, 1(x5)
    data_read_data        = 32'h1234_5678;
    #1;
    check_data_interface(32'h0000_0101, 32'h0000_0500, 4'b0000,
                         1'b0, 1'b0, 1'b1,
                         "misaligned LH suppresses memory request");
    @(posedge clk);
    #1;
    check_register(5'd9, 32'd7, "misaligned LH does not write x9");

    // Store checks are performed before the rising edge, when outputs are valid.
    @(negedge clk);
    instruction_read_data = 32'h0062_8123; // SB x6, 2(x5)
    #1;
    check_data_interface(32'h0000_0102, 32'h00ef_0000, 4'b0100,
                         1'b0, 1'b1, 1'b0,
                         "SB selects the addressed byte lane");

    @(negedge clk);
    instruction_read_data = 32'h0062_a023; // SW x6, 0(x5)
    #1;
    check_data_interface(32'h0000_0100, 32'hdead_beef, 4'b1111,
                         1'b0, 1'b1, 1'b0, "aligned SW enables all byte lanes");

    @(negedge clk);
    instruction_read_data = 32'h0062_a123; // SW x6, 2(x5)
    #1;
    check_data_interface(32'h0000_0102, 32'hdead_beef, 4'b0000,
                         1'b0, 1'b0, 1'b1,
                         "misaligned SW suppresses memory write");

    // Retire the misaligned store. With no trap unit yet, PC advances by four.
    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_004c,
                              "misaligned store leaves sequential PC flow intact");

    // JAL at PC 0x4c jumps to 0x54 and writes its link address 0x50 to x10.
    @(negedge clk);
    instruction_read_data = 32'h0080_056f; // JAL x10, +8
    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0054,
                              "JAL selects PC-relative target");
    check_register(5'd10, 32'h0000_0050,
                   "JAL writes PC plus 4 to link register");

    // x5 contains 0x100. JALR adds one, then clears target bit zero.
    @(negedge clk);
    instruction_read_data = 32'h0012_85e7; // JALR x11, 1(x5)
    @(posedge clk);
    #1;
    check_instruction_address(32'h0000_0100,
                              "JALR clears bit zero of indirect target");
    check_register(5'd11, 32'h0000_0058,
                   "JALR writes PC plus 4 to link register");

    @(negedge clk);
    instruction_read_data = 32'h0330_000f; // FENCE rw, rw
    check_exceptions(1'b0, 1'b0, 1'b0, 1'b0,
                     "FENCE is a legal no-op");

    @(negedge clk);
    instruction_read_data = 32'h0000_0073; // ECALL
    check_exceptions(1'b0, 1'b0, 1'b1, 1'b0,
                     "ECALL requests an environment trap");

    @(negedge clk);
    instruction_read_data = 32'h0010_0073; // EBREAK
    check_exceptions(1'b0, 1'b0, 1'b0, 1'b1,
                     "EBREAK requests a breakpoint trap");

    @(negedge clk);
    instruction_read_data = 32'h0020_0073; // Unsupported SYSTEM encoding
    check_exceptions(1'b0, 1'b1, 1'b0, 1'b0,
                     "unsupported SYSTEM instruction is illegal");

    @(negedge clk);
    instruction_read_data = 32'h0020_006f; // JAL x0, +2
    check_exceptions(1'b1, 1'b0, 1'b0, 1'b0,
                     "misaligned jump target requests an exception");

    $display("Tests: %0d, Passed: %0d, Failed: %0d",
             test_count, test_count - error_count, error_count);

    if (error_count != 0) begin
      $fatal(1, "RV32I core testbench failed");
    end

    $finish;
  end

endmodule
