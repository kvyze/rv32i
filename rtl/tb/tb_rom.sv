`timescale 1ns/1ps

module tb_rom;

    logic        clk = 0;
    logic [31:0] addr, data;

    always #5 clk = ~clk;

    rom dut (.*);

    task automatic check(input logic [31:0] address, logic [31:0] expected);
        addr = address;
        @(posedge clk); #1;
        $display("time=%0t, address=%h; expected %h, got %h", $time, addr, expected, data);
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);

        check(32'd0, 32'h00a00093);
        check(32'd1, 32'h01400113);
        check(32'd2, 32'h002081b3);

        $display("PASS");
        $finish;
    end

endmodule
