`include "RISCV_PKG.vh"
module alu(
    input [`INSTRUCTION_SIZE-1:0] rs1,
    input [`INSTRUCTION_SIZE-1:0] rs2,
    input [3:0] alu_control,
    output reg [`INSTRUCTION_SIZE-1:0] result
);
always @(*) begin
    case (alu_control)
        `ADD:                   result = rs1 + rs2;
        `SUB:                   result = rs1 - rs2;
        `less_than:             result = {31'b0, ($signed(rs1) < $signed(rs2))}; 
        `less_than_unsigned:    result = {31'b0, (rs1 < rs2)};
        `greater_than:          result = {31'b0, ($signed(rs1) > $signed(rs2))};
        `greater_than_unsigned: result = {31'b0, (rs1 > rs2)};
        `XOR:                   result = rs1 ^ rs2;
        `OR:                    result = rs1 | rs2;
        `AND:                   result = rs1 & rs2;
        `SLL:                   result = rs1 << rs2[4:0];
        `SRL:                   result = rs1 >> rs2[4:0];
        `SRA:                   result = $signed(rs1) >>> rs2[4:0];
        default:                result = 32'b0;
    endcase
end
endmodule