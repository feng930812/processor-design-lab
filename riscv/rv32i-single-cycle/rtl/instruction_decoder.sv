module instruction_decoder(
  input  logic [31:0]           instruction,
  output rv32i_pkg::alu_a_sel_t alu_a_sel,
  output rv32i_pkg::alu_b_sel_t alu_b_sel,
  output rv32i_pkg::alu_op_t    alu_op,
  output rv32i_pkg::imm_type_t  imm_type,
  output rv32i_pkg::branch_op_t branch_op,
  output rv32i_pkg::mem_size_t  memory_size,
  output rv32i_pkg::wb_sel_t    writeback_sel,
  output rv32i_pkg::jump_type_t jump_type,
  output logic                  register_write_enable,
  output logic                  memory_read_enable,
  output logic                  memory_write_enable,
  output logic                  load_unsigned,
  output logic                  environment_call,
  output logic                  breakpoint,
  output logic                  illegal_instruction
);

  import rv32i_pkg::*;

  logic [6:0] opcode;
  logic [4:0] rd;
  logic [2:0] funct3;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [6:0] funct7;

  assign opcode = instruction[6:0];
  assign rd     = instruction[11:7];
  assign funct3 = instruction[14:12];
  assign rs1    = instruction[19:15];
  assign rs2    = instruction[24:20];
  assign funct7 = instruction[31:25];

  always_comb begin
    alu_a_sel             = ALU_A_RS1;
    alu_b_sel             = ALU_B_RS2;
    alu_op                = ALU_ADD;
    imm_type              = IMM_NONE;
    branch_op             = BR_NONE;
    memory_size           = MEM_WORD;
    writeback_sel          = WB_ALU;
    jump_type             = JUMP_NONE;
    register_write_enable = 1'b0;
    memory_read_enable    = 1'b0;
    memory_write_enable   = 1'b0;
    load_unsigned         = 1'b0;
    environment_call      = 1'b0;
    breakpoint            = 1'b0;
    illegal_instruction   = 1'b1;

    case (opcode)
      OPCODE_OP: begin
        case ({funct7, funct3})
          R_FUNCT_ADD: begin
            alu_op                = ALU_ADD;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          R_FUNCT_SUB: begin
            alu_op                = ALU_SUB;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          R_FUNCT_SLL: begin
            alu_op                = ALU_SLL;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          R_FUNCT_SLT: begin
            alu_op                = ALU_SLT;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          R_FUNCT_SLTU: begin
            alu_op                = ALU_SLTU;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          R_FUNCT_XOR: begin
            alu_op                = ALU_XOR;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          R_FUNCT_SRL: begin
            alu_op                = ALU_SRL;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          R_FUNCT_SRA: begin
            alu_op                = ALU_SRA;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          R_FUNCT_OR: begin
            alu_op                = ALU_OR;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          R_FUNCT_AND: begin
            alu_op                = ALU_AND;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          default: begin
          end
        endcase
      end

      OPCODE_OP_IMM: begin
        alu_b_sel = ALU_B_IMM;
        imm_type  = IMM_I;

        case (funct3)
          I_FUNCT_ADDI: begin
            alu_op                = ALU_ADD;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          I_FUNCT_SLLI: begin
            if (funct7 == SHIFT_LOGICAL) begin
              alu_op                = ALU_SLL;
              register_write_enable = 1'b1;
              illegal_instruction   = 1'b0;
            end
          end
          I_FUNCT_SLTI: begin
            alu_op                = ALU_SLT;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          I_FUNCT_SLTIU: begin
            alu_op                = ALU_SLTU;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          I_FUNCT_XORI: begin
            alu_op                = ALU_XOR;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          I_FUNCT_SRLI_SRAI: begin
            case (funct7)
              SHIFT_LOGICAL: begin
                alu_op                = ALU_SRL;
                register_write_enable = 1'b1;
                illegal_instruction   = 1'b0;
              end
              SHIFT_ARITHMETIC: begin
                alu_op                = ALU_SRA;
                register_write_enable = 1'b1;
                illegal_instruction   = 1'b0;
              end
              default: begin
              end
            endcase
          end
          I_FUNCT_ORI: begin
            alu_op                = ALU_OR;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          I_FUNCT_ANDI: begin
            alu_op                = ALU_AND;
            register_write_enable = 1'b1;
            illegal_instruction   = 1'b0;
          end
          default: begin
          end
        endcase
      end

      OPCODE_LUI: begin
        alu_a_sel             = ALU_A_ZERO;
        alu_b_sel             = ALU_B_IMM;
        alu_op                = ALU_ADD;
        imm_type              = IMM_U;
        register_write_enable = 1'b1;
        illegal_instruction   = 1'b0;
      end

      OPCODE_AUIPC: begin
        alu_a_sel             = ALU_A_PC;
        alu_b_sel             = ALU_B_IMM;
        alu_op                = ALU_ADD;
        imm_type              = IMM_U;
        register_write_enable = 1'b1;
        illegal_instruction   = 1'b0;
      end

      OPCODE_BRANCH: begin
        alu_a_sel = ALU_A_PC;
        alu_b_sel = ALU_B_IMM;
        alu_op    = ALU_ADD;
        imm_type = IMM_B;

        case (funct3)
          B_FUNCT_BEQ: begin
            branch_op           = BR_EQ;
            illegal_instruction = 1'b0;
          end
          B_FUNCT_BNE: begin
            branch_op           = BR_NE;
            illegal_instruction = 1'b0;
          end
          B_FUNCT_BLT: begin
            branch_op           = BR_LT;
            illegal_instruction = 1'b0;
          end
          B_FUNCT_BGE: begin
            branch_op           = BR_GE;
            illegal_instruction = 1'b0;
          end
          B_FUNCT_BLTU: begin
            branch_op           = BR_LTU;
            illegal_instruction = 1'b0;
          end
          B_FUNCT_BGEU: begin
            branch_op           = BR_GEU;
            illegal_instruction = 1'b0;
          end
          default: begin
          end
        endcase
      end

      OPCODE_LOAD: begin
        alu_a_sel    = ALU_A_RS1;
        alu_b_sel    = ALU_B_IMM;
        alu_op       = ALU_ADD;
        imm_type     = IMM_I;
        writeback_sel = WB_MEMORY;

        case (funct3)
          L_FUNCT_LB: begin
            memory_size           = MEM_BYTE;
            register_write_enable = 1'b1;
            memory_read_enable    = 1'b1;
            illegal_instruction   = 1'b0;
          end
          L_FUNCT_LH: begin
            memory_size           = MEM_HALF;
            register_write_enable = 1'b1;
            memory_read_enable    = 1'b1;
            illegal_instruction   = 1'b0;
          end
          L_FUNCT_LW: begin
            memory_size           = MEM_WORD;
            register_write_enable = 1'b1;
            memory_read_enable    = 1'b1;
            illegal_instruction   = 1'b0;
          end
          L_FUNCT_LBU: begin
            memory_size           = MEM_BYTE;
            register_write_enable = 1'b1;
            memory_read_enable    = 1'b1;
            load_unsigned         = 1'b1;
            illegal_instruction   = 1'b0;
          end
          L_FUNCT_LHU: begin
            memory_size           = MEM_HALF;
            register_write_enable = 1'b1;
            memory_read_enable    = 1'b1;
            load_unsigned         = 1'b1;
            illegal_instruction   = 1'b0;
          end
          default: begin
          end
        endcase
      end

      OPCODE_STORE: begin
        alu_a_sel = ALU_A_RS1;
        alu_b_sel = ALU_B_IMM;
        alu_op    = ALU_ADD;
        imm_type = IMM_S;

        case (funct3)
          S_FUNCT_SB: begin
            memory_size         = MEM_BYTE;
            memory_write_enable = 1'b1;
            illegal_instruction = 1'b0;
          end
          S_FUNCT_SH: begin
            memory_size         = MEM_HALF;
            memory_write_enable = 1'b1;
            illegal_instruction = 1'b0;
          end
          S_FUNCT_SW: begin
            memory_size         = MEM_WORD;
            memory_write_enable = 1'b1;
            illegal_instruction = 1'b0;
          end
          default: begin
          end
        endcase
      end

      OPCODE_JAL: begin
        alu_a_sel             = ALU_A_PC;
        alu_b_sel             = ALU_B_IMM;
        alu_op                = ALU_ADD;
        imm_type              = IMM_J;
        writeback_sel         = WB_PC_PLUS_4;
        jump_type             = JUMP_DIRECT;
        register_write_enable = 1'b1;
        illegal_instruction   = 1'b0;
      end

      OPCODE_JALR: begin
        alu_a_sel     = ALU_A_RS1;
        alu_b_sel     = ALU_B_IMM;
        alu_op        = ALU_ADD;
        imm_type      = IMM_I;
        writeback_sel = WB_PC_PLUS_4;

        if (funct3 == JALR_FUNCT) begin
          jump_type             = JUMP_INDIRECT;
          register_write_enable = 1'b1;
          illegal_instruction   = 1'b0;
        end
      end

      OPCODE_MISC_MEM: begin
        // A single-cycle in-order core has no observable memory reordering,
        // so the base FENCE operation completes as a legal no-op.
        if ((funct3 == 3'b000) && (instruction[31:28] == 4'b0000)) begin
          illegal_instruction = 1'b0;
        end
      end

      OPCODE_SYSTEM: begin
        case (instruction)
          32'h0000_0073: begin
            environment_call    = 1'b1;
            illegal_instruction = 1'b0;
          end
          32'h0010_0073: begin
            breakpoint          = 1'b1;
            illegal_instruction = 1'b0;
          end
          default: begin
          end
        endcase
      end

      default: begin
      end
    endcase
  end

endmodule
