`include "RISCV_PKG.vh"

// ==================== WRAPPER MODULE ====================
module wrapper (
    input clk,
    input rst,
    output [7:0] AN , 
    output [7:0] SEG_C,
    output [3:0] data_memory_out,
    output [3:0] regfile_rd_out,
    output [7:0] pc_out_debug
);
wire [3:0] alu_result_out;
    // ==================== CLOCK DIVIDER ====================
    parameter DIVIDE_BY = 500000000; // adjust to slow CPU clock (~0.5 Hz)
    reg [$clog2(DIVIDE_BY)-1:0] counter = 0;
    reg slow_clk = 0;

    always @(posedge clk or posedge rst) begin
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
    assign AN = 8'b11111110;
    // ALU_RESULT
    hex_to_7seg u0(
    .hex(alu_result_out),   
    .seg(SEG_C));

endmodule