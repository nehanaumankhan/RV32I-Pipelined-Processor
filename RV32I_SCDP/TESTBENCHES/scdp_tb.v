`timescale 1ns/1ps
`include "RISCV_PKG.vh"

module SCDP_tb;

    reg clk, rst;

    // DUT outputs (make sure SCDP has these outputs declared)
    wire [31:0] alu_result;
    wire [31:0] pc_out;
    wire [31:0] reg_rs1_data;
    wire [31:0] reg_rs2_data;
    wire [31:0] rd_data;
    wire [31:0] data_memory_output;

    // Instantiate the main processor (SCDP)
    SCDP uut (
        .clk(clk),
        .rst(rst),
        .alu_result(alu_result),
        .pc_out(pc_out),
        .reg_rs1_data(reg_rs1_data),
        .reg_rs2_data(reg_rs2_data),
        .rd_data(rd_data),
        .data_memory_output(data_memory_output)
    );

    // Clock generation — 10 ns period
    always #5 clk = ~clk;

    // Simulation control
    initial begin
        $display("===========================================");
        $display("     RISC-V Single Cycle Datapath Test     ");
        $display("===========================================");
        clk = 0;
        rst = 1;
        #10 rst = 0;   // Release reset
    end

    // Monitor datapath behavior
    initial begin
        $display("Time\tPC\t\tALU_Result\tRS1_Data\tRS2_Data\tMem_Out\t\tRD_Data");
        $display("--------------------------------------------------------------------------");
        $monitor("%0t\t%h\t%h\t%h\t%h\t%h\t%h",
                 $time, pc_out, alu_result, reg_rs1_data, reg_rs2_data, data_memory_output, rd_data);
    end

    // Stop simulation after some time
    initial begin
        #300; // Run enough cycles to execute full program
        $display("\n===========================================");
        $display("     Simulation Finished — Check Results   ");
        $display("===========================================\n");
        $stop;
    end

    // Optional VCD dump for GTKWave or ModelSim waveform viewing
    initial begin
        $dumpfile("SCDP_wave.vcd");
        $dumpvars(0, SCDP_tb);
    end

endmodule
