`timescale 1ns/1ns
`include "RISCV_PKG.vh"

module datamemory_tb;

    // Testbench signals
    reg clk, reset, mem_read, mem_write;
    reg [$clog2(`MEM_SIZE)-1:0] address;
    reg [`INSTRUCTION_SIZE-1:0] write_data;
    reg [2:0] funct3;
    wire [`INSTRUCTION_SIZE-1:0] read_data;

    integer pass_count = 0, fail_count = 0;

    // Instantiate the DUT
    datamemory uut (
        .clk(clk),
        .reset(reset),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .funct3(funct3),
        .read_data(read_data)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    //==============================
    // Task to check correctness
    //==============================
    task check_result;
        input [31:0] expected;
        input [127:0] msg;
        begin
            #1; // allow read_data to update
            if (read_data === expected) begin
                $display("[PASS] %s | Expected = %h, Got = %h", msg, expected, read_data);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s | Expected = %h, Got = %h", msg, expected, read_data);
                fail_count = fail_count + 1;
            end
        end
    endtask

    //==============================
    // Test procedure
    //==============================
    initial begin
        $display("\n=== Starting Data Memory Testbench ===");

        // Initialize
        reset = 1; mem_read = 0; mem_write = 0;
        address = 0; write_data = 0; funct3 = 0;
        #10 reset = 0;

        //------------------------------------
        // 1. Test SW + LW
        //------------------------------------
        address = 8'h00; write_data = 32'hAABBCCDD; funct3 = 3'b010;
        mem_write = 1; #10 mem_write = 0;

        // Read back LW
        mem_read = 1; funct3 = 3'b010;
        #2 check_result(32'hAABBCCDD, "LW after SW at addr 0x00");
        mem_read = 0;

        //------------------------------------
        // 2. Test SH + LH
        //------------------------------------
        address = 8'h10; write_data = 32'h0000BEEF; funct3 = 3'b001;
        mem_write = 1; #10 mem_write = 0;

        // Signed halfword read
        mem_read = 1; funct3 = 3'b001;
        #2 check_result(32'hFFFFBEEF, "LH after SH (sign-extended)");
        mem_read = 0;

        //------------------------------------
        // 3. Test SH + LHU
        //------------------------------------
        mem_read = 1; funct3 = 3'b101;
        #2 check_result(32'h0000BEEF, "LHU after SH (zero-extended)");
        mem_read = 0;

        //------------------------------------
        // 4. Test SB + LB
        //------------------------------------
        address = 8'h20; write_data = 32'h000000AA; funct3 = 3'b000;
        mem_write = 1; #10 mem_write = 0;

        // Signed byte load
        mem_read = 1; funct3 = 3'b000;
        #2 check_result(32'hFFFFFFAA, "LB after SB (sign-extended)");
        mem_read = 0;

        //------------------------------------
        // 5. Test SB + LBU
        //------------------------------------
        mem_read = 1; funct3 = 3'b100;
        #2 check_result(32'h000000AA, "LBU after SB (zero-extended)");
        mem_read = 0;

        //------------------------------------
        // Summary
        //------------------------------------
        #10;
        $display("\n=== TEST SUMMARY ===");
        $display("PASS Count = %0d", pass_count);
        $display("FAIL Count = %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED SUCCESSFULLY :) ");
        else
            $display("SOME TESTS FAILED :(");

        $stop;
    end

endmodule
