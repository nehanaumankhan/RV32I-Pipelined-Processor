`include "RISCV_PKG.vh"

module wrapper (
    input clk100MHz,    
    input rst,
    output [`INSTRUCTION_SIZE-1:0] alu_result_out,
    output [`INSTRUCTION_SIZE-1:0] regfile_rd_out,
    output [`INSTRUCTION_SIZE-1:0] data_memory_out,
    output [`INSTRUCTION_SIZE-1:0] pc_out_debug
);

    // --- Clock Divider ---
    parameter DIVIDE_BY = 100000; // adjust for CPU clock speed
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

    // --- Instantiate CPU ---
    SCDP cpu_inst (
        .clk(slow_clk),
        .rst(rst),
        .alu_result_out(alu_result_out),
        .regfile_rd_out(regfile_rd_out),
        .data_memory_out(data_memory_out),
        .pc_out_debug(pc_out_debug)
    );

endmodule
