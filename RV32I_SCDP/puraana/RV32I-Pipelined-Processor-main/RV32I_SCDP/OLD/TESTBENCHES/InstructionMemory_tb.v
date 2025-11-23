`timescale 1ns / 1ns
`include "RISCV_PKG.vh"

module InstructionMemory_tb;

    reg  [`INSTRUCTION_SIZE-1:0] InstructionAddress;
    wire [`INSTRUCTION_SIZE-1:0] ReadInstruction;

    InstructionMemory uut (
        .InstructionAddress(InstructionAddress),
        .ReadInstruction(ReadInstruction)
    );

    // Instruction list (converted from your bytes)
    reg [31:0] expected_inst [0:26];
    integer i;

    task check_output;
        input integer addr;
        input [31:0] expected;
        begin
            InstructionAddress = addr;
            #1;
            $display("PC=%0d | Got=%h | Expected=%h", addr, ReadInstruction, expected);

            if (ReadInstruction !== expected) begin
                $display("ERROR at PC=%0d: Got %h Expected %h",
                        addr, ReadInstruction, expected);
            end else begin
                $display("PASS");
            end
        end
    endtask


    initial begin
        $display("\n========== Instruction Memory Test ==========\n");

        // Fill expected array exactly in order of your byte stream
        expected_inst[0]  = 32'h000000B7;
        expected_inst[1]  = 32'h00000117;
        expected_inst[2]  = 32'h00500193;
        expected_inst[3]  = 32'h00A00213;
        expected_inst[4]  = 32'h0091B293;
        expected_inst[5]  = 32'h00324313;
        expected_inst[6]  = 32'h005183B3;
        expected_inst[7]  = 32'h00627433;
        expected_inst[8]  = 32'h0051E4B3;
        expected_inst[9]  = 32'h0041C533;
        expected_inst[10] = 32'h00702023;
        expected_inst[11] = 32'h00800223;
        expected_inst[12] = 32'h00901423;
        expected_inst[13] = 32'h00002583;
        expected_inst[14] = 32'h00404603;
        expected_inst[15] = 32'h00805683;
        expected_inst[16] = 32'h00358463;
        expected_inst[17] = 32'h00359263;
        expected_inst[18] = 32'h0041C263;
        expected_inst[19] = 32'h00325263;
        expected_inst[20] = 32'h0041E263;
        expected_inst[21] = 32'h00327263;
        expected_inst[22] = 32'h0080076F;
        expected_inst[23] = 32'h00900793;
        expected_inst[24] = 32'h00170813;
        expected_inst[25] = 32'h00080067;
        expected_inst[26] = 32'h0000006F;

        // Run test for each instruction (0, 4, 8, 
        for (i = 0; i < 27; i = i + 1) begin
            check_output(i*4, expected_inst[i]);
        end

        $display("\nAll tests completed.\n");
        $stop;
    end

endmodule
