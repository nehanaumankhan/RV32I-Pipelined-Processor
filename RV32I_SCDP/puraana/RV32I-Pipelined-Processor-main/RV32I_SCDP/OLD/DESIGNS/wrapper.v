`include "RISCV_PKG.vh"

// ==================== WRAPPER MODULE ====================
module wrapper (
    input clk100MHz,
    input rst,
    output [6:0] HEX0, HEX1, HEX2, HEX3, // ALU_RESULT lower 16 bits
    output [6:0] HEX4, HEX5, HEX6, HEX7, // DATA_MEMORY_OUT lower 16 bits
    output [`INSTRUCTION_SIZE-1:0] alu_result_out,
    output [`INSTRUCTION_SIZE-1:0] data_memory_out,
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
