`timescale 1ns/1ns
`include "RISCV_PKG.vh"

module alu_cu_tb;

    // DUT signals
    reg  [2:0] aluop;
    reg  [2:0] funct3;
    reg  [6:0] funct7;
    wire [3:0] alu_control;

    integer errors = 0;
    integer tests  = 0;

    // instantiate DUT
    alu_cu uut (
        .aluop(aluop),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    // check task (PASS formatting improved)
    task check;
        input [2:0]  t_aluop;
        input [6:0]  t_funct7;
        input [2:0]  t_funct3;
        input [3:0]  expected;
        input        check_enable; 
        input [80*8:1] name;
        begin
            tests = tests + 1;
            aluop  = t_aluop;
            funct7 = t_funct7;
            funct3 = t_funct3;
            #1;

            if (check_enable) begin
                if (alu_control !== expected) begin
                    $error("FAIL: %0s — aluop=%b funct7[5]=%b funct3=%b -> got %b expected %b",
                           name, aluop, funct7[5], funct3, alu_control, expected);
                    errors = errors + 1;
                end else begin
                    // UPDATED: No extra spaces
                    $display("PASS: %0s", name);
                end
            end else begin
                $display("SKIP: %0s — ALU output don't-care (skipped check)", name);
            end
        end
    endtask


    initial begin
        $display("===== ALU_CU: Running full RV32I test vector (38 insns) =====");

        // ---------------- R-type (10)
        check(`R_TYPE, 7'b0000000, 3'b000, `ADD,  1, "ADD");
        check(`R_TYPE, 7'b0100000, 3'b000, `SUB,  1, "SUB");
        check(`R_TYPE, 7'b0000000, 3'b001, `SLL,  1, "SLL");
        check(`R_TYPE, 7'b0000000, 3'b010, `less_than, 1, "SLT");
        check(`R_TYPE, 7'b0000000, 3'b011, `less_than_unsigned, 1, "SLTU");
        check(`R_TYPE, 7'b0000000, 3'b100, `XOR,  1, "XOR");
        check(`R_TYPE, 7'b0000000, 3'b101, `SRL,  1, "SRL");
        check(`R_TYPE, 7'b0100000, 3'b101, `SRA,  1, "SRA");
        check(`R_TYPE, 7'b0000000, 3'b110, `OR,   1, "OR");
        check(`R_TYPE, 7'b0000000, 3'b111, `AND,  1, "AND");

        // ---------------- I-type arithmetic (9)
        check(`I_TYPE, 7'b0000000, 3'b000, `ADD, 1, "ADDI");
        check(`I_TYPE, 7'b0000000, 3'b001, `SLL, 1, "SLLI");
        check(`I_TYPE, 7'b0000000, 3'b010, `less_than, 1, "SLTI");
        check(`I_TYPE, 7'b0000000, 3'b011, `less_than_unsigned, 1, "SLTIU");
        check(`I_TYPE, 7'b0000000, 3'b100, `XOR, 1, "XORI");
        check(`I_TYPE, 7'b0000000, 3'b101, `SRL, 1, "SRLI");
        check(`I_TYPE, 7'b0100000, 3'b101, `SRA, 1, "SRAI");
        check(`I_TYPE, 7'b0000000, 3'b110, `OR, 1, "ORI");
        check(`I_TYPE, 7'b0000000, 3'b111, `AND,1, "ANDI");

        // ---------------- Loads (5)
        check(`LOAD, 7'b0000000, 3'b000, `ADD, 1, "LB");
        check(`LOAD, 7'b0000000, 3'b001, `ADD, 1, "LH");
        check(`LOAD, 7'b0000000, 3'b010, `ADD, 1, "LW");
        check(`LOAD, 7'b0000000, 3'b100, `ADD, 1, "LBU");
        check(`LOAD, 7'b0000000, 3'b101, `ADD, 1, "LHU");

        // ---------------- Stores (3)
        check(`STORE, 7'b0000000, 3'b000, `ADD, 1, "SB");
        check(`STORE, 7'b0000000, 3'b001, `ADD, 1, "SH");
        check(`STORE, 7'b0000000, 3'b010, `ADD, 1, "SW");

        // ---------------- Branch (6)
        check(`BRANCH, 7'b0000000, 3'b000, `equal, 1, "BEQ");
        check(`BRANCH, 7'b0000000, 3'b001, `not_equal, 1, "BNE");
        check(`BRANCH, 7'b0000000, 3'b100, `less_than, 1, "BLT");
        check(`BRANCH, 7'b0000000, 3'b101, `greater_than, 1, "BGE");
        check(`BRANCH, 7'b0000000, 3'b110, `less_than_unsigned, 1, "BLTU");
        check(`BRANCH, 7'b0000000, 3'b111, `greater_than_unsigned, 1, "BGEU");

        // ---------------- U-type
        check(`U_TYPE, 7'b0000000, 3'b000, 4'b0000, 0, "LUI (don't-care)");
        check(`U_TYPE, 7'b0000000, 3'b000, `ADD, 1, "AUIPC");

        // ---------------- Jumps
        check(`JUMP, 7'b0000000, 3'b000, `pc_plus_4, 1, "JAL");
        check(`JUMP, 7'b0000000, 3'b000, `pc_plus_4, 1, "JALR");

        // ---------------- NOP
        check(`NOP, 7'b0000000, 3'b000, `ADD, 1, "NOP");

        // Summary
        #1;
        if (errors == 0) 
            $display("Total tests run : %0d, Total failures  : %0d ALL TESTS PASSED ALHAMDULILLAH!", tests, errors);
        else 
            $display("Total tests run : %0d, Total failures  : %0d SOME TESTS FAILED",tests, errors);

        $stop;
    end

endmodule
