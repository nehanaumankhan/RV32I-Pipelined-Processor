`timescale 1ns/1ns
`include "RISCV_PKG.vh"

module scdp_tb;

    // Clock and reset
    reg clk, rst;

    // Wires for observing outputs
    wire [`INSTRUCTION_SIZE-1:0] instruction_fetched;
    wire [`INSTRUCTION_SIZE-1:0] alu_result_out;
    wire [`INSTRUCTION_SIZE-1:0] regfile_data1_out;
    wire [`INSTRUCTION_SIZE-1:0] regfile_data2_out;
    wire [`INSTRUCTION_SIZE-1:0] regfile_rd_out;
    wire [`INSTRUCTION_SIZE-1:0] data_memory_out;
    wire [`INSTRUCTION_SIZE-1:0] pc_out_debug;

    // Instantiate the SCDP module
    SCDP dut (
        .clk(clk),
        .rst(rst),
        .instruction_fetched(instruction_fetched),
        .alu_result_out(alu_result_out),
        .regfile_data1_out(regfile_data1_out),
        .regfile_data2_out(regfile_data2_out),
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
        #800; // Run for 200ns (adjust depending on instruction count)
        $finish;
    end

endmodule
