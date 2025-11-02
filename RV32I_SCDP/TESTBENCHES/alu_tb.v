`timescale 1ns / 1ps
`include "RISCV_PKG.vh"

module alu_tb;

    reg [31:0] rs1;
    reg [31:0] rs2;
    reg [3:0] alu_control;
    wire [31:0] result;

    // Instantiate the ALU
    alu uut (
        .rs1(rs1),
        .rs2(rs2),
        .alu_control(alu_control),
        .result(result)
    );

    // Task to check output and print results
    task check_result;
        input [31:0] in1, in2;
        input [3:0] ctrl;
        input [31:0] expected;
        begin
            rs1 = in1;
            rs2 = in2;
            alu_control = ctrl;
            #10;
            if (result !== expected)
                $display("❌ ERROR: ctrl=%0d | rs1=%0d | rs2=%0d | expected=%h | got=%h @ time %0t",
                         ctrl, in1, in2, expected, result, $time);
            else
                $display("✅ PASS: ctrl=%0d | rs1=%0d | rs2=%0d | result=%h", ctrl, in1, in2, result);
        end
    endtask

    initial begin
        $display("=== Starting ALU Testbench ===");

        // =========================
        // Arithmetic Operations
        // =========================
        check_result(10, 5, `ADD, 32'h0000000F);   // 10 + 5 = 15
        check_result(10, 5, `SUB, 32'h00000005);   // 10 - 5 = 5

        // =========================
        // Comparison Operations
        // =========================
        check_result(-3, 2, `less_than, 32'h00000001);            // -3 < 2 → true (1)
        check_result(32'hFFFFFFFF, 2, `less_than_unsigned, 32'h00000000); // 4294967295 < 2 → false (0)
        check_result(5, 3, `greater_than, 32'h00000001);          // 5 > 3 → true (1)
        check_result(10, 5, `greater_than_unsigned, 32'h00000001); // 10 > 5 → true (1)

        // =========================
        // Logical Operations
        // =========================
        check_result(32'hA5A5A5A5, 32'h0F0F0F0F, `AND, 32'h05050505); // Bitwise AND
        check_result(32'hA5A5A5A5, 32'h0F0F0F0F, `OR,  32'hAFAFAFAF); // Bitwise OR
        check_result(32'hAAAA5555, 32'h0F0F0F0F, `XOR, 32'hA5A55A5A); // Bitwise XOR

        // =========================
        // Shift Operations
        // =========================
        check_result(32'h00000001, 2, `SLL, 32'h00000004);  // 1 << 2 = 4
        check_result(32'h00000010, 2, `SRL, 32'h00000004);  // 16 >> 2 = 4 (logical)
        check_result(-32'sd16, 2, `SRA, -32'sd4);           // (-16) >>> 2 = -4 (arithmetic)

        $display("=== ALU Testbench Completed ===");
        $stop;
    end

endmodule
