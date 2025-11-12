`include "RISCV_PKG.vh"

// ==================== HEX TO 7-SEGMENT MODULE ====================
module hex_to_7seg(
    input [3:0] hex,
    output reg [6:0] seg // {a,b,c,d,e,f,g}
);
    always @(*) begin
        case(hex)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111; // all off
        endcase
    end
endmodule

// ==================== WRAPPER MODULE ====================
module wrapper (
    input clk100MHz,
    input rst,
    output [6:0] HEX0, HEX1, HEX2, HEX3, // ALU_RESULT lower 16 bits
    output [6:0] HEX4, HEX5, HEX6, HEX7, // DATA_MEMORY_OUT lower 16 bits
    //output [`INSTRUCTION_SIZE-1:0] alu_result_out,
    //output [`INSTRUCTION_SIZE-1:0] data_memory_out,
    output [`INSTRUCTION_SIZE-1:0] regfile_rd_out,
    output [`INSTRUCTION_SIZE-1:0] pc_out_debug
);

    // ==================== CLOCK DIVIDER ====================
    parameter DIVIDE_BY = 5000000; // adjust to slow CPU clock (~10 Hz)
    reg [$clog2(DIVIDE_BY)-1:0] counter = 0;
    reg slow_clk = 0;

    always @(posedge clk100MHz or posedge rst) begin
        if (rst) begin
            counter <= 0;
            slow_clk <= 0;
        end else begin
            if (counter == DIVIDE_BY-1) begin
                counter <= 0;
                slow_clk <= ~slow_clk;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    // ==================== INSTANTIATE CPU ====================
    SCDP cpu_inst (
        .clk(slow_clk),
        .rst(rst),
        .alu_result_out(alu_result_out),
        .regfile_rd_out(regfile_rd_out),
        .data_memory_out(data_memory_out),
        .pc_out_debug(pc_out_debug)
    );

    // ==================== CONNECT 7-SEGMENT DISPLAYS ====================
    // ALU_RESULT[15:0] → HEX0–HEX3
    hex_to_7seg u0(.hex(alu_result_out[3:0]),   .seg(HEX0));
    hex_to_7seg u1(.hex(alu_result_out[7:4]),   .seg(HEX1));
    hex_to_7seg u2(.hex(alu_result_out[11:8]),  .seg(HEX2));
    hex_to_7seg u3(.hex(alu_result_out[15:12]), .seg(HEX3));

    // DATA_MEMORY_OUT[15:0] → HEX4–HEX7
    hex_to_7seg u4(.hex(data_memory_out[3:0]),   .seg(HEX4));
    hex_to_7seg u5(.hex(data_memory_out[7:4]),   .seg(HEX5));
    hex_to_7seg u6(.hex(data_memory_out[11:8]),  .seg(HEX6));
    hex_to_7seg u7(.hex(data_memory_out[15:12]), .seg(HEX7));

endmodule
