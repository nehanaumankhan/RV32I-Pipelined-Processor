// ====================================================== //
// RISCV_PKG.vh : Package file for RV32I SCDP Processor   //
// ====================================================== //

`define INSTRUCTION_SIZE 32
`define WORD_LENGTH      32
`define MEM_SIZE         1024

// ALU Operation Codes
`define ADD                     4'b0000
`define SUB                     4'b0001 
`define less_than               4'b0010
`define less_than_unsigned      4'b0011
`define greater_than            4'b0100
`define greater_than_unsigned   4'b0101
`define XOR                     4'b0110
`define OR                      4'b0111
`define AND                     4'b1000
`define SLL                     4'b1001
`define SRL                     4'b1010
`define SRA                     4'b1011