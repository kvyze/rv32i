`timescale 1ns/1ps

module tb_uart_tx;

    logic       clk = 0, rst = 0, start = 0;
    logic [7:0] data;
    logic       tx, busy;

    always #5 clk = ~clk;

    uart_tx dut (.*);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);

        rst = 1'b1;
        @(posedge clk);
        rst = 1'b0;

        data = 8'd135;
        start = 1'b1;
        #10;
        start = 1'b0;

        wait (busy == 1'b0);

        $display("PASS");
        $finish;
    end

endmodule
