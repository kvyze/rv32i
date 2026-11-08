`timescale 1ns/1ps

module tb_decoder;

    import types::*;

    logic [6:0]   opcode = 7'b0010011;
    logic [2:0]   funct3 = 3'b000;
    logic         funct7_5 = 1'b0;
    imm_type_t    imm_type;
    alu_op_t      alu_op;
    logic         alu_inv;
    alu_operand_t alu_operand1;
    alu_operand_t alu_operand2;
    rd_src_t      rd_src;
    instr_class_t instr_class;
    logic         reg_write;
    mem_width_t   mem_width;
    logic         mem_sign;
    logic         illegal;

    localparam int TESTS_AMOUNT = 2;

    // [34:28] - opcode, [27:25] - funct3, [24] - funct7[5], [23:21] - imm_type, [20:17] - alu_op, [16] - alu_inv,
    // [15:13] - alu_operand1, [12:10] - alu_operand2, [9:8] - rd_src, [7:5] - instr_class, [4] - reg_write,
    // [3:2] - mem_width, [1] - mem_sign, [0] - illegal
    logic [34:0] tests [0:TESTS_AMOUNT-1] = '{
        35'b0010011_000_0_001_0000_0_000_010_00_000_1_10_0_0, // addi
        35'b0110011_000_0_000_0000_0_000_001_00_000_1_10_0_0  // add
    };
    logic [34:0] test;

    decoder dut (.*);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);

        for (int i = 0; i < TESTS_AMOUNT; i++) begin
            test     = tests[i];
            opcode   = test[34:28];
            funct3   = test[27:25];
            funct7_5 = test[24];

            #1;

            if (imm_type === test[23:21] && alu_op === test[20:17] && alu_inv === test[16] && alu_operand1 == test[15:13] &&
                alu_operand2 === test[12:10] && rd_src === test[9:8] && instr_class === test[7:5] && reg_write === test[4] &&
                mem_width === test[3:2] && mem_sign === test[1] && illegal === test[0])
                $display("PASS");
            else
                $error("FAIL: test_index=%0d", i);
        end

        $finish;
    end

endmodule
