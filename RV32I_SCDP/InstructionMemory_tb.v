`timescale 1ns / 1ns
`include "RISCV_PKG.vh"

module InstructionMemory_tb;

    // Testbench signals
    reg [INSTRUCTION_SIZE-1:0] InstructionAddress;
    wire [INSTRUCTION_SIZE-1:0] ReadInstruction;

    // Instantiate the DUT
    InstructionMemory uut (
        .InstructionAddress(InstructionAddress),
        .ReadInstruction(ReadInstruction)
    );

    // Task to check results with assertions
    task check_output;
        input [31:0] expected;
        begin
            #1; // wait for combinational propagation
            $display("Time=%0t | PC=%0d | Instruction=%h (Expected=%h)", $time, InstructionAddress, ReadInstruction, expected);
            assert (ReadInstruction === expected)
                else $error("Mismatch at PC=%0d: Got %h, Expected %h", InstructionAddress, ReadInstruction, expected);
        end
    endtask

    // Test sequence
    initial begin
        $display("=========== Instruction Memory Test ===========");

        // Initialize address
        InstructionAddress = 0;
        #5;

        // Test instruction at address 0
        // Expected: 0x00000033 (add x0, x0, x0)
        check_output(32'h00000033);

        // Test instruction at address 4
        // Expected: 0x00100093 (addi x1, x0, 1)
        InstructionAddress = 4;
        check_output(32'h00100093);

        // Test instruction at address 8
        // Expected: 0x00200113 (addi x2, x0, 2)
        InstructionAddress = 8;
        check_output(32'h00200113);

        // Test instruction at address 12
        // Expected: 0x00300193 (addi x3, x0, 3)
        InstructionAddress = 12;
        check_output(32'h00300193);

        $display("All instruction fetch tests PASSED!");
        $finish;
    end

endmodule
