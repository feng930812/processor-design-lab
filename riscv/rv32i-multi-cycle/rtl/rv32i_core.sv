// First milestone: ADD only, with combinational instruction-memory reads.
module rv32i_core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instruction_read_data,
    output logic [31:0] instruction_address,
    output logic        unsupported_instruction
);
    logic [31:0] instruction;
    logic [31:0] rs1_data, rs2_data, alu_out;
    logic ir_write_enable, operand_write_enable, alu_write_enable;
    logic reg_write_enable, pc_write_enable;
    logic is_add;

    // Decode the saved instruction, which remains stable through WRITEBACK.
    assign is_add = instruction[6:0] == 7'b0110011
                 && instruction[14:12] == 3'b000
                 && instruction[31:25] == 7'b0000000;
    // Unsupported instructions advance PC but never write a destination.
    assign unsupported_instruction = reg_write_enable && !is_add;

    program_counter u_pc (
        .clk          (clk),
        .reset        (reset),
        .write_enable (pc_write_enable),
        .next_pc      (instruction_address + 32'd4),
        .pc           (instruction_address)
    );

    instruction_register u_ir (
        .clk            (clk),
        .reset          (reset),
        .write_enable   (ir_write_enable),
        .instruction_in (instruction_read_data),
        .instruction    (instruction)
    );

    add_controller u_controller (
        .clk                  (clk),
        .reset                (reset),
        .ir_write_enable      (ir_write_enable),
        .operand_write_enable (operand_write_enable),
        .alu_write_enable     (alu_write_enable),
        .reg_write_enable     (reg_write_enable),
        .pc_write_enable      (pc_write_enable)
    );

    register_file u_register_file (
        .clk          (clk),
        .rs1_addr     (instruction[19:15]),
        .rs2_addr     (instruction[24:20]),
        .rd_addr      (instruction[11:7]),
        .rd_data      (alu_out),
        .write_enable (reg_write_enable && is_add),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data)
    );

    add_datapath u_datapath (
        .clk                  (clk),
        .reset                (reset),
        .operand_write_enable (operand_write_enable),
        .alu_write_enable     (alu_write_enable),
        .rs1_data             (rs1_data),
        .rs2_data             (rs2_data),
        .alu_out              (alu_out)
    );
endmodule
