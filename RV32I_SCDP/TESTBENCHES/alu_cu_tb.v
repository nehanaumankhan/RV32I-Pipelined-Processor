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

    // check task: if check_enable==1 then compare, else print SKIPPED (dont-care)
    task check;
        input [2:0]  t_aluop;
        input [6:0]  t_funct7;
        input [2:0]  t_funct3;
        input [3:0]  expected;
        input        check_enable; // 1 = compare, 0 = skip (don't care)
        input [80*8:1] name;
        begin
            tests = tests + 1;
            aluop  = t_aluop;
            funct7 = t_funct7;
            funct3 = t_funct3;
            #1;
            if (check_enable) begin
                if (alu_control !== expected) begin
                    $error("FAIL: %s — aluop=%b funct7[5]=%b funct3=%b -> got %b expected %b",
                           name, aluop, funct7[5], funct3, alu_control, expected);
                    errors = errors + 1;
                end else begin
                    $display("PASS: %s", name);
                end
            end else begin
                $display("SKIP: %s — ALU output don't-care (skipped check)", name);
            end
        end
    endtask

    initial begin
        $display("\n===== ALU_CU: Running full RV32I test vector (38 insns) =====\n");

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

        // ---------------- I-type arithmetic (9: 8 imm-arith + JALR handled later)
        check(`I_TYPE, 7'b0000000, 3'b000, `ADD, 1, "ADDI");
        check(`I_TYPE, 7'b0000000, 3'b001, `SLL, 1, "SLLI");
        check(`I_TYPE, 7'b0000000, 3'b010, `less_than, 1, "SLTI");
        check(`I_TYPE, 7'b0000000, 3'b011, `less_than_unsigned, 1, "SLTIU");
        check(`I_TYPE, 7'b0000000, 3'b100, `XOR, 1, "XORI");
        check(`I_TYPE, 7'b0000000, 3'b101, `SRL, 1, "SRLI");    // SRLI (funct7=0000000)
        check(`I_TYPE, 7'b0100000, 3'b101, `SRA, 1, "SRAI");    // SRAI (funct7=0100000)
        check(`I_TYPE, 7'b0000000, 3'b110, `OR, 1, "ORI");
        check(`I_TYPE, 7'b0000000, 3'b111, `AND,1, "ANDI");

        // ---------------- Loads (5 variants)
        check(`LOAD, 7'b0000000, 3'b000, `ADD, 1, "LB");
        check(`LOAD, 7'b0000000, 3'b001, `ADD, 1, "LH");
        check(`LOAD, 7'b0000000, 3'b010, `ADD, 1, "LW");
        check(`LOAD, 7'b0000000, 3'b100, `ADD, 1, "LBU");
        check(`LOAD, 7'b0000000, 3'b101, `ADD, 1, "LHU");

        // ---------------- Stores (3 variants)
        check(`STORE, 7'b0000000, 3'b000, `ADD, 1, "SB");
        check(`STORE, 7'b0000000, 3'b001, `ADD, 1, "SH");
        check(`STORE, 7'b0000000, 3'b010, `ADD, 1, "SW");

        // ---------------- Branches (6)
        check(`BRANCH, 7'b0000000, 3'b000, `equal, 1, "BEQ");
        check(`BRANCH, 7'b0000000, 3'b001, `not_equal, 1, "BNE");
        check(`BRANCH, 7'b0000000, 3'b100, `less_than, 1, "BLT");
        check(`BRANCH, 7'b0000000, 3'b101, `greater_than, 1, "BGE");
        check(`BRANCH, 7'b0000000, 3'b110, `less_than_unsigned, 1, "BLTU");
        check(`BRANCH, 7'b0000000, 3'b111, `greater_than_unsigned, 1, "BGEU");

        // ---------------- U-type (LUI, AUIPC)
        // LUI: ALU result is don't-care in my design => SKIP CHECK
        check(`U_TYPE, 7'b0000000, 3'b000, 4'b0000, 0, "LUI (don't-care)");
        // AUIPC should perform PC+imm — I mapped it to ADD (PC + imm); check ADD
        check(`U_TYPE, 7'b0000000, 3'b000, `ADD, 1, "AUIPC");

        // ---------------- Jumps (JAL, JALR)
        // Your implementation uses JUMP macro for both JAL and JALR (pc_plus_4)
        check(`JUMP, 7'b0000000, 3'b000, `pc_plus_4, 1, "JAL");
        check(`JUMP, 7'b0000000, 3'b000, `pc_plus_4, 1, "JALR");

        // ---------------- NOP (treated as ADD in your earlier code)
        check(`NOP, 7'b0000000, 3'b000, `ADD, 1, "NOP");

        // ---------------- Summary ----------------
        #1;
        $display("\n=== SUMMARY ===");
        $display("Total tests run : %0d", tests);
        $display("Total failures  : %0d", errors);
        if (errors == 0) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");

        $stop;
    end

endmodule
