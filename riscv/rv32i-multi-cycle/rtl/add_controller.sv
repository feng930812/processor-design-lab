module add_controller (
    input  logic clk,
    input  logic reset,
    output logic ir_write_enable,
    output logic operand_write_enable,
    output logic alu_write_enable,
    output logic reg_write_enable,
    output logic pc_write_enable
);

    typedef enum logic [1:0] {
        FETCH,
        DECODE,
        EXECUTE,
        WRITEBACK
    } state_t;

    state_t state;
    state_t next_state;

    // 狀態暫存器：每個上升緣更新目前狀態。
    always_ff @(posedge clk) begin
        if (reset)
            state <= FETCH;
        else
            state <= next_state;
    end

    // 組合邏輯：根據目前狀態，決定下一個狀態。
    always_comb begin
        next_state = state;

        case (state)
            FETCH:     next_state = DECODE;
            DECODE:    next_state = EXECUTE;
            EXECUTE:   next_state = WRITEBACK;
            WRITEBACK: next_state = FETCH;
            default:   next_state = FETCH;
        endcase
    end

    always_comb begin
        ir_write_enable      = 1'b0;
        operand_write_enable = 1'b0;
        alu_write_enable     = 1'b0;
        reg_write_enable     = 1'b0;
        pc_write_enable      = 1'b0;

        if (!reset) begin
            case (state)
                FETCH: begin
                    ir_write_enable = 1'b1;
                end

                DECODE: begin
                    operand_write_enable = 1'b1;
                end

                EXECUTE: begin
                    alu_write_enable = 1'b1;
                end

                WRITEBACK: begin
                    reg_write_enable = 1'b1;
                    pc_write_enable = 1'b1;
                end

                default: begin end
            endcase
        end
    end

endmodule
