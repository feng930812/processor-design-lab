package rv32i_pkg;

  typedef enum logic [3:0] {
    ALU_ADD, 
    ALU_SUB, 
    ALU_AND, 
    ALU_OR, 
    ALU_XOR, 
    ALU_SLL, 
    ALU_SRL, 
    ALU_SRA, 
    ALU_SLT, 
    ALU_SLTU
  } alu_op_t;

  typedef enum logic [2:0] {
    IMM_NONE,
    IMM_I,
    IMM_S,
    IMM_B,
    IMM_U,
    IMM_J
  } imm_type_t;

  typedef enum logic [2:0] {
    BR_NONE,
    BR_EQ,
    BR_NE,
    BR_LT,
    BR_GE,
    BR_LTU,
    BR_GEU
  } branch_op_t;

  typedef enum logic [1:0] {
    ALU_A_RS1,
    ALU_A_PC,
    ALU_A_ZERO
  } alu_a_sel_t;

  typedef enum logic {
    ALU_B_RS2,
    ALU_B_IMM
  } alu_b_sel_t;

  typedef enum logic [1:0] {
    MEM_BYTE,
    MEM_HALF,
    MEM_WORD
  } mem_size_t;

  typedef enum logic [1:0] {
    WB_ALU,
    WB_MEMORY,
    WB_PC_PLUS_4
  } wb_sel_t;

  typedef enum logic [1:0] {
    JUMP_NONE,
    JUMP_DIRECT,
    JUMP_INDIRECT
  } jump_type_t;

  localparam logic [6:0] OPCODE_OP     = 7'b0110011;
  localparam logic [6:0] OPCODE_OP_IMM = 7'b0010011;
  localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
  localparam logic [6:0] OPCODE_AUIPC  = 7'b0010111;
  localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
  localparam logic [6:0] OPCODE_LOAD   = 7'b0000011;
  localparam logic [6:0] OPCODE_STORE  = 7'b0100011;
  localparam logic [6:0] OPCODE_JAL    = 7'b1101111;
  localparam logic [6:0] OPCODE_JALR   = 7'b1100111;
  localparam logic [6:0] OPCODE_MISC_MEM = 7'b0001111;
  localparam logic [6:0] OPCODE_SYSTEM   = 7'b1110011;

  localparam logic [9:0] R_FUNCT_ADD  = 10'b0000000_000;
  localparam logic [9:0] R_FUNCT_SUB  = 10'b0100000_000;
  localparam logic [9:0] R_FUNCT_SLL  = 10'b0000000_001;
  localparam logic [9:0] R_FUNCT_SLT  = 10'b0000000_010;
  localparam logic [9:0] R_FUNCT_SLTU = 10'b0000000_011;
  localparam logic [9:0] R_FUNCT_XOR  = 10'b0000000_100;
  localparam logic [9:0] R_FUNCT_SRL  = 10'b0000000_101;
  localparam logic [9:0] R_FUNCT_SRA  = 10'b0100000_101;
  localparam logic [9:0] R_FUNCT_OR   = 10'b0000000_110;
  localparam logic [9:0] R_FUNCT_AND  = 10'b0000000_111;

  localparam logic [2:0] I_FUNCT_ADDI  = 3'b000;
  localparam logic [2:0] I_FUNCT_SLLI  = 3'b001;
  localparam logic [2:0] I_FUNCT_SLTI  = 3'b010;
  localparam logic [2:0] I_FUNCT_SLTIU = 3'b011;
  localparam logic [2:0] I_FUNCT_XORI  = 3'b100;
  localparam logic [2:0] I_FUNCT_SRLI_SRAI = 3'b101;
  localparam logic [2:0] I_FUNCT_ORI   = 3'b110;
  localparam logic [2:0] I_FUNCT_ANDI  = 3'b111;

  localparam logic [6:0] SHIFT_LOGICAL    = 7'b0000000;
  localparam logic [6:0] SHIFT_ARITHMETIC = 7'b0100000;

  localparam logic [2:0] B_FUNCT_BEQ  = 3'b000;
  localparam logic [2:0] B_FUNCT_BNE  = 3'b001;
  localparam logic [2:0] B_FUNCT_BLT  = 3'b100;
  localparam logic [2:0] B_FUNCT_BGE  = 3'b101;
  localparam logic [2:0] B_FUNCT_BLTU = 3'b110;
  localparam logic [2:0] B_FUNCT_BGEU = 3'b111;

  localparam logic [2:0] L_FUNCT_LB  = 3'b000;
  localparam logic [2:0] L_FUNCT_LH  = 3'b001;
  localparam logic [2:0] L_FUNCT_LW  = 3'b010;
  localparam logic [2:0] L_FUNCT_LBU = 3'b100;
  localparam logic [2:0] L_FUNCT_LHU = 3'b101;

  localparam logic [2:0] S_FUNCT_SB = 3'b000;
  localparam logic [2:0] S_FUNCT_SH = 3'b001;
  localparam logic [2:0] S_FUNCT_SW = 3'b010;

  localparam logic [2:0] JALR_FUNCT = 3'b000;

endpackage
