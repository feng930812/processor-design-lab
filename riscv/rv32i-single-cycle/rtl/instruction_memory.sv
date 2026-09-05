module instruction_memory #(
  parameter integer WORD_COUNT = 256,
  parameter         INIT_FILE  = ""
) (
  input  logic [31:0] address,
  output logic [31:0] read_data
);

  localparam logic [31:0] NOP = 32'h0000_0013;

  logic [31:0] memory [0:WORD_COUNT-1];
  logic [29:0] word_index;
  integer index;

  assign word_index = address[31:2];

  initial begin
    for (index = 0; index < WORD_COUNT; index = index + 1) begin
      memory[index] = NOP;
    end

    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, memory);
    end
  end

  always_comb begin
    if ((address[1:0] == 2'b00) && (word_index < WORD_COUNT)) begin
      read_data = memory[word_index];
    end else begin
      read_data = NOP;
    end
  end

endmodule
