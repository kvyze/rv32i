module ram #(
    parameter SIZE = 1024
)(
    input  logic        clk, we, lu, // load unsigned
    input  logic [4:0]  slen,        // store data length
    input  logic [31:0] addr, wd,
    output logic [31:0] rdata,
    output logic        misaligned
);
    logic [31:0] memory [0:SIZE-1];
    logic [31:0] data;
    logic [4:0]  bit_offset;
    logic [9:0]  word_index;

    assign word_index = addr >> 2;
    assign bit_offset = addr[1:0] * 8;
    assign misaligned = (slen == 5'd15 && addr[0] != 0) || (slen == 5'd31 && addr[1:0] != 2'd0);
    
    always_comb begin
        {rdata, data} = '0;

        if (!misaligned && word_index < SIZE) begin
            for (int i = bit_offset, j = 0; i <= bit_offset + slen; i++, j++) begin
                data[j] = memory[word_index][i];
            end

            if      (slen == 5'd7)  rdata = { {24{lu ? 1'b0 : data[7]}},  data[7:0] };
            else if (slen == 5'd15) rdata = { {16{lu ? 1'b0 : data[15]}}, data[15:0] };
            else if (slen == 5'd31) rdata = data;
        end
    end

    always_ff @(posedge clk) begin
        if (we && !misaligned && word_index < SIZE) begin
            for (int i = bit_offset, j = 0; i <= bit_offset + slen; i++, j++) begin
                memory[word_index][i] <= wd[j];
            end
        end
    end

endmodule
