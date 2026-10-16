/*
0000 = 0 - add
0001 = 1 - sub
0010 = 2 - and
0011 = 3 - or
0100 = 4 - xor
0101 = 5 - sll
0110 = 6 - srl
0111 = 7 - sra
1000 = 8 - slt
1001 = 9 - sltu
1010 = 10 - beq
*/
module alu (
    input  logic [3:0]  opcode,
    input  logic [31:0] a, b,
    input  logic        inv,
    output logic [31:0] q
);

    always_comb begin
        case (opcode)
            4'd0:    q = a + b;
            4'd1:    q = a - b;
            4'd2:    q = a & b;
            4'd3:    q = a | b;
            4'd4:    q = a ^ b;
            4'd5:    q = a << b[4:0];
            4'd6:    q = a >> b[4:0];
            4'd7:    q = $signed(a) >>> b[4:0];
            4'd8:    q = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            4'd9:    q = ($unsigned(a) < $unsigned(b)) ? 32'd1 : 32'd0;
            4'd10:   q = (a == b) ? 32'd1 : 32'd0;
            default: q = 32'd0;
        endcase

        if (inv) q = !q;
    end

endmodule
