module cpu (
    input  logic        clk,
    output logic [31:0] q
);

    logic        we, alu_inv,
                 ram_we, ram_load, ram_load_u, ram_misaligned,
                 lui, auipc, jal, jalr;
    logic [31:0] ins, imm, a, b, rdata2, ram_data, wd, count, offset;
    logic [3:0]  alu_op;
    logic [4:0]  rs1, rs2, rd, ram_slen;
    logic [2:0]  imm_type;

    assign b = (imm_type == 3'd0 || imm_type == 3'd2 || imm_type == 3'd3) ? rdata2 : imm;

    always_comb begin
        if      (lui)         wd = imm;
        else if (ram_load)    wd = ram_data;
        else if (auipc)       wd = count + imm;
        else if (jal || jalr) wd = count + 4;
        else                  wd = q;

        if ((imm_type == 3'd3 && q == 32'd1) || jal) offset = imm;
        else if (jalr) offset = ((a + imm) & 32'hfffffffe) - count;
        else offset = 32'd4;
    end

    pc u_pc (
        .clk(clk),
        .offset(offset),
        .ins(ins), .current_addr(count)
    );

    control cu (
        .ins(ins),
        .alu_op(alu_op),
        .rs1(rs1), .rs2(rs2), .rd(rd), .ram_slen(ram_slen),
        .imm_type(imm_type),
        .we(we), .alu_inv(alu_inv),
        .ram_we(ram_we), .ram_load(ram_load), .ram_load_u(ram_load_u),
        .lui(lui), .auipc(auipc), .jal(jal), .jalr(jalr)
    );

    immediate u_imm (
        .ins(ins),
        .imm_type(imm_type),
        .imm(imm)
    );

    alu u_alu (
        .opcode(alu_op),
        .a(a), .b(b),
        .inv(alu_inv),
        .q(q)
    );

    regfile rf (
        .clk(clk),
        .we((ram_load && !ram_misaligned) ? 1'b1 : we),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .wd(wd),
        .rdata1(a), .rdata2(rdata2)
    );

    ram u_ram (
        .clk(clk), .we(ram_we), .lu(ram_load_u),
        .slen(ram_slen),
        .addr(a + imm), .wd(rdata2),
        .rdata(ram_data),
        .misaligned(ram_misaligned)
    );

endmodule
