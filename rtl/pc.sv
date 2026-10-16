module pc (
    input  logic        clk,
    input  logic [31:0] offset,
    output logic [31:0] ins, current_addr
);

    logic [31:0] count = 32'd0;

    rom #(.SIZE(5)) u_rom (
        .addr(count >> 2),
        .data(ins)
    );

    always_ff @(posedge clk) begin
        count <= count + offset;
    end

    assign current_addr = count;

endmodule
