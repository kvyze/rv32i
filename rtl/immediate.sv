module immediate import types::*; (
    input  logic [31:0] ins,        // instruction
    input  imm_type_t   imm_type,   // immediate type
    output logic [31:0] imm         // immediate
);

    always_comb begin
        case (imm_type)
            IMM_R:   imm = 32'd0;
            IMM_I:   imm = { {20{ins[31]}}, ins[31:20] };
            IMM_S:   imm = { {20{ins[31]}}, ins[31:25], ins[11:7] };
            IMM_B:   imm = { {19{ins[31]}}, ins[31], ins[7], ins[30:25], ins[11:8], 1'b0 };
            IMM_U:   imm = { ins[31:12], {12{1'b0}} };
            IMM_J:   imm = { {11{ins[31]}}, ins[31], ins[19:12], ins[20], ins[30:21], 1'b0 };
            default: imm = 32'd0;
        endcase
    end

endmodule
