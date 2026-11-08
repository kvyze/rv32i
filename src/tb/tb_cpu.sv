`timescale 1ns/1ps

module tb_cpu;

    logic clk = 0, rst = 1;
    logic tx, led1, busy, led2;

    always #5 clk = ~clk;

    cpu dut (.*);

    initial begin
        $dumpfile("cpu_wave.vcd");
        $dumpvars(0, dut);

        rst = 1'b0;
        #5;
        rst = 1'b1;

        #20000;

        $display("PASS");
        $finish;
    end

endmodule
