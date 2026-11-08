module control_unit import types::*; (
    input  logic          clk, rst, illegal, reg_write, uart_tx_busy,
    input  instr_class_t  instr_class,
    input  logic [31:0]   alu_out,
    output logic          inregs_we, dec_valid, reg_we, ram_we, fetch,
    output regs_t         inreg,
    output alu_operand_t  alu_operand1, alu_operand2,
    output rd_src_t       rd_src,
    output alu_op_t       alu_op,
    output mem_addr_src_t mem_addr_src
);

    typedef enum logic [2:0] {
        STATE_FETCH,
        STATE_FETCH2,
        STATE_CALC_PC,
        STATE_EXECUTE,
        STATE_MEM_LOAD,
        STATE_WRITEBACK,
        STATE_WAIT_UART
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge clk or negedge rst) begin
        current_state <= state_t'(!rst ? STATE_FETCH : next_state);
    end

    always_comb begin
        next_state = current_state;
        {inregs_we, dec_valid, reg_we, ram_we, fetch} = '0;
        inreg = REGS_ALU_OUT;
        alu_operand1 = ALU_OPERAND_ZERO;
        alu_operand2 = ALU_OPERAND_FOUR;
        rd_src = RD_SRC_ALU_OUT;
        alu_op = ALU_ADD;
        mem_addr_src = MEM_ADDR_SRC_ALU;

        case (current_state)
            STATE_FETCH: begin
                mem_addr_src = MEM_ADDR_SRC_IP;
                fetch        = 1'b1;
                next_state   = STATE_FETCH2;
            end

            STATE_FETCH2: begin
                mem_addr_src = MEM_ADDR_SRC_IP;
                inregs_we    = 1'b1;
                fetch        = 1'b1;
                inreg        = REGS_IR;
                next_state   = STATE_CALC_PC;
            end

            STATE_CALC_PC: begin
                alu_operand1 = ALU_OPERAND_PC;
                alu_operand2 = ALU_OPERAND_FOUR;

                if (instr_class == INSTR_JAL) begin
                    reg_we    = 1'b1;
                    rd_src    = RD_SRC_ALU_Q;
                end

                inregs_we = (instr_class != INSTR_JAL);
                
                if (instr_class == INSTR_BRANCH || instr_class == INSTR_AUIPC) begin
                    dec_valid  = 1'b1;
                    next_state = STATE_WRITEBACK;
                end else begin
                    inreg      = REGS_IP;
                    next_state = STATE_EXECUTE;
                end
            end

            STATE_EXECUTE: begin
                inregs_we  = 1'b1;
                dec_valid  = 1'b1;
                
                if (instr_class == INSTR_JAL) begin
                    inreg      = REGS_IP;
                    next_state = STATE_FETCH;
                end else begin
                    inreg      = REGS_ALU_OUT;
                    next_state = state_t'((instr_class == INSTR_LOAD) ? STATE_MEM_LOAD : STATE_WRITEBACK);
                end
            end

            STATE_MEM_LOAD: next_state = STATE_WRITEBACK;

            STATE_WRITEBACK: begin
                if (instr_class == INSTR_BRANCH) begin
                    alu_operand1 = ALU_OPERAND_PC;
                    alu_operand2 = alu_operand_t'((alu_out == 32'd1) ? ALU_OPERAND_IMM : ALU_OPERAND_FOUR);
                    inregs_we    = 1'b1;
                    inreg        = REGS_IP;
                end else if (instr_class == INSTR_AUIPC) begin
                    alu_operand1 = ALU_OPERAND_PC;
                    alu_operand2 = ALU_OPERAND_FOUR;
                    inregs_we    = 1'b1;
                    inreg        = REGS_IP;
                end else if (instr_class == INSTR_LOAD)
                    rd_src = RD_SRC_MEM;

                ram_we     = (instr_class == INSTR_STORE);
                reg_we     = 1'b1 & reg_write;
                next_state = state_t'(uart_tx_busy ? STATE_WAIT_UART : STATE_FETCH);
            end

            STATE_WAIT_UART: begin
                if (!uart_tx_busy) next_state = STATE_FETCH;
                else next_state = STATE_WAIT_UART;
            end
        endcase
    end

endmodule
