`timescale 1ns/1ns
`include "RISCV_PKG.vh"

module scdp_tb;

    // Clock and reset
    reg clk, rst;

    // Wires for observing outputs
    wire [3:0] alu_result_out;
    wire [3:0] regfile_rd_out;
    wire [3:0] data_memory_out;
    wire [7:0] pc_out_debug;

    // Instantiate the SCDP module
    SCDP dut (
        .clk(clk),
        .rst(rst),
        .alu_result_out(alu_result_out),
        .regfile_rd_out(regfile_rd_out),
        .data_memory_out(data_memory_out),
        .pc_out_debug(pc_out_debug)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Reset sequence
    initial begin
        clk = 0;
        rst = 1;
        @(posedge clk);
        rst = 0;
    end

    // Run simulation for a fixed number of cycles
    initial begin
        #1000; 
        $stop;
    end

endmodule
