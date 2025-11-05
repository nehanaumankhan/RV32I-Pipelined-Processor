module control_unit(
    input [6:0]opcode,
    output reg regwrite, memread, memwrite, beq, bne, blt, bgt, bltu, bgeu, memtoreg, alusrc1, alusrc2,lui, jal, jalr
    output reg [2:0] aluop
);

endmodule