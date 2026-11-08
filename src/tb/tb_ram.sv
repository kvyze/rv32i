`timescale 1ns/1ps

module tb_ram;

    import types::*;

    logic        clk = 0, we;
    logic [9:0]  addr;
    logic [31:0] wd;
    mem_width_t  mem_width;
    logic [31:0] rdata;

    always #5 clk = ~clk;

    ram dut (.*);

    task automatic check(input logic [9:0] exp_addr, input logic [31:0] exp_data);
        addr = exp_addr;

        @(posedge clk); #1;

        if (exp_data !== rdata)
            $error("FAIL: exp_data=%0d, rdata=%0d", exp_data, rdata);
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);

        we        = 1'b1;
        addr      = 10'd0;
        wd        = 32'd58;
        mem_width = MEM_BYTE;
        @(posedge clk);
        check(10'd0, 32'd58);

        addr      = 10'd5;
        wd        = 32'd573;
        mem_width = MEM_HALFWORD;
        @(posedge clk);
        check(10'd5, 32'd573);

        we        = 1'b0;
        mem_width = MEM_BYTE;
        check(10'd0, 32'd58);

        $finish;
    end

endmodule
