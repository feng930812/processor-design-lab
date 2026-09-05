module rv32i_system_tb;

  timeunit 1ns;
  timeprecision 1ps;

  localparam integer MAX_CYCLES = 200;

  logic clk;
  logic reset;
  logic instruction_address_misaligned;
  logic data_address_misaligned;
  logic illegal_instruction;
  logic environment_call;
  logic breakpoint;
  logic [31:0] signature;
  int unsigned cycle_count;

  rv32i_system #(
    .INSTRUCTION_WORDS (256),
    .DATA_BYTES        (1024),
    .PROGRAM_FILE      ("programs/rv32i_integration.hex")
  ) dut (
    .clk                            (clk),
    .reset                          (reset),
    .instruction_address_misaligned (instruction_address_misaligned),
    .data_address_misaligned        (data_address_misaligned),
    .illegal_instruction            (illegal_instruction),
    .environment_call               (environment_call),
    .breakpoint                     (breakpoint)
  );

  always #5 clk = ~clk;

  always_comb begin
    signature = {
      dut.u_data_memory.memory[32'h103],
      dut.u_data_memory.memory[32'h102],
      dut.u_data_memory.memory[32'h101],
      dut.u_data_memory.memory[32'h100]
    };
  end

  initial begin
    clk         = 1'b0;
    reset       = 1'b1;
    cycle_count = 0;

    for (int i = 0; i < 1024; i++) dut.u_data_memory.memory[i] = 8'b0;

    repeat (2) @(posedge clk);
    @(negedge clk);
    reset = 1'b0;

    while ((signature !== 32'h0000_0001) &&
           (signature !== 32'hffff_ffff) &&
           (cycle_count < MAX_CYCLES)) begin
      @(negedge clk);
      cycle_count++;

      if (instruction_address_misaligned || data_address_misaligned ||
          illegal_instruction || environment_call || breakpoint) begin
        $fatal(1, "Unexpected exception at PC=%h", dut.instruction_address);
      end
    end

    if (signature === 32'h0000_0001) begin
      $display("PASS: RV32I integration program completed in %0d cycles",
               cycle_count);
    end else if (signature === 32'hffff_ffff) begin
      $fatal(1, "RV32I integration program reached fail handler at PC=%h",
             dut.instruction_address);
    end else begin
      $fatal(1, "RV32I integration program timed out at PC=%h signature=%h",
             dut.instruction_address, signature);
    end

    $finish;
  end

endmodule
