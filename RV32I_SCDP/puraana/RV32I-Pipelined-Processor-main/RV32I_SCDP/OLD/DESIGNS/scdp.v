`include "RISCV_PKG.vh"

module SCDP(
    input clk, rst,
     // === Added Outputs for Observation ===
    output [`INSTRUCTION_SIZE-1:0] alu_result_out,
    output [`INSTRUCTION_SIZE-1:0] regfile_rd_out,
    output [`INSTRUCTION_SIZE-1:0] data_memory_out,
    output [`INSTRUCTION_SIZE-1:0] pc_out_debug
    );

    wire memread, memwrite, branch, jump, regwrite, pcsrc, alusrc1, alusrc2, lui, memtoreg, b_or_j, branch_taken;
    wire [2:0] aluop;
    wire [3:0] alu_control;
    wire [`INSTRUCTION_SIZE-1:0] instruction, rs1_data, rs2_data, rd_data, pc_in, pc_out, operand1, operand2, alu_result, data_memory_output, alu_or_data_out, immediate, adder_input_1, adder_input_2;

    InstructionMemory instruction_memory (
        .InstructionAddress(pc_out), // Connect to PC output
        .ReadInstruction(instruction) // Connect to instruction fetch logic
    );
    control_unit control_unit (
        .opcode(instruction[6:0]), // Connect to instruction opcode
        .aluop(aluop), // Connect to ALU control logic
        .memread(memread), // Connect to data memory read logic
        .memwrite(memwrite), // Connect to data memory write logic
        .branch(branch), // Connect to branch control logic
        .jump(jump), // Connect to jump control logic
        .regwrite(regwrite), // Connect to register file write logic
        .pcsrc(pcsrc), // Connect to PC source selection logic
        .alusrc1(alusrc1), // Connect to ALU source 1 selection logic
        .alusrc2(alusrc2), // Connect to ALU source 2 selection logic
        .lui(lui), // Connect to LUI control logic
        .memtoreg(memtoreg) // Connect to memory to register selection logic
    );

    regfile register_file (
        .clk(clk),
        .rst(rst),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .read_data1(rs1_data), 
        .read_data2(rs2_data),
        .write_data(rd_data), // Connect to write back data logic
        .regwrite(regwrite) // Connect to control unit regwrite signal
    );

    mux ALUSRC1_mux (
        .sel(alusrc1),
        .in0(rs1_data), // Connect to register file read data 1
        .in1(pc_out), // Connect to PC value for JAL/JALR
        .out(operand1) // Connect to ALU input 1
    );

    mux ALUSRC2_mux (
        .sel(alusrc2),
        .in0(rs2_data), // Connect to register file read data 2
        .in1(immediate), // Connect to immediate value from ImmGen
        .out(operand2) // Connect to ALU input 2
    );

    alu_cu ALU_control_unit (
        .aluop(aluop), // Connect to control unit aluop signal
        .funct3(instruction[14:12]), // Connect to instruction funct3 field
        .funct7(instruction[31:25]), // Connect to instruction funct7 field
        .alu_control(alu_control) // Connect to ALU control input
    );

    alu ALU (
        .rs1(operand1),
        .rs2(operand2),
        .alu_control(alu_control),
        .result(alu_result) // Connect to MemToReg mux 
    );

    datamemory data_memory (
        .clk(clk),
        .reset(rst),
        .funct3(instruction[14:12]), 
        .address(alu_result[11:0]), // Connect to ALU result
        .write_data(rs2_data), // Connect to register file read data 2
        .mem_read(memread), // Connect to control unit memread signal
        .mem_write(memwrite), // Connect to control unit memwrite signal
        .read_data(data_memory_output) // Connect to MemToReg mux
    );

    mux MEMTOREG_MUX (
        .sel(memtoreg),
        .in0(alu_result), // Connect to ALU result
        .in1(data_memory_output), // Connect to data memory output
        .out(alu_or_data_out) // Connect to register file write data
    );

    imm_gen Immediate_Generator (
        .instruction(instruction),
        .imm_out(immediate) // Connect to ALUSRC2 mux
    );

    mux LUI_MUX (
        .sel(lui),
        .in0(alu_or_data_out), // Connect to MemToReg mux output
        .in1(immediate), // Connect to immediate value from ImmGen
        .out(rd_data) // Connect to register file write data
    );

    and branch_and (
        branch_taken,
        branch,
        alu_result[0] // Assuming ALU result zero flag indicates branch condition
    );

    or jump_or_branch (
        b_or_j,
        jump,
        branch_taken
    );

    mux PC_MUX1 (
        .sel(b_or_j),
        .in0(32'd4), // Next sequential instruction
        .in1(immediate), // 
        .out(adder_input_1) // Connect to PC input
    );

    mux PC_MUX2 (
        .sel(pcsrc),
        .in0(pc_out), // Current PC value
        .in1(rs1_data), // For JALR, use rs1_data as base
        .out(adder_input_2) // Connect to PC input
    );

    adder PC_adder (
        .in1(adder_input_2),
        .in2(adder_input_1),
        .out(pc_in) // Connect to PC input
    );
    pc program_counter (
        .clk(clk),
        .rst(rst),
        .in(pc_in), // Connect to next PC logic
        .out(pc_out) // Connect to instruction memory address
    );

    // === Assign Outputs for Observation ===
    assign alu_result_out = alu_result;
    assign regfile_data1_out = rs1_data;
    assign regfile_data2_out = rs2_data;
    assign regfile_rd_out = rd_data;
    assign data_memory_out = data_memory_output;
    assign pc_out_debug = pc_out;
    
endmodule