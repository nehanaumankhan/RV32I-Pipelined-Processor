`include "RISCV_PKG.vh"

module datamemory(
    input clk,
    input reset,
    input mem_read,
    input mem_write,
    input [$clog2(`MEM_SIZE)-1:0] address,         // fixed range (MEM_SIZE is byte count)
    input [`INSTRUCTION_SIZE-1:0] write_data,      // fixed width: 31:0 not 32:0
    input [2:0] funct3,
    output reg [`INSTRUCTION_SIZE-1:0] read_data   // must be reg for procedural assignment
);

    integer k;
    reg [7:0] mem [0:`MEM_SIZE-1];  // byte-addressable memory

    //====================================================
    // WRITE Operation
    //====================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (k = 0; k < `MEM_SIZE; k = k + 1)
                mem[k] <= 8'h00;
        end 
        else if (mem_write) begin
            case (funct3)
                3'b000: begin  // SB
                    mem[address] <= write_data[7:0];
                end
                3'b001: begin  // SH
                    mem[address]     <= write_data[7:0];
                    mem[address + 1] <= write_data[15:8];
                end
                3'b010: begin  // SW
                    mem[address]     <= write_data[7:0];
                    mem[address + 1] <= write_data[15:8];
                    mem[address + 2] <= write_data[23:16];
                    mem[address + 3] <= write_data[31:24];
                end
                default: ; // do nothing
            endcase
        end
    end

    //====================================================
    // READ Operation (Combinational)
    //====================================================
    always @(*) begin
        if (mem_read) begin
            case (funct3)
                3'b000:  read_data = {{24{mem[address][7]}}, mem[address]};                     // LB
                3'b100:  read_data = {{24{1'b0}}, mem[address]};                                // LBU

                3'b001:  read_data = {{16{mem[address+1][7]}}, mem[address+1], mem[address]};   // LH
                3'b101:  read_data = {{16{1'b0}}, mem[address+1], mem[address]};                // LHU

                3'b010:  read_data = {mem[address+3], mem[address+2], mem[address+1], mem[address]}; // LW
                default: read_data = 32'b0;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end

endmodule