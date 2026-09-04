module next_pc_logic
  import rv32i_pkg::*;
(
  input  logic [31:0] pc_plus_4,
  input  logic [31:0] target_address,
  input  logic        branch_taken,
  input  jump_type_t  jump_type,

  output logic [31:0] next_pc,
  output logic        instruction_address_misaligned
);

  always_comb begin
    
    if (branch_taken) begin
      next_pc = target_address;
      instruction_address_misaligned = |target_address[1:0];
    end
    else if (jump_type == JUMP_DIRECT) begin
      next_pc = target_address;
      instruction_address_misaligned = |target_address[1:0];
    end
    else if (jump_type == JUMP_INDIRECT) begin
      next_pc = {target_address[31:1], 1'b0};
      instruction_address_misaligned = target_address[1];
    end
    else begin
      next_pc = pc_plus_4;
      instruction_address_misaligned = 1'b0;
    end



  end





endmodule
