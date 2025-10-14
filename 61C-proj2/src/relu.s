.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    ebreak
    # Prologue
    addi t0, a1, -1
    mv t1, x0
    blt t0, x0, exit_code36

loop_start:
    blt t0, x0, loop_end

    slli t2, t1, 2
    add t2, t2, a0
    lw t3, 0(t2)

    addi t1, t1, 1
    addi t0, t0, -1
    bge t3, x0, loop_start


loop_continue:
    sw x0 0(t2)
    j loop_start



loop_end:
    # Epilogue

    jr ra

exit_code36:
    li a0, 36
    j exit
