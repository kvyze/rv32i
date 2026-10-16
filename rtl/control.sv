module control (
    input  logic [31:0] ins,
    output logic [3:0]  alu_op,
    output logic [4:0]  rs1, rs2, rd, ram_slen,
    output logic [2:0]  imm_type,
    output logic        we, alu_inv, ram_we, ram_load, ram_load_u, lui, auipc, jal, jalr
);

    logic [6:0] opcode, funct7;
    logic [2:0] funct3;

    always_comb begin
        {we, alu_inv, ram_we, ram_load, ram_load_u, lui, auipc, jal, jalr} = '0;
        ram_slen   = 5'd0;
        alu_op     = 4'd15;
        imm_type   = 3'd0;
        rs2        = ins[24:20];
        rs1        = ins[19:15];
        rd         = ins[11:7];
        opcode     = ins[6:0];
        funct7     = ins[31:25];
        funct3     = ins[14:12];

        case (opcode)
            7'b0110111: begin                                       // lui
                imm_type = 3'd4;
                lui      = 1'b1;
                we       = 1'b1;
            end

            7'b0010111: begin                                       // auipc
                imm_type = 3'd4;
                auipc    = 1'b1;
                we       = 1'b1;
            end

            7'b1101111: begin
                imm_type = 3'd5;
                we       = 1'b1;
                jal      = 1'b1;
            end

            7'b1100111: begin
                if (funct3 == 3'b000) begin
                    imm_type = 3'd1;
                    we       = 1'b1;
                    jalr     = 1'b1;
                end
            end

            7'b0110011: begin
                we = 1'b1;

                if (funct3 == 3'b000)                               // add/sub
                    alu_op = (funct7 == 7'd0) ? 4'd0 : (funct7 == 7'b0100000) ? 4'd1 : 4'd15;
                    // we     = (funct7 == 7'd0 || funct7 == 7'b0100000) ? 1'b1 : 1'b0;
                else if (funct3 == 3'b111 && funct7 == 7'd0)        // and
                    alu_op = 4'd2;
                else if (funct3 == 3'b110 && funct7 == 7'd0)        // or
                    alu_op = 4'd3;
                else if (funct3 == 3'b100 && funct7 == 7'd0)        // xor
                    alu_op = 4'd4;
                else if (funct3 == 3'b001 && funct7 == 7'd0)        // sll
                    alu_op = 4'd5;
                else if (funct3 == 3'b101)                          // srl/sra
                    alu_op = (funct7 == 7'd0) ? 4'd6 : (funct7 == 7'b0100000) ? 4'd7 : 4'd15;
                else if (funct3 == 3'b010 && funct7 == 7'd0)        // slt
                    alu_op = 4'd8;
                else if (funct3 == 3'b011 && funct7 == 7'd0)        // sltu
                    alu_op = 4'd9;
            end

            7'b0010011: begin
                imm_type = 3'd1;
                we       = 1'b1;

                if (funct3 == 3'b000)                               // addi
                    alu_op = 4'd0;
                else if (funct3 == 3'b010)                          // slti
                    alu_op = 4'd8;
                else if (funct3 == 3'b011)                          // sltiu
                    alu_op = 4'd9;
                else if (funct3 == 3'b100)                          // xori
                    alu_op = 4'd4;
                else if (funct3 == 3'b110)                          // ori
                    alu_op = 4'd3;
                else if (funct3 == 3'b111)                          // andi
                    alu_op = 4'd2;
                else if (funct3 == 3'b001 && funct7 == 7'd0) begin  // slli
                    imm_type = 3'd6;
                    alu_op   = 4'd5;
                end else if (funct3 == 3'b101) begin                // srli/srai
                    imm_type = 3'd6;
                    alu_op   = (funct7 == 7'd0) ? 4'd6 : (funct7 == 7'b0100000) ? 4'd7 : 4'd15;
                end
            end

            7'b1100011: begin
                imm_type = 3'd3;

                if (funct3 == 3'b000)                               // beq
                    alu_op = 4'd10;
                else if (funct3 == 3'b001) begin                    // bne
                    alu_op  = 4'd10;
                    alu_inv = 1'b1;
                end else if (funct3 == 3'b100)                      // blt
                    alu_op = 4'd8;
                else if (funct3 == 3'b101) begin                    // bge
                    alu_op  = 4'd8;
                    alu_inv = 1'b1;
                end else if (funct3 == 3'b110)                      // bltu
                    alu_op = 4'd9;
                else if (funct3 == 3'b111) begin                    // bgeu
                    alu_op  = 4'd9;
                    alu_inv = 1'b1;
                end
            end

            7'b0100011: begin
                imm_type = 3'd2;
                ram_we   = 1'b1;

                if (funct3 == 3'b000)                               // sb
                    ram_slen = 5'd7;
                else if (funct3 == 3'b001)                          // sh
                    ram_slen = 5'd15;
                else if (funct3 == 3'b010)                          // sw
                    ram_slen = 5'd31;
            end

            7'b0000011: begin
                imm_type = 3'd1;
                ram_load = 1'b1;

                if (funct3 == 3'b000)                               // lb
                    ram_slen = 5'd7;
                else if (funct3 == 3'b001)                          // lh
                    ram_slen = 5'd15;
                else if (funct3 == 3'b010)                          // lw
                    ram_slen = 5'd31;
                else if (funct3 == 3'b100) begin                    // lbu
                    ram_slen   = 5'd7;
                    ram_load_u = 1'b1;
                end else if (funct3 == 3'b101) begin                // lhu
                    ram_slen   = 5'd15;
                    ram_load_u = 1'b1;
                end
            end

            default: ;
        endcase
    end

endmodule
