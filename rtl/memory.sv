module memory import types::*; #(
    parameter int SIZE = 8192,
    localparam int ADDR_WIDTH = $clog2(SIZE)
)(
    input  logic                  clk, we, mem_sign,
    input  logic [ADDR_WIDTH+1:0] addr,
    input  logic [31:0]           wd,
    input  mem_width_t            mem_width,
    output logic [31:0]           rdata
);

    logic [7:0] mem0 [0:SIZE-1];
    logic [7:0] mem1 [0:SIZE-1];
    logic [7:0] mem2 [0:SIZE-1];
    logic [7:0] mem3 [0:SIZE-1];

    logic [31:0] mem [0:SIZE-1];

    logic [1:0] offset;
    logic [3:0] byte_enable;
    logic [ADDR_WIDTH-1:0] lane_addr;
    logic [4:0] wd_offset;
    logic [31:0] wd_aligned, mem_rdata;
    logic mem_we;

    initial begin
        $readmemh("crt0/main.hex", mem);

        for (int i = 0; i < SIZE; i++) begin
            mem0[i] = mem[i][7:0];
            mem1[i] = mem[i][15:8];
            mem2[i] = mem[i][23:16];
            mem3[i] = mem[i][31:24];
        end
    end

    always_comb begin
        offset = addr[1:0];
        byte_enable = 4'b0000;
        lane_addr = addr >> 2;
        wd_offset = offset * 8;
        wd_aligned = wd << wd_offset;
        mem_we = we && (addr[14] != 1'b1);

        if (mem_width == MEM_WORD)
            byte_enable = 4'b1111;
        else begin
            byte_enable[0] = (offset == 2'b00);
            byte_enable[1] = (offset == 2'b01) || (offset == 2'b00 && mem_width == MEM_HALFWORD);
            byte_enable[2] = (offset == 2'b10) || (offset == 2'b01 && mem_width == MEM_HALFWORD);
            byte_enable[3] = (offset == 2'b11 && mem_width == MEM_BYTE) || (offset == 2'b10 && mem_width == MEM_HALFWORD);
        end

        byte_enable &= {4{mem_we}};
    end

    always_ff @(posedge clk) begin
        if (byte_enable[0]) mem0[lane_addr] <= wd_aligned[7:0];
        if (byte_enable[1]) mem1[lane_addr] <= wd_aligned[15:8];
        if (byte_enable[2]) mem2[lane_addr] <= wd_aligned[23:16];
        if (byte_enable[3]) mem3[lane_addr] <= wd_aligned[31:24];

        mem_rdata <= {mem3[lane_addr], mem2[lane_addr], mem1[lane_addr], mem0[lane_addr]};
    end

    always_comb begin
        rdata = mem_rdata >> wd_offset;

        if      (mem_width == MEM_BYTE)     rdata = { {24{mem_sign ? rdata[7] : 1'b0}}, rdata[7:0] };
        else if (mem_width == MEM_HALFWORD) rdata = { {16{mem_sign ? rdata[15] : 1'b0}}, rdata[15:0] };
    end

endmodule
