`timescale 1ns/1ns
`include "RISCV_PKG.vh"

module regfile_tb;

    //===================================
    // DUT Signals
    //===================================
    reg clk, rst, regwrite;
    reg [$clog2(`REG_COUNT)-1:0] rs1, rs2, rd;
    reg [`INSTRUCTION_SIZE-1:0] write_data;
    wire [`INSTRUCTION_SIZE-1:0] read_data1, read_data2;

    integer pass_count = 0, fail_count = 0;

    //===================================
    // Instantiate DUT
    //===================================
    regfile uut (
        .clk(clk),
        .rst(rst),
        .regwrite(regwrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    //===================================
    // Clock Generation
    //===================================
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period

    //===================================
    // Task: Compare Expected vs Actual
    //===================================
    task check_result;
        input [31:0] actual;
        input [31:0] expected;
        input [127:0] msg;
        begin
            #1;
            if (actual === expected) begin
                $display("[PASS] %s | Expected = %h, Got = %h", msg, expected, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s | Expected = %h, Got = %h", msg, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    //===================================
    // Main Test Procedure
    //===================================
    initial begin
        $display("\n=== Starting Register File Testbench ===");

        //------------------------------------
        // 1. Reset
        //------------------------------------
        rst = 1; regwrite = 0;
        rs1 = 0; rs2 = 0; rd = 0; write_data = 0;
        #10 rst = 0;
        $display("[INFO] Reset complete, all registers = 0");

        //------------------------------------
        // 2. Write to x5 = 0xA5A5A5A5
        //------------------------------------
        rd = 5; write_data = 32'hA5A5A5A5; regwrite = 1;
        #10 regwrite = 0;

        // Read x5
        rs1 = 5; rs2 = 5;
        #2 check_result(read_data1, 32'hA5A5A5A5, "Write/Read x5");

        //------------------------------------
        // 3. Write to x10 = 0x12345678
        //------------------------------------
        rd = 10; write_data = 32'h12345678; regwrite = 1;
        #10 regwrite = 0;

        rs1 = 10;
        #2 check_result(read_data1, 32'h12345678, "Write/Read x10");

        //------------------------------------
        // 4. Write to x15 = 0x87654321
        //------------------------------------
        rd = 15; write_data = 32'h87654321; regwrite = 1;
        #10 regwrite = 0;

        rs1 = 15;
        #2 check_result(read_data1, 32'h87654321, "Write/Read x15");

        //------------------------------------
        // 5. Try writing to x0 (should not change)
        //------------------------------------
        rd = 0; write_data = 32'hFFFFFFFF; regwrite = 1;
        #10 regwrite = 0;

        rs1 = 0;
        #2 check_result(read_data1, 32'h00000000, "x0 remains 0 after write attempt");

        //------------------------------------
        // 6. Read x5 and x10 together
        //------------------------------------
        rs1 = 5; rs2 = 10;
        #2;
        check_result(read_data1, 32'hA5A5A5A5, "Parallel read rs1=x5");
        check_result(read_data2, 32'h12345678, "Parallel read rs2=x10");

        //------------------------------------
        // Summary
        //------------------------------------
        #10;
        $display("\n=== TEST SUMMARY ===");
        $display("PASS Count = %0d", pass_count);
        $display("FAIL Count = %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED SUCCESSFULLY :)");
        else
            $display("SOME TESTS FAILED :(");

        $stop;
    end

endmodule
