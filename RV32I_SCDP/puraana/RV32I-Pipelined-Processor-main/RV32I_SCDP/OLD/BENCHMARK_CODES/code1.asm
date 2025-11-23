# ================================
# Simple Test Program for SCDP
# ================================
# This program will:
# 1. Load immediate values
# 2. Perform arithmetic
# 3. Store and load to/from memory
# 4. Execute a simple branch and jump
# ================================

    LUI   x1, 0x00010       # x1 = 0x00010000
    ADDI  x2, x0, 5         # x2 = 5
    ADDI  x3, x0, 10        # x3 = 10
    ADD   x4, x2, x3        # x4 = 15
    SUB   x5, x3, x2        # x5 = 5
    SW    x4, 0(x1)         # MEM[x1 + 0] = x4 (15)
    LW    x6, 0(x1)         # x6 = MEM[x1 + 0] -> 15
    BEQ   x4, x6, LABEL1    # Branch if equal (should take branch)
    ADDI  x7, x0, 0xFF      # This instruction should be skipped if branch taken
LABEL1:
    ADDI  x8, x0, 42        # x8 = 42
    JAL   x9, LABEL2        # Jump to LABEL2, x9 = return address
    ADDI  x10, x0, 99       # Should be skipped due to jump
LABEL2:
    ADDI  x11, x0, 123      # x11 = 123 (confirm jump worked)

# ======================================
    MACHINE CODE OF ABOVE PROGRAM
# ======================================
000100B7
00500113
00A00193
00310233
402182B3
0040A023
0000A303
00620463
0FF00393
02A00413
008004EF
06300513
07B00593