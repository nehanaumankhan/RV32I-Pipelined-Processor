`include "RISCV_PKG.vh"
module alu_cu(
    input [2:0] aluop,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] alu_control
);
always @(*) begin
    casez ({aluop, funct7[5], funct3})
        7'b010_?_???, 7'b100_?_???, 7'b101_?_???, 7'b110_?_???, 7'b000_0_000, 7'b001_1_000 : alu_control = `ADD; 
        7'b000_1_000, 7'b011_?_000, 7'b011_?_001 : alu_control = `SUB;
        7'b011_?_100, 7'b001_?_010, 7'b000_0_010 : alu_control = `less_than;
        7'b011_?_101 : alu_control = `greater_than;
        7'b001_?_011, 7'b000_0_011 : alu_control = `less_than_unsigned;
        7'b011_?_111 : alu_control = `greater_than_unsigned;
        7'b000_0_100, 7'b001_?_100 : alu_control = `XOR;
        7'b000_0_110, 7'b001_?_110 : alu_control = `OR;
        7'b000_0_111, 7'b001_?_111 : alu_control = `AND;
        7'b001_0_001, 7'b000_0_001 : alu_control = `SLL;
        7'b001_0_101, 7'b000_0_101 : alu_control = `SRL;
        7'b000_1_100 : alu_control = `SRA;
        default: alu_control = 4'b0000;
    endcase
end
        
endmodule