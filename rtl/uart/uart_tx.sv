module uart_tx (
    input  logic       clk, rst, start,
    input  logic [7:0] data,
    output logic       tx, busy
);

    localparam int FREQUENCY = 234;

    logic       tick;
    logic [7:0] count;
    logic [9:0] sr;
    logic [3:0] bit_idx;

    assign tx = sr[0];

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            bit_idx <= 4'd0;
            sr      <= 10'h3FF;
            busy    <= 1'b0;
            tick    <= 1'b0;
            count   <= 8'd0;
        end else begin
            if (count >= FREQUENCY - 1) begin
                tick  <= 1'b1;
                count <= 8'd0;
            end else begin
                tick  <= 1'b0;
                count <= count + 1;
            end

            if (!busy && start) begin
                sr   <= {1'b1, data, 1'b0};
                busy <= 1'b1;
            end

            if (tick && busy) begin
                if (bit_idx >= 4'd9) begin
                    bit_idx <= 4'd0;
                    busy    <= 1'b0;
                end else begin
                    bit_idx <= bit_idx + 1;
                    sr <= sr >> 1;
                end
            end
        end
    end

endmodule
