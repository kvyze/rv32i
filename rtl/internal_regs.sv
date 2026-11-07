module internal_regs import types::*; #(
    parameter int SIZE = 3
)(
    input  logic        clk, we, rst,
    input  regs_t       rd,
    input  logic [31:0] wd,
    output logic [31:0] ir, ip, aluq
);

    logic [31:0] regs [0:SIZE-1];

    initial begin
        for (int i = 0; i < SIZE; i++)
            regs[i] = 32'd0;
    end

    assign ir   = regs[REGS_IR];
    assign ip   = regs[REGS_IP];
    assign aluq = regs[REGS_ALU_OUT];

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) regs[REGS_IP] <= 32'h4000;
        else if (we) regs[rd] <= wd;
    end

endmodule
