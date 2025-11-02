`timescale 1ns/1ns
`include "RISCV_PKG.vh"

module alu_cu_tb;

    reg [2:0] aluop;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire [3:0] alu_control;

    integer errors = 0;

    alu_cu uut (
        .aluop(aluop),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    // -------------------- TASK --------------------
    task check;
        input [2:0] op;
        input [2:0] f3;
        input [6:0] f7;
        input [3:0] expected;
        input [127:0] instr_name;
        begin
            aluop  = op;
            funct3 = f3;
            funct7 = f7;
            #1;
            if (alu_control !== expected) begin
                $error("[%0s] FAILED: aluop=%b funct7=%b funct3=%b → got %b, expected %b",
                       instr_name, aluop, funct7, funct3, alu_control, expected);
                errors = errors + 1;
            end else begin
                $display("[%0s] OK", instr_name);
            end
        end
    endtask

    // -------------------- TEST VECTORS --------------------
    initial begin
        $display("=== Starting ALU Control Unit Tests ===");

        // -------- R-type (aluop = R_TYPE = 000) --------
        check(`R_TYPE, 3'b000, 7'b0000000, `ADD,  "ADD");
        check(`R_TYPE, 3'b000, 7'b0100000, `SUB,  "SUB");
        check(`R_TYPE, 3'b111, 7'b0000000, `AND,  "AND");
        check(`R_TYPE, 3'b110, 7'b0000000, `OR,   "OR");
        check(`R_TYPE, 3'b100, 7'b0000000, `XOR,  "XOR");
        check(`R_TYPE, 3'b001, 7'b0000000, `SLL,  "SLL");
        check(`R_TYPE, 3'b101, 7'b0000000, `SRL,  "SRL");
        check(`R_TYPE, 3'b101, 7'b0100000, `SRA,  "SRA");
        check(`R_TYPE, 3'b010, 7'b0000000, `less_than, "SLT");
        check(`R_TYPE, 3'b011, 7'b0000000, `less_than_unsigned, "SLTU");

        // -------- I-type (aluop = I_TYPE = 001) --------
        check(`I_TYPE, 3'b000, 7'b0000000, `ADD, "ADDI");
        check(`I_TYPE, 3'b111, 7'b0000000, `AND, "ANDI");
        check(`I_TYPE, 3'b110, 7'b0000000, `OR,  "ORI");
        check(`I_TYPE, 3'b100, 7'b0000000, `XOR, "XORI");
        check(`I_TYPE, 3'b001, 7'b0000000, `SLL, "SLLI");
        check(`I_TYPE, 3'b101, 7'b0000000, `SRL, "SRLI");
        check(`I_TYPE, 3'b101, 7'b0100000, `SRA, "SRAI");
        check(`I_TYPE, 3'b010, 7'b0000000, `less_than, "SLTI");
        check(`I_TYPE, 3'b011, 7'b0000000, `less_than_unsigned, "SLTIU");

        // -------- S-type (aluop = S_TYPE = 010) --------
        check(`S_TYPE, 3'b010, 7'b0000000, `ADD, "SW");
        check(`S_TYPE, 3'b010, 7'b0000000, `ADD, "SH");
        check(`S_TYPE, 3'b010, 7'b0000000, `ADD, "SB");

        // -------- SB-type (aluop = SB_TYPE = 011) --------
        check(`SB_TYPE, 3'b000, 7'b0000000, `SUB, "BEQ");
        check(`SB_TYPE, 3'b001, 7'b0000000, `SUB, "BNE");
        check(`SB_TYPE, 3'b100, 7'b0000000, `less_than, "BLT");
        check(`SB_TYPE, 3'b101, 7'b0000000, `greater_than, "BGE");
        check(`SB_TYPE, 3'b110, 7'b0000000, `less_than_unsigned, "BLTU");
        check(`SB_TYPE, 3'b111, 7'b0000000, `greater_than_unsigned, "BGEU");

        // -------- U-type (aluop = U_TYPE = 100) --------
        check(`U_TYPE, 3'b000, 7'b0000000, `ADD, "LUI");
        check(`U_TYPE, 3'b000, 7'b0000000, `ADD, "AUIPC");

        // -------- UJ-type (aluop = UJ_TYPE = 101) --------
        check(`UJ_TYPE, 3'b000, 7'b0000000, `ADD, "JAL");
        check(`UJ_TYPE, 3'b000, 7'b0000000, `ADD, "JALR");

        // -------- NOP (aluop = 110) --------
        check(`NOP, 3'b000, 7'b0000000, 4'b0000, "NOP");

        // -------------------- Results --------------------
        #5;
        if (errors == 0)
            $display("All ALU_CU test cases PASSED successfully!");
        else
            $display("%0d ALU_CU test case(s) FAILED!", errors);

        $finish;
    end

endmodule
