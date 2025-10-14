.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
    # Error checks
    li t0, 1
    blt a1, t0, exit_code38
    blt a2, t0, exit_code38
    blt a4, t0, exit_code38
    blt a5, t0, exit_code38
    bne a2, a4, exit_code38

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    li s1, 0        # outer loop counter
    mv s2, a0       # m0 pointer
    mv s3, a3       # m1 pointer
    mv s4, a6       # result matrix pointer
    li s5, 0        # result index helper

outer_loop_start:
    bge s1, a1, outer_loop_end
    li s0, 0        # reset inner loop counter
    mv s3, a3       # reset m2 counter

inner_loop_start:
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)

    mv a0, s2       # a0 = a0
    mv a1, s3       # a1 = a3
                    # a2 = a2
    li a3, 1        # a3 = 1
    mv a4, a5       # a4 = a5

    jal dot
    mv t0, a0       # t0 = a0 = result

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28

    sw t0, 0(s4)

    addi s3, s3, 4  # pointer index + 1
    addi s0, s0, 1  # inner counter + 1

    addi s5, s5, 1  # result index + 1
    slli t0, s5, 2
    add s4, a6, t0

    blt s0, a5, inner_loop_start

inner_loop_end:
    slli t0, a2, 2
    add s2, s2, t0
    addi s1, s1, 1

    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw s5, 24(sp)
    lw s4, 20(sp)
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 28
    jr ra

exit_code38:
    li a0, 38
    j exit