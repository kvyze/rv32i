module rom #(
    parameter SIZE = 256
)(
    input  logic [31:0] addr,
    output logic [31:0] data
);

    logic [31:0] memory [0:SIZE-1];

    assign data = (addr < SIZE) ? memory[addr] : 32'd0;

    initial begin
        $readmemh("asm/program.hex", memory);
    end

endmodule
