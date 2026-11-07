module alu import types::*; (
    input  alu_op_t     alu_op,
    input  logic [31:0] a, b,
    input  logic        inv,
    output logic [31:0] q
);

    always_comb begin
        case (alu_op)
            ALU_ADD:  q = a + b;
            ALU_SUB:  q = a - b;
            ALU_AND:  q = a & b;
            ALU_OR:   q = a | b;
            ALU_XOR:  q = a ^ b;
            ALU_SLL:  q = a << b[4:0];
            ALU_SRL:  q = a >> b[4:0];
            ALU_SRA:  q = $signed(a) >>> b[4:0];
            ALU_SLT:  q = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_SLTU: q = ($unsigned(a) < $unsigned(b)) ? 32'd1 : 32'd0;
            ALU_EQ:   q = (a == b) ? 32'd1 : 32'd0;
            default:  q = 32'd0;
        endcase

        if (inv) q = !q;
    end

endmodule
