.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:

    # Prologue
    li t0, 5
    bne a0, t0, command_error

    addi sp, sp, -52
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)
    sw s11, 48(sp)

    mv s0, a0           # argc
    mv s1, a1           # argv
    mv s2, a2           # silent mode
    
    # -------------- Read pretrained m0 ---------------
    li a0, 8
    jal malloc
    beq a0, x0, malloc_error
    mv s8, a0           # save rows/cols blocks for m0
    
    mv a1, s8
    addi a2, s8, 4
    lw a0, 4(s1)        # argv[1] = m0 filepath
    jal read_matrix

    mv s3, a0           # m0 data ptr
    lw t0, 0(s8)        # m0 rows
    lw t1, 4(s8)        # m0 columns
    addi sp, sp, -8
    sw t0, 0(sp)        # [sp+16]: m0 rows
    sw t1, 4(sp)        # [sp+20]: mo cols


    # -------------- Read pretrained m1 --------------
    li a0, 8
    jal malloc
    beq a0, x0, malloc_error
    mv s9, a0           # save rows/cols blocks for m1
    
    mv a1, s9
    addi a2, s9, 4
    lw a0, 8(s1)        # argv[2] = m1 filepath
    jal read_matrix

    mv s4, a0           # m1 data ptr
    lw t2, 0(s9)        # m1 rows
    lw t3, 4(s9)        # m1 columns
    addi sp, sp, -8
    sw t2, 0(sp)        # [sp+8]: m1 rows
    sw t3, 4(sp)        # [sp+12]: m1 cols

    # -------------- Read input matrix --------------
    li a0, 8
    jal malloc
    beq a0, x0, malloc_error
    mv s10, a0          # save rows/cols blocks for input
    
    mv a1, s10
    addi a2, s10, 4
    lw a0, 12(s1)       # argv[3] = input filepath
    jal read_matrix

    mv s5, a0           # input data ptr
    lw t4, 0(s10)        # input rows
    lw t5, 4(s10)        # input columns
    addi sp, sp, -8
    sw t4, 0(sp)        # [sp+0]: input rows
    sw t5, 4(sp)        # [sp+4]: input cols

    # ------------- h = matmul(m0, input) -----------
    lw t0, 16(sp)       # m0 rows
    lw t1, 4(sp)        # input colus
    mul t0, t0, t1      # items(h)
    slli t0, t0, 2      # bytes(h)
    mv a0, t0
    jal malloc
    beq a0, x0, malloc_error
    mv a6, a0           # dest ptr(h)
    
    addi sp, sp, -4
    sw a0, 0(sp)

    lw a1, 20(sp)       # m0 rows
    lw a2, 24(sp)       # m0 cols
    lw a4, 4(sp)        # input rows
    lw a5, 8(sp)        # input columns
    mv a0, s3           # m0 ptr
    mv a3, s5           # input ptr
    jal matmul
    
    lw a0, 0(sp)
    addi sp, sp, 4
    mv s6, a0           # s6 = h

    # ------------ h = relu(h) (in-place) ------------
    lw t0, 16(sp)       # h rows = m0 rows
    lw t1, 4(sp)        # h cols = input cols
    mul t0, t0, t1      # items(h)
    mv a0, s6           # ptr(h)
    mv a1, t0           # len(h)
    jal relu
    mv s6, a0           # s6 = h = relu(h)
    mv s11, s6          # keep h in s11 for later free


    # ------------ o = matmul(m1, h) -----------------
    # allocate o
    lw t0, 8(sp)        # m1 rows => o rows
    lw t1, 4(sp)        # h cols  => o cols (same as input cols)
    mul t0, t0, t1
    slli t0, t0, 2
    mv a0, t0
    jal malloc
    beq a0, x0, malloc_error
    mv a6, a0           # dest o

    addi sp, sp, -4
    sw a0, 0(sp)

    lw a1, 12(sp)        # m1 rows
    lw a2, 16(sp)       # m1 cols
    lw a4, 20(sp)       # h rows
    lw a5, 8(sp)        # h cols
    mv a0, s4           # m1 ptr
    mv a3, s11          # h pointer
    jal matmul

    lw a0, 0(sp)
    addi sp, sp, 4
    mv s6, a0           # s6 = o = matmul(m1, h)

    # ----------- Write output matrix o --------------
    lw a0, 16(s1)       # argv[4] = output filepath
    mv a1, s6           # a1 = o matrix ptr
    lw a2, 8(sp)        # a2 = o rows = m1 rows
    lw a3, 4(sp)        # a3 = o cols = h cols = input cols
    jal write_matrix

    # ----------- Compute and return argmax(o) --------
    lw t0, 8(sp)        # t0 = o rows
    lw t1, 4(sp)        # t1 = o cols
    mul t0, t0, t1      # t0 = items(o)
    mv a0, s6
    mv a1, t0
    jal argmax
    mv s7, a0           # save classification result

    # ------- If enabled, print argmax(o) and newline ---
    bne s2, x0, skip_print

do_print:
    mv a0, s7
    jal print_int
    li a0, 10
    jal print_char

skip_print:
    # Free all allocated memory
    mv a0, s6           # free o
    jal free
    mv a0, s11          # free h        
    jal free
    mv a0, s5           # free input matrix
    jal free
    mv a0, s4           # free m1 matrix
    jal free
    mv a0, s3           # free m0 matrix
    jal free

    # Free the malloc'ed row/col blocks
    mv a0, s10
    jal free
    mv a0, s9
    jal free
    mv a0, s8
    jal free

    # Epilogue
    mv a0, s7           # return value
    addi sp, sp, 24     # restore sp pointer
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    lw s11, 48(sp)
    addi sp, sp, 52 

    jr ra

malloc_error:
    li a0, 26
    j exit

command_error:
    li a0, 31
    j exit