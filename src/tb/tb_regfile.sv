`timescale 1ns/1ps

module tb_regfile;

    logic        clk = 0, we;
    logic [4:0]  rs1, rs2, rd;
    logic [31:0] wd, rdata1, rdata2;

    always #5 clk = ~clk;

    regfile dut (.*);

    task automatic check(input logic [31:0] exp1, exp2);
        @(posedge clk); #1;

        if (exp1 !== rdata1 || exp2 !== rdata2)
            $error("FAIL: exp1=%0d, rdata1=%0d; exp2=%0d, rdata2=%0d", exp1, rdata1, exp2, rdata2);
        else
            $display("PASS");
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);

        we  = 1'b1;
        wd  = 32'd17;
        rd  = 5'd1;
        rs1 = 5'd0;
        rs2 = 5'd0;
        check(32'd0, 32'd0);

        we  = 1'b1;
        wd  = 32'd90;
        rd  = 5'd2;
        rs1 = 5'd0;
        rs2 = 5'd0;
        check(32'd0, 32'd0);

        we  = 1'b1;
        wd  = 32'd274;
        rd  = 5'd0;
        rs1 = 5'd1;
        rs2 = 5'd2;
        check(32'd17, 32'd90);

        we  = 1'b0;
        rd  = 5'd2;
        wd  = 32'd235;
        rs1 = 5'd0;
        check(32'd0, 32'd90);

        $finish;
    end

endmodule
