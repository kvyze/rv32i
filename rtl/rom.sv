module rom #(
    parameter int SIZE = 4096,
    localparam int ADDR_WIDTH = $clog2(SIZE)
)(
    input  logic                  clk,
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [31:0]           instr
);

    logic [31:0] memory [0:SIZE-1];

    initial begin
        $readmemh("asm/program.hex", memory);
    end

    always_ff @(posedge clk) begin
        instr <= memory[addr];
    end

endmodule
