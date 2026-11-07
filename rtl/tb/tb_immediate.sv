`timescale 1ns/1ps

module tb_immediate;

    logic [31:0] ins, imm;
    logic [2:0]  imm_type;

    logic [31:0] instructions [0:5] = '{
        32'h008280b3, // add x1, x5, x8
        32'h07128093, // addi x1, x5, 113
        32'h00c02a23, // sw x12, 20(x0)
        32'h01fb8263, // beq x23, x31, 4
        32'h00166537, // lui x10, 358
        32'h00C0016f  // jal x2, 12
    };
    logic [31:0] results [0:5] = '{32'd0, 32'd113, 32'd20, 32'd4, 32'd358 << 12, 32'd12};

    immediate dut (.*);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);

        for (int i = 0; i < 6; i++) begin
            ins = instructions[i];
            imm_type = i;
            $strobe("ins=%h, imm_type=%0d, imm=%0d, exp=%0d", ins, imm_type, imm, results[i]);
            #1;
        end

        $display("PASS");
        $finish;
    end

endmodule
