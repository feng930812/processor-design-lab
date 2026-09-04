module load_store_unit
  import rv32i_pkg::*;
(
  input  logic [31:0] address,
  input  logic [31:0] store_data,
  input  logic [31:0] memory_read_data,
  input  mem_size_t   memory_size,
  input  logic        load_unsigned,

  output logic [31:0] load_data,
  output logic [31:0] memory_write_data,
  output logic [3:0]  memory_byte_enable,
  output logic        misaligned_access
);

  logic [31:0] shifted_read_data;

  // 1. Load
  always_comb begin
    
    shifted_read_data = memory_read_data >> (address[1:0] * 8);

    case(memory_size)
      MEM_BYTE: begin
        if (load_unsigned)
          load_data = {24'b0, shifted_read_data[7:0]};
        else
          load_data = {{24{shifted_read_data[7]}},
                       shifted_read_data[7:0]};
      end

      MEM_HALF: begin
        if (load_unsigned)
          load_data = {16'b0, shifted_read_data[15:0]};
        else
          load_data = {{16{shifted_read_data[15]}},
                       shifted_read_data[15:0]};
      end

      MEM_WORD: begin
        load_data = shifted_read_data;
      end

      default: begin
        load_data = 32'b0;
      end
    endcase
  end

  // 2. Store
  always_comb begin
    memory_write_data = 32'b0;
    memory_byte_enable = 4'b0000;
    
    case (memory_size)
      MEM_BYTE: begin
        memory_write_data = ((store_data & 32'hff) << (address[1:0] * 8));
        memory_byte_enable = 4'b0001 << address[1:0];
      end

      MEM_HALF: begin
        memory_write_data = ((store_data & 32'hffff) << (address[1:0] * 8));
        memory_byte_enable = 4'b0011 << address[1:0];
      end

      MEM_WORD: begin
        memory_write_data = store_data;
        memory_byte_enable = 4'b1111;
      end

      default: begin
        memory_write_data  = 32'b0;
        memory_byte_enable = 4'b0000;
      end
    endcase
    

  end

  // 3. Alignment
  always_comb begin

    misaligned_access = 1'b1;

    case (memory_size)
      MEM_BYTE: misaligned_access = 1'b0;

      MEM_HALF: misaligned_access = address[0];

      MEM_WORD: misaligned_access = |address[1:0];
    endcase
  end


  


endmodule
