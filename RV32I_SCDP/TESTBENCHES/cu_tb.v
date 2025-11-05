`timescale 1ns / 1ps
`include "RISCV_PKG.vh"   // Ensure this defines macros like `R_TYPE`, `I_TYPE`, etc.

module control_unit_tb;

    // Inputs
    reg [6:0] opcode;

    // Outputs
    wire regwrite, memread, memwrite, branch, jump, memtoreg, alusrc1, alusrc2, lui, pcsrc;
    wire [2:0] aluop;

    // Instantiate the DUT (Device Under Test)
    control_unit uut (
        .opcode(opcode),
        .regwrite(regwrite),
        .memread(memread),
        .memwrite(memwrite),
        .branch(branch),
        .jump(jump),
        .memtoreg(memtoreg),
        .alusrc1(alusrc1),
        .alusrc2(alusrc2),
        .lui(lui),
        .pcsrc(pcsrc),
        .aluop(aluop)
    );

    // Variables for test management
    integer total_tests = 0;
    integer failed_tests = 0;

    // Task to check and display results
    task check_output;
        input [6:0] opcode_t;
        input exp_regwrite, exp_memread, exp_memwrite, exp_branch, exp_jump, exp_memtoreg, exp_alusrc1, exp_alusrc2, exp_lui, exp_pcsrc;
        input [2:0] exp_aluop;
        begin
            total_tests = total_tests + 1;
            #5;
            if ({regwrite, memread, memwrite, branch, jump, memtoreg, alusrc1, alusrc2, lui, pcsrc, aluop} !== 
                {exp_regwrite, exp_memread, exp_memwrite, exp_branch, exp_jump, exp_memtoreg, exp_alusrc1, exp_alusrc2, exp_lui, exp_pcsrc, exp_aluop}) begin
                $display("Test %0d FAILED for opcode = %b", total_tests, opcode_t);
                failed_tests = failed_tests + 1;
            end else begin
                $display("Test %0d PASSED for opcode = %b", total_tests, opcode_t);
            end
        end
    endtask

    // Test procedure
    initial begin
        $display("========== Starting Control Unit Testbench ==========");

        // Default (NOP)
        opcode = 7'b0000000;
        check_output(opcode, 0,0,0,0,0,0,0,0,0,0, `NOP);

        // R-type
        opcode = 7'b0110011;
        check_output(opcode, 1,0,0,0,0,0,0,0,0,0, `R_TYPE);

        // I-type
        opcode = 7'b0010011;
        check_output(opcode, 1,0,0,0,0,0,0,1,0,0, `I_TYPE);

        // Load
        opcode = 7'b0000011;
        check_output(opcode, 1,1,0,0,0,1,0,1,0,0, `LOAD);

        // Store
        opcode = 7'b0100011;
        check_output(opcode, 0,0,1,0,0,0,0,1,0,0, `STORE);

        // Branch
        opcode = 7'b1100011;
        check_output(opcode, 0,0,0,1,0,0,0,0,0,0, `BRANCH);

        // JAL
        opcode = 7'b1101111;
        check_output(opcode, 1,0,0,0,1,0,1,0,0,0, `JUMP);

        // JALR
        opcode = 7'b1100111;
        check_output(opcode, 1,0,0,0,1,0,1,0,0,1, `JUMP);

        // LUI
        opcode = 7'b0110111;
        check_output(opcode, 1,0,0,0,0,0,0,1,1,0, `U_TYPE);

        // AUIPC
        opcode = 7'b0010111;
        check_output(opcode, 1,0,0,0,0,0,0,1,0,0, `U_TYPE);

        // Print Summary
        $display("=====================================================");
        $display("Total Tests Run: %0d", total_tests);
        $display("Tests Failed   : %0d", failed_tests);
        if (failed_tests == 0)
            $display("ALL TESTS PASSED SUCCESSFULLY!");
        else
            $display("Some tests FAILED. Please review outputs above.");
        $display("=====================================================");
        $finish;
    end
endmodule
