.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================

# my first approach

# argmax:
#   ebreak
#    # Prologue
#    addi t0, a1, -1         # t0 = right   
#    blt t0, x0, exit_code36
#    mv t1, x0               # t1 = left
#    mv t5, t1               # t5 = t1(max)
#
# loop_start:
#    bge t1, t0, loop_end
#    slli t2, t1, 2
#    add t2, a0, t2
#    lw t3, 0(t2)            # t3 = array[left]
#
#    slli t2, t0, 2
#    add t2, a0, t2
#    lw t4, 0(t2)            # t4 = array[right]
#    
#    bge t3, t4, loop_continue
#
#   addi t1, t1, 1  # array[left] < array[right], left_index++ 
#    mv t5, t0       # update max index
#    j loop_start
#
# loop_continue:
#   addi t0, t0, -1 # array[left] >= array[right], right_index--
#    mv t5, t1       # update max index
#    j loop_start
#    
#
# loop_end:
#    # Epilogue
#    mv a0, t5
#    jr ra
#
# exit_code36:
#    li a0, 36
#    j exit

# better approach
argmax:
    # 检查数组长度是否 >= 1
    li t0, 1
    blt a1, t0, exit_code36  # 如果 a1 < 1，跳转到错误处理

    # 初始化
    mv t1, x0          # t1 = 当前索引 i = 0
    mv t2, x0          # t2 = 当前最大值索引 max_index = 0
    lw t3, 0(a0)       # t3 = 当前最大值 max_value = arr[0]

loop_start:
    addi t1, t1, 1     # i++
    bge t1, a1, loop_end # 若 i >= 数组长度，结束循环

    # 计算 arr[i] 的地址
    slli t4, t1, 2     # t4 = i * 4
    add t4, a0, t4     # t4 = arr + i*4
    lw t5, 0(t4)       # t5 = arr[i]

    # 比较 arr[i] 和当前最大值
    ble t5, t3, loop_start  # 如果 arr[i] <= max_value，跳过更新
    mv t2, t1          # 更新最大值索引 max_index = i
    mv t3, t5          # 更新最大值 max_value = arr[i]
    j loop_start

loop_end:
    mv a0, t2          # 返回值 = max_index
    jr ra

exit_code36:
    li a0, 36
    j exit

