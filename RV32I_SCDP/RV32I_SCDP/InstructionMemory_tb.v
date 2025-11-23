`timescale 1ns/1ns
`include "RISCV_PKG.vh"
module InstructionMemory_tb;

    reg  [`INSTRUCTION_SIZE-1:0] InstructionAddress;
    wire [`INSTRUCTION_SIZE-1:0] ReadInstruction;
    integer pass_count;
    integer fail_count;
    integer i;

    // Byte-array to load MachineCode.mem inside TB
    reg [7:0] memfile_bytes [0:`MEM_SIZE-1];

    // Instantiate UUT
    InstructionMemory uut (
        .InstructionAddress(InstructionAddress),
        .ReadInstruction(ReadInstruction)
    );
    // Task: Compare Expected vs Actual
    task check_result;
        input [31:0] actual;
        input [31:0] expected;
        input integer addr;
        begin
            #1;
            if (actual === expected) begin
                $display("[PASS] PC=%0d | Expected=%h, Got=%h", addr, expected, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] PC=%0d | Expected=%h, Got=%h", addr, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Build expected instruction word (little-endian) from memfile_bytes
    function [31:0] build_word_from_bytes;
        input integer addr;
        begin
            // little-endian: lowest-address holds LSB
            build_word_from_bytes = { memfile_bytes[addr+3], memfile_bytes[addr+2], memfile_bytes[addr+1], memfile_bytes[addr+0] };
        end
    endfunction

    initial begin
        $display("\n=== Instruction Memory TB ===\n");

        // Initialize counters
        pass_count = 0;
        fail_count = 0;

        // Read machine code file into testbench byte array
        $readmemh("MachineCode.mem", memfile_bytes);
        $display("Byte 0 = %h, Byte 1 = %h", memfile_bytes[0], memfile_bytes[1]);

        // Run through instructions (assume instructions are 4 bytes)
        for (i = 0; i <= `MEM_SIZE - 4; i = i + 4) begin
            InstructionAddress = i[(`INSTRUCTION_SIZE-1):0]; #2; 
            // reconstruct expected instruction from bytes
            check_result(ReadInstruction, build_word_from_bytes(i), i);
        end

        // Summary
        #5;
        $display("\n=== TEST SUMMARY ===");
        $display("PASS Count = %0d", pass_count);
        $display("FAIL Count = %0d", fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED :)");
        else
            $display("SOME TESTS FAILED :(");

        $stop;
    end

endmodule
