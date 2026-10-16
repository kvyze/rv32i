/*
immediate type opcodes:
R - 000 = 0 (imm = 0)
I - 001 = 1
S - 010 = 2
B - 011 = 3
U - 100 = 4
J - 101 = 5
shamt - 110 = 6
*/
module immediate (
    input  logic [31:0] ins,        // instruction
    input  logic [2:0]  imm_type,   // immediate type
    output logic [31:0] imm         // immediate
);

    always_comb begin
        case (imm_type)
            3'd0:    imm = 32'd0;
            3'd1:    imm = { {20{ins[31]}}, ins[31:20] };
            3'd2:    imm = { {20{ins[31]}}, ins[31:25], ins[11:7] };
            3'd3:    imm = { {19{ins[31]}}, ins[31], ins[7], ins[30:25], ins[11:8], 1'b0 };
            3'd4:    imm = { ins[31:12], {12{1'b0}} };
            3'd5:    imm = { {11{ins[31]}}, ins[31], ins[19:12], ins[20], ins[30:21], 1'b0 };
            3'd6:    imm = { {27{1'b0}}, ins[24:20] };
            default: imm = 32'd0;
        endcase
    end

endmodule
