module regfile (
    input  logic        clk,            // clock
    input  logic        we,             // write enable
    input  logic [4:0]  rs1, rs2, rd,   // register source 1, 2 and register destination
    input  logic [31:0] wd,             // write data
    output logic [31:0] rdata1, rdata2  // read ports
);

    logic [31:0] regs [0:31];

    assign rdata1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
    assign rdata2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

    always_ff @(posedge clk) begin
        if (we && rd != 5'd0)
            regs[rd] <= wd;
    end

endmodule
