.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2

    # open file
    mv a0, s0           # a0: pointer to the filename string
    li a1, 0            # a1 = 0 read only
    jal fopen
    li t0, -1
    beq a0, t0, open_error
    mv s3, a0           # save the file descriptor

    # read matrix rows and columns
    addi sp, sp, -8     # alloc 8 bytes in the stack for fread
    mv a0, s3           # a0: the file descriptor
    mv a1, sp           # a1 = sp
    li a2, 8            # a2 = 8 bytes
    jal fread
    li t0, 8
    bne a0, t0, read_error

    lw t1, 0(sp)        # get the rows and the columns of the matrix
    lw t2, 4(sp)
    sw t1, 0(s1)
    sw t2, 0(s2)
    addi sp, sp, 8

    # malloc memory for the matrix
    mul s4, t1, t2      # s4: how many items the matrix has
    slli t3, s4, 2
    mv a0, t3
    jal malloc
    beq a0, x0, malloc_error
    mv s5, a0           # save the allocated memory pointer

    # read matrix data
    mv a0, s3           # a0: the file descriptor
    mv a1, s5           # read the matrix and directly send it to the right place
    slli a2, s4, 2
    jal fread
    slli t3, s4, 2
    bne a0, t3, read_error

    # close the file
    mv a0, s3           # a0: the file descriptor 
    jal fclose
    bne a0, x0, close_error

    # Epilogue
    mv a0, s5
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28

    jr ra

malloc_error:
    li a0, 26
    j exit

open_error:
    li a0, 27
    j exit

close_error:
    li a0, 28
    j exit

read_error:
    li a0, 29
    j exit