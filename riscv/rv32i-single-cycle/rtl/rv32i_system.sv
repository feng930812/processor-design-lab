module rv32i_system #(
  parameter integer INSTRUCTION_WORDS = 256,
  parameter integer DATA_BYTES        = 1024,
  parameter         PROGRAM_FILE      = ""
) (
  input  logic clk,
  input  logic reset,
  output logic instruction_address_misaligned,
  output logic data_address_misaligned,
  output logic illegal_instruction,
  output logic environment_call,
  output logic breakpoint
);

  logic [31:0] instruction_address;
  logic [31:0] instruction_read_data;
  logic [31:0] data_address;
  logic [31:0] data_read_data;
  logic [31:0] data_write_data;
  logic [3:0]  data_byte_enable;
  logic        data_read_enable;
  logic        data_write_enable;

  instruction_memory #(
    .WORD_COUNT (INSTRUCTION_WORDS),
    .INIT_FILE  (PROGRAM_FILE)
  ) u_instruction_memory (
    .address   (instruction_address),
    .read_data (instruction_read_data)
  );

  rv32i_core u_core (
    .clk                     (clk),
    .reset                   (reset),
    .instruction_read_data   (instruction_read_data),
    .data_read_data          (data_read_data),
    .instruction_address     (instruction_address),
    .data_address            (data_address),
    .data_write_data         (data_write_data),
    .data_byte_enable        (data_byte_enable),
    .data_read_enable        (data_read_enable),
    .data_write_enable       (data_write_enable),
    .data_address_misaligned (data_address_misaligned),
    .instruction_address_misaligned (instruction_address_misaligned),
    .illegal_instruction     (illegal_instruction),
    .environment_call        (environment_call),
    .breakpoint              (breakpoint)
  );

  data_memory #(
    .BYTE_COUNT (DATA_BYTES)
  ) u_data_memory (
    .clk          (clk),
    .address      (data_address),
    .write_data   (data_write_data),
    .byte_enable  (data_byte_enable),
    .read_enable  (data_read_enable),
    .write_enable (data_write_enable),
    .read_data    (data_read_data)
  );

endmodule
