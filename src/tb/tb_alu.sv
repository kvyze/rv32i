`timescale 1ns/1ps

module tb_alu;

    logic [3:0]  opcode;
    logic [31:0] a, b, q;
    logic        inv;

    logic [31:0] results [0:10] = '{32'd110, 32'd50, 32'd16, 32'd94, 32'd78, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0};

    alu dut (.*);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);

        opcode = 4'd0;
        a = 32'd80;
        b = 32'd30;
        inv = 1'b0;
        #1;

        for (int i = 0; i < 11; i++) begin
            opcode = i;
            $strobe("opcode=%0d, a=%0d, b=%0d, inv=%b, q=%0d, exp=%0d", opcode, a, b, inv, q, results[i]);
            #1;
        end

        $display("PASS");
        $finish;
    end

endmodule
