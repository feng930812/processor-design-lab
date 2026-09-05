module data_memory #(
  parameter integer BYTE_COUNT = 1024
) (
  input  logic        clk,
  input  logic [31:0] address,
  input  logic [31:0] write_data,
  input  logic [3:0]  byte_enable,
  input  logic        read_enable,
  input  logic        write_enable,
  output logic [31:0] read_data
);

  logic [7:0]  memory [0:BYTE_COUNT-1];
  logic [31:0] aligned_address;

  assign aligned_address = {address[31:2], 2'b00};

  always_comb begin
    read_data = 32'b0;

    if (read_enable && ((aligned_address + 32'd3) < BYTE_COUNT)) begin
      read_data = {
        memory[aligned_address + 32'd3],
        memory[aligned_address + 32'd2],
        memory[aligned_address + 32'd1],
        memory[aligned_address]
      };
    end
  end

  always_ff @(posedge clk) begin
    if (write_enable && ((aligned_address + 32'd3) < BYTE_COUNT)) begin
      if (byte_enable[0]) memory[aligned_address]         <= write_data[7:0];
      if (byte_enable[1]) memory[aligned_address + 32'd1] <= write_data[15:8];
      if (byte_enable[2]) memory[aligned_address + 32'd2] <= write_data[23:16];
      if (byte_enable[3]) memory[aligned_address + 32'd3] <= write_data[31:24];
    end
  end

endmodule
