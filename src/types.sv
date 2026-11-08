package types;

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
        ALU_SLTU,
        ALU_EQ
    } alu_op_t;

    typedef enum logic [2:0] {
        ALU_OPERAND_A,
        ALU_OPERAND_B,
        ALU_OPERAND_IMM,
        ALU_OPERAND_PC,
        ALU_OPERAND_ZERO,
        ALU_OPERAND_FOUR,
        ALU_OPERAND_12,
        ALU_OPERAND_OUT
    } alu_operand_t;

    typedef enum logic [2:0] {
        IMM_R,
        IMM_I,
        IMM_S,
        IMM_B,
        IMM_U,
        IMM_J
    } imm_type_t;

    typedef enum logic [2:0] {
        INSTR_ARITHMETIC,
        INSTR_LOAD,
        INSTR_STORE,
        INSTR_BRANCH,
        INSTR_JAL,
        INSTR_AUIPC
    } instr_class_t;

    typedef enum logic [1:0] {
        RD_SRC_ALU_OUT,
        RD_SRC_ALU_Q,
        RD_SRC_MEM,
        RD_SRC_PC
    } rd_src_t;

    typedef enum logic [1:0] {
        MEM_BYTE,
        MEM_HALFWORD,
        MEM_WORD
    } mem_width_t;

    typedef enum logic [1:0] {
        REGS_IR, // Instruction Register
        REGS_IP, // Instruction Pointer
        REGS_ALU_OUT
    } regs_t;

    typedef enum logic {
        MEM_ADDR_SRC_ALU,
        MEM_ADDR_SRC_IP
    } mem_addr_src_t;

endpackage
