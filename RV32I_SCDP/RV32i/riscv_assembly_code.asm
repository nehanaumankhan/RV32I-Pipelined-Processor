    #############################################
    # U-type TEST: LUI, AUIPC
    #############################################
    # PC = 0x00
    lui   x1, 0x0          # x1 = 0
    auipc x2, 0            # x2 = PC (low bits <= 15 since PC < 128)

    #############################################
    # I-type TEST: ADDI, SLTIU, XORI
    #############################################
    # PC = 0x08
    addi  x3, x0, 5        # x3 = 5 → regfile_write=5
    addi  x4, x0, 10       # x4 = 10 → regfile_write=10
    sltiu x5, x3, 9        # 5 < 9 → x5 = 1
    xori  x6, x4, 3        # 10 XOR 3 = 9 → stays < 15

    #############################################
    # R-type TEST: ADD, AND, OR, XOR
    #############################################
    add   x7, x3, x5       # 5 + 1 = 6
    and   x8, x4, x6       # 10 & 9 = 8
    or    x9, x3, x5       # 5 | 1 = 5
    xor   x10, x3, x4      # 5 XOR 10 = 15

    #############################################
    # STORE/LOAD TEST: SW, SH, SB, LW, LBU, LHU
    #############################################
    # Memory accesses always stay within 128 bytes.
    # Store small values only (0–15).
    sw    x7, 0(x0)        # MEM[0] = 6  → data_memory_write_data = 6
    sb    x8, 4(x0)        # MEM[4] = 8  → 8 fits 4 bits
    sh    x9, 8(x0)        # MEM[8] = 5  → safe

    lw    x11, 0(x0)       # x11 = 6
    lbu   x12, 4(x0)       # x12 = 8
    lhu   x13, 8(x0)       # x13 = 5

    #############################################
    # BRANCH TESTS: BEQ, BNE, BLT, BGE, BLTU, BGEU
    #############################################
    beq   x11, x3, skip1   # 6==5? no → not taken
    bne   x11, x3, skip1   # taken
skip1:
    blt   x3, x4, skip2    # 5<10? → taken
skip2:
    bge   x4, x3, skip3    # 10>=5 → taken
skip3:
    bltu  x3, x4, skip4    # unsigned 5 < 10 → taken
skip4:
    bgeu  x4, x3, skip5    # unsigned 10 ≥ 5 → taken
skip5:

    #############################################
    # JUMP TEST: JAL, JALR
    #############################################
    jal   x14, jump_target   # x14 = return PC
    addi  x15, x0, 9         # skipped due to jump

jump_target:
    addi  x16, x14, 1        # x16 = small value (returnPC+1) still < 15

    # JALR back to halt loop
    jalr  x0, x16, 0

halt:
    jal x0, halt             # infinite loop
