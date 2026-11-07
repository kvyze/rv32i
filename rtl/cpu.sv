module cpu (
    input  logic clk, rst,
    output logic tx, led1, busy
);

    import types::*;

    localparam logic [31:0] UART_TX_ADDR = 32'h8000;

    logic [31:0]  instr, ir, ip;

    imm_type_t     imm_type;
    alu_op_t       alu_op_dec, alu_op_cu, alu_op;
    logic          alu_inv;
    alu_operand_t  alu_operand1_dec, alu_operand2_dec,
                   alu_operand1_cu, alu_operand2_cu;
    rd_src_t       rd_src_dec, rd_src_cu;
    instr_class_t  instr_class;
    logic          reg_write;
    mem_width_t    mem_width;
    logic          mem_sign, illegal, dec_valid;

    regs_t         inreg;
    logic          inregs_we, reg_we;
    logic [31:0]   inregs_wd, reg_wd, rdata1, rdata2;
    logic [4:0]    rs1, rs2, rd;

    logic [31:0]   alu_a, alu_b, alu_q, alu_out;
    logic [31:0]   imm;

    logic          ram_we, uart_tx_start, uart_tx_busy;
    logic [31:0]   ram_rdata, mem_addr;
    mem_addr_src_t mem_addr_src;

    always_comb begin
        uart_tx_start = (instr_class == INSTR_STORE && !uart_tx_busy && alu_out == UART_TX_ADDR);
        led1          = rst;
        busy          = uart_tx_busy;
        alu_op        = alu_op_t'(dec_valid ? alu_op_dec : alu_op_cu);

        case (inreg)
            REGS_IR:      inregs_wd = ram_rdata;
            REGS_IP:      inregs_wd = alu_q;
            REGS_ALU_OUT: inregs_wd = alu_q;
            default:      inregs_wd = 32'd0;
        endcase

        case (mem_addr_src)
            MEM_ADDR_SRC_ALU: mem_addr = alu_out;
            MEM_ADDR_SRC_IP:  mem_addr = ip;
        endcase

        case (dec_valid ? alu_operand1_dec : alu_operand1_cu)
            ALU_OPERAND_A:    alu_a = rdata1;
            ALU_OPERAND_PC:   alu_a = ip;
            ALU_OPERAND_ZERO: alu_a = 32'd0;
            ALU_OPERAND_IMM:  alu_a = imm;
            default:          alu_a = 32'd0;
        endcase

        case (dec_valid ? alu_operand2_dec : alu_operand2_cu)
            ALU_OPERAND_B:    alu_b = rdata2;
            ALU_OPERAND_IMM:  alu_b = imm;
            ALU_OPERAND_FOUR: alu_b = 32'd4;
            ALU_OPERAND_12:   alu_b = 32'd12;
            ALU_OPERAND_OUT:  alu_b = alu_out;
            default:          alu_b = 32'd0;
        endcase

        case (dec_valid ? rd_src_dec : rd_src_cu)
            RD_SRC_ALU_OUT: reg_wd = alu_out;
            RD_SRC_ALU_Q:   reg_wd = alu_q;
            RD_SRC_MEM:     reg_wd = ram_rdata;
            RD_SRC_PC:      reg_wd = ip;
        endcase
    end

    // rom u_rom (.clk(clk), .addr(rom_addr >> 2), .instr(instr));
    memory u_memory (.*, .we(ram_we), .addr(mem_addr), .wd(rdata2), .rdata(ram_rdata));
    regfile u_regs (.*, .we(reg_we), .wd(reg_wd));
    uart_tx u_uart_tx (.*, .start(uart_tx_start), .data(rdata2), .busy(uart_tx_busy));

    decoder u_decoder (
        .*, .instr(ir),
        .alu_operand1(alu_operand1_dec), .alu_operand2(alu_operand2_dec),
        .rd_src(rd_src_dec), .alu_op(alu_op_dec)
    );
    
    control_unit cu (
        .*, .alu_operand1(alu_operand1_cu), .alu_operand2(alu_operand2_cu),
        .rd_src(rd_src_cu), .alu_op(alu_op_cu)
    );

    internal_regs inregs (
        .clk(clk), .we(inregs_we), .rst(rst),
        .rd(inreg), .wd(inregs_wd),
        .ir(ir), .ip(ip), .aluq(alu_out)
    );

    alu u_alu (
        .alu_op(alu_op),
        .a(alu_a), .b(alu_b),
        .inv(dec_valid ? alu_inv : 1'b0),
        .q(alu_q)
    );

    immediate u_imm (
        .ins(ir),
        .imm_type(imm_type),
        .imm(imm)
    );

endmodule
