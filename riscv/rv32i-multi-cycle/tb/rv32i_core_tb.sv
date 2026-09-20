module rv32i_core_tb;
    timeunit 1ns;
    timeprecision 1ps;
    logic clk = 0;
    logic reset;
    logic [31:0] instruction_read_data, instruction_address;
    logic unsupported_instruction;
    logic [31:0] program_words [0:7];
    logic [31:0] expected_regs [0:31];
    logic disturb_bus = 0;
    int unsigned test_count = 0;

    rv32i_core dut (.*);
    always #5 clk = ~clk;
    assign instruction_read_data = disturb_bus ? 32'hffff_ffff
                                 : program_words[instruction_address[4:2]];

    function automatic logic [31:0] add_inst(input logic [4:0] rd, rs1, rs2);
        return {7'b0000000, rs2, rs1, 3'b000, rd, 7'b0110011};
    endfunction

    task automatic check_regs;
        for (int r = 1; r < 32; r++) begin
            if (dut.u_register_file.registers[r] !== expected_regs[r])
                $fatal(1, "x%0d: expected=%h actual=%h", r,
                       expected_regs[r], dut.u_register_file.registers[r]);
        end
        test_count++;
    endtask

    task automatic execute(input int index, rd,
                           input logic [31:0] result,
                           input logic unsupported);
        // FETCH, DECODE, EXECUTE: no architectural writes yet.
        for (int phase = 0; phase < 3; phase++) begin
            @(posedge clk);
            #1;
            if (instruction_address !== 32'(index * 4))
                $fatal(1, "PC advanced before WRITEBACK");
            if (unsupported_instruction !== ((phase == 2) && unsupported))
                $fatal(1, "Incorrect unsupported-instruction indication");
            check_regs();
            @(negedge clk);
            // Once fetched, the external instruction bus may change.
            disturb_bus = 1;
        end
        if (rd != 0 && !unsupported)
            expected_regs[rd] = result;
        @(posedge clk);
        #1;
        check_regs();
        if (instruction_address !== 32'((index + 1) * 4)
            || unsupported_instruction !== 0)
            $fatal(1, "Incorrect PC or status after WRITEBACK");
        @(negedge clk);
        disturb_bus = 0;
    endtask

    initial begin
        reset = 1;
        // Test-only initialization: ADD alone cannot create nonzero constants.
        for (int r = 0; r < 32; r++) begin
            expected_regs[r] = 0;
            dut.u_register_file.registers[r] = 0;
        end
        expected_regs[1] = 10;
        expected_regs[2] = 20;
        expected_regs[6] = 32'hffff_ffff;
        expected_regs[7] = 1;
        for (int r = 1; r < 32; r++)
            dut.u_register_file.registers[r] = expected_regs[r];
        program_words[0] = add_inst(3, 1, 2);
        program_words[1] = add_inst(4, 3, 1); // dependent ADD
        program_words[2] = add_inst(0, 1, 2); // ignore x0 write
        program_words[3] = add_inst(5, 0, 4); // x0 still reads zero
        program_words[4] = add_inst(8, 6, 7); // wraparound
        program_words[5] = 32'h4020_84b3;    // SUB x9,x1,x2: unsupported
        program_words[6] = add_inst(10, 1, 2);
        program_words[7] = add_inst(0, 0, 0);
        @(posedge clk);
        #1;
        if (instruction_address !== 0 || unsupported_instruction !== 0)
            $fatal(1, "Reset failed");
        @(negedge clk);
        reset = 0;
        execute(0, 3, 30, 0);
        execute(1, 4, 40, 0);
        execute(2, 0, 0, 0);
        execute(3, 5, 40, 0);
        execute(4, 8, 0, 0);
        execute(5, 9, 0, 1);

        // Cancel a pending writeback using reset.
        repeat (3) @(posedge clk);
        @(negedge clk);
        reset = 1;
        @(posedge clk);
        #1;
        check_regs();
        if (instruction_address !== 0)
            $fatal(1, "Reset did not restart PC");
        @(negedge clk);
        reset = 0;
        execute(0, 3, 30, 0);
        $display("All %0d checks passed", test_count);
        $finish;
    end

    initial begin
        #3000;
        $fatal(1, "Simulation timed out");
    end
endmodule
