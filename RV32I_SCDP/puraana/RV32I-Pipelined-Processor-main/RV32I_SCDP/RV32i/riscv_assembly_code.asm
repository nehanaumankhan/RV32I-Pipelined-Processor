# U-TYPE TESTS
                lui   x1, 0x0
                auipc x2, 0
# I-TYPE TESTS
                addi  x3, x0, 5
                addi  x4, x0, 10
                sltiu x5, x3, 9
                xori  x6, x4, 3
# R-TYPE TESTS
                add   x7, x3, x5
                and   x8, x4, x6
                or    x9, x3, x5
                xor   x10, x3, x4
# STORE / LOAD TESTS
                sw    x7, 0(x0)
                sb    x8, 4(x0)
                sh    x9, 8(x0)

                lw    x11, 0(x0)
                lbu   x12, 4(x0)
                lhu   x13, 8(x0)
# BRANCH TESTS 
                beq   x11, x3, skip1      # NOT taken
                bne   x11, x3, skip1      # TAKEN
                addi x0, x0, 0

skip1:          blt   x3, x4, skip2       # TAKEN
                addi x0, x0, 0

skip2:          bge   x4, x3, skip3       # TAKEN
                addi x0, x0, 0

skip3:          bltu  x3, x4, skip4       # TAKEN
                addi x0, x0, 0

skip4:          bgeu  x4, x3, skip5       # TAKEN
                addi x0, x0, 0
# JUMP TESTS — OFFSETS FIXED
skip5:          jal   x14, jump_target
                addi  x15, x0, 9          # should be SKIPPED
jump_target:    addi  x16, x14, 1         # returnPC + 1
                jalr  x0, x16, 0          # return
# FINAL HALT LOOP
halt:           jal x0, halt              # infinite loop
