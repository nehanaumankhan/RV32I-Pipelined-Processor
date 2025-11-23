    ########################################
    # Main Program
    ########################################
    LUI   x3, 0x00010          # x3 = 0x00010000 (memory base)
    ADDI  x10, x0, 5           # a0 = 5 (N = 5)
    JAL   x1, SUM_FUNC         # call SUM_FUNC
    SW    x10, 0(x3)           # store result = 15
    ADDI  x8, x0, 99           # marker instruction

    ########################################
    # Function: SUM_FUNC
    # Computes sum of numbers 1..N
    ########################################
SUM_FUNC:
    ADDI  x5, x0, 0            # t0 = 0 (sum)
    ADDI  x6, x0, 1            # t1 = 1 (counter)

LOOP:
    BLT   x10, x6, DONE        # if (N < i) → exit
    ADD   x5, x5, x6           # sum += i
    ADDI  x6, x6, 1            # i++
    JAL   x0, LOOP             # repeat

DONE:
    ADDI  x10, x5, 0           # a0 = sum
    JALR  x0, x12, 0            # return
