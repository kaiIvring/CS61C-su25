addi s0, x0, 5
addi s1, x0, 7
addi t0, x0, 5
addi t1, x0, 8
addi t2, x0, -1

L1:  bne s0, s1, L6
L2:  bge s1, s0, L5
L3:  blt s0, t2, L6 
L4:  bltu s0, t2, L7
L5:  bgeu t2, s0, L3
L6:  beq s0, t0, L2

L7:  bne s0, t0, L1