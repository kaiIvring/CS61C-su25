addi t0, x0, 200
addi t1, x0, 1024

sw t1, 0(t0)
sb t1, 5(t0)
sh t1, 9(t0)

lw s0, 0(t0)
lb s1, 9(t0)
lh t2, 9(t0)
