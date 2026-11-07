module decoder import types::*; (
    input  logic [31:0]  instr,
    output logic [4:0]   rs1, rs2, rd,
    output imm_type_t    imm_type,
    output alu_op_t      alu_op,
    output logic         alu_inv,
    output alu_operand_t alu_operand1,
    output alu_operand_t alu_operand2,
    output rd_src_t      rd_src,
    output instr_class_t instr_class,
    output logic         reg_write,
    output mem_width_t   mem_width,
    output logic         mem_sign,     // 0 - unsigned, 1 - signed
    output logic         illegal
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic       funct7_5;

    always_comb begin
        opcode   = instr[6:0];
        funct3   = instr[14:12];
        funct7_5 = instr[30];
        rs1      = instr[19:15];
        rs2      = instr[24:20];
        rd       = instr[11:7];

        imm_type     = IMM_R;
        alu_op       = ALU_ADD;
        alu_inv      = 1'b0;
        alu_operand1 = ALU_OPERAND_ZERO;
        alu_operand2 = ALU_OPERAND_IMM;
        rd_src       = RD_SRC_ALU_OUT;
        instr_class  = INSTR_ARITHMETIC;
        reg_write    = 1'b0;
        mem_width    = MEM_WORD;
        mem_sign     = 1'b0;
        illegal      = 1'b0;

        case (opcode)
            7'b0110111: begin                                       // lui
                imm_type     = IMM_U;
                reg_write    = 1'b1;
            end

            7'b0010111: begin                                       // auipc
                imm_type     = IMM_U;
                alu_operand1 = ALU_OPERAND_PC;
                alu_operand2 = ALU_OPERAND_IMM;
                instr_class  = INSTR_AUIPC;
                reg_write    = 1'b1;
            end

            7'b1101111: begin                                       // jal
                imm_type     = IMM_J;
                alu_operand1 = ALU_OPERAND_PC;
                instr_class  = INSTR_JAL;
            end

            7'b1100111: begin                                       // jalr
                imm_type     = IMM_I;
                alu_operand1 = ALU_OPERAND_A;
                instr_class  = INSTR_JAL;
            end

            7'b1100011: begin
                alu_operand1 = ALU_OPERAND_A;
                alu_operand2 = ALU_OPERAND_B;
                imm_type     = IMM_B;
                instr_class  = INSTR_BRANCH;

                if (funct3 == 3'b000)                               // beq
                    alu_op = ALU_EQ;
                else if (funct3 == 3'b001) begin                    // bne
                    alu_op  = ALU_EQ;
                    alu_inv = 1'b1;
                end else if (funct3 == 3'b100)                      // blt
                    alu_op = ALU_SLT;
                else if (funct3 == 3'b101) begin                    // bge
                    alu_op  = ALU_SLT;
                    alu_inv = 1'b1;
                end else if (funct3 == 3'b110)                      // bltu
                    alu_op = ALU_SLTU;
                else if (funct3 == 3'b111) begin                    // bgeu
                    alu_op  = ALU_SLTU;
                    alu_inv = 1'b1;
                end
            end

            7'b0000011: begin
                imm_type     = IMM_I;
                alu_operand1 = ALU_OPERAND_A;
                instr_class  = INSTR_LOAD;
                reg_write    = 1'b1;

                if (funct3 == 3'b000) begin                         // lb
                    mem_width = MEM_BYTE;
                    mem_sign  = 1'b1;
                end else if (funct3 == 3'b001) begin                // lh
                    mem_width = MEM_HALFWORD;
                    mem_sign  = 1'b1;
                end else if (funct3 == 3'b010) begin                // lw
                    mem_width = MEM_WORD;
                    mem_sign  = 1'b1;
                end else if (funct3 == 3'b100) begin                // lbu
                    mem_width = MEM_BYTE;
                    mem_sign  = 1'b0;
                end else if (funct3 == 3'b101) begin                // lhu
                    mem_width = MEM_HALFWORD;
                    mem_sign  = 1'b0;
                end
            end

            7'b0100011: begin
                imm_type     = IMM_S;
                alu_operand1 = ALU_OPERAND_A;
                instr_class  = INSTR_STORE;

                if (funct3 == 3'b000)                               // sb
                    mem_width = MEM_BYTE;
                else if (funct3 == 3'b001)                          // sh
                    mem_width = MEM_HALFWORD;
                else if (funct3 == 3'b010)                          // sw
                    mem_width = MEM_WORD;
            end

            7'b0010011: begin
                alu_operand1 = ALU_OPERAND_A;
                imm_type     = IMM_I;
                reg_write    = 1'b1;

                if (funct3 == 3'b000)                               // addi
                    alu_op = ALU_ADD;
                else if (funct3 == 3'b010)                          // slti
                    alu_op = ALU_SLT;
                else if (funct3 == 3'b011)                          // sltiu
                    alu_op = ALU_SLTU;
                else if (funct3 == 3'b100)                          // xori
                    alu_op = ALU_XOR;
                else if (funct3 == 3'b110)                          // ori
                    alu_op = ALU_OR;
                else if (funct3 == 3'b111)                          // andi
                    alu_op = ALU_AND;
                else if (funct3 == 3'b001 && funct7_5 == 1'b0)      // slli
                    alu_op = ALU_SLL;
                else if (funct3 == 3'b101 && funct7_5 == 1'b0)      // srli
                    alu_op = ALU_SRL;
                else if (funct3 == 3'b101 && funct7_5 == 1'b1)      // srai
                    alu_op = ALU_SRA;
            end

            7'b0110011: begin
                alu_operand1 = ALU_OPERAND_A;
                alu_operand2 = ALU_OPERAND_B;
                reg_write    = 1'b1;

                if (funct3 == 3'b000 && funct7_5 == 1'b0)           // add
                    alu_op = ALU_ADD;
                else if (funct3 == 3'b000 && funct7_5 == 1'b1)      // sub
                    alu_op = ALU_SUB;
                else if (funct3 == 3'b001 && funct7_5 == 1'b0)      // sll
                    alu_op = ALU_SLL;
                else if (funct3 == 3'b010 && funct7_5 == 1'b0)      // slt
                    alu_op = ALU_SLT;
                else if (funct3 == 3'b011 && funct7_5 == 1'b0)      // sltu
                    alu_op = ALU_SLTU;
                else if (funct3 == 3'b100 && funct7_5 == 1'b0)      // xor
                    alu_op = ALU_XOR;
                else if (funct3 == 3'b101 && funct7_5 == 1'b0)      // srl
                    alu_op = ALU_SRL;
                else if (funct3 == 3'b101 && funct7_5 == 1'b1)      // sra
                    alu_op = ALU_SRA;
                else if (funct3 == 3'b110 && funct7_5 == 1'b0)      // or
                    alu_op = ALU_OR;
                else if (funct3 == 3'b111 && funct7_5 == 1'b0)      // and
                    alu_op = ALU_AND;
            end

            default: illegal = 1'b1;
        endcase
    end

endmodule
