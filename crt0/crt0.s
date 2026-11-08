.section .start
.global _crt0

_crt0:
    la sp, _stack_top
    la t0, _data_lma
    la t1, _data_vma
    la t2, _data_size
    beq t2, zero, main

load_data:
    add t0, t0, t3
    add t1, t1, t3
    lw s1, 0(t0)
    sw s1, 0(t1)
    addi t3, t3, 4
    blt t3, t2, load_data
    j main
