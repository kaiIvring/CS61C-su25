.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    li t0, 1
    blt a2, t0, exit_code36
    blt a3, t0, exit_code37
    blt a4, t0, exit_code37

    li t1, 0        # array0 index
    li t2, 0        # array1 index
    li t6, 0        # result


loop_start:
    blt a2, t0, loop_end

    slli t3, t1, 2
    add t3, a0, t3
    lw t4, 0(t3)    # t4 = arr0[t1]

    slli t3, t2, 2
    add t3, a1, t3
    lw t5, 0(t3)    # t5 = arr0[t2]

    mul t5, t4, t5
    add t6, t6, t5

    add t1, t1, a3
    add t2, t2, a4
    addi a2, a2, -1

    j loop_start

loop_end:
    # Epilogue
    mv a0, t6
    jr ra


exit_code36:
    li a0, 36
    j exit

exit_code37:
    li a0, 37
    j exit