`include "RISCV_PKG.vh"
module imm_gen(
    input [`INSTRUCTION_SIZE-1:0] instruction,
    output reg [`INSTRUCTION_SIZE-1:0] imm_out
);
always @(*) begin
    case (instruction[6:0])
        7'b0000011: // I-type (Load)
            imm_out = {{20{instruction[31]}}, instruction[31:20]};
        7'b0010011: // I-type (ALU immediate)
            imm_out = {{20{instruction[31]}}, instruction[31:20]};
        7'b0100011: // S-type (Store)
            imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
        7'b1100011: // B-type (Branch)
            imm_out = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        7'b1101111: // J-type (JAL)
            imm_out = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        7'b1100111: // I-type (JALR)
            imm_out = {{20{instruction[31]}}, instruction[31:20]};
        7'b0110111, 7'b0010111: // U-type (LUI, AUIPC)
            imm_out = {instruction[31:12], 12'b0};
        default:
            imm_out = 32'b0;
    endcase 
end

endmodule