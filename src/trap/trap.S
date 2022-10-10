# the number of bytes of each register
.equ XLENB, 8

# save the value of register a1 to sp+XLENB*a2
.macro SAVE a
    sd x\a, \a*XLENB(sp)
.endm

# load the value in sp+XLENB*a2 to register a1
.macro LOAD a
    ld x\a, \a*XLENB(sp)
.endm

.macro SAVE_ALL
    csrrw sp, sscratch, sp
    bnez sp, trap_from_user
trap_from_kernel:
    csrr sp, sscratch
trap_from_user:
    addi sp, sp, -36*XLENB
    SAVE 1
    SAVE 3
    SAVE 4
    SAVE 5
    SAVE 6
    SAVE 7
    SAVE 8
    SAVE 9
    SAVE 10
    SAVE 11
    SAVE 12
    SAVE 13
    SAVE 14
    SAVE 15
    SAVE 16
    SAVE 17
    SAVE 18
    SAVE 19
    SAVE 20
    SAVE 21
    SAVE 22
    SAVE 23
    SAVE 24
    SAVE 25
    SAVE 26
    SAVE 27
    SAVE 28
    SAVE 29
    SAVE 30
    SAVE 31
    csrrw s0, sscratch, x0
    csrr s1, sstatus
    csrr s2, sepc
    csrr s3, stval
    csrr s4, scause
    sd s0, 2*XLENB(sp)
    sd s1, 32*XLENB(sp)
    sd s2, 33*XLENB(sp)
    sd s3, 34*XLENB(sp)
    sd s4, 35*XLENB(sp)
.endm

.macro RESTORE_ALL
    ld s1, 32*XLENB(sp)
    ld s2, 33*XLENB(sp)
    andi s0, s1, 1 << 8
    bnez s0, _to_kernel
_to_user:
    andi s0, sp, 36*XLENB
    csrw sscratch, s0
_to_kernel:
    csrw sstatus, s1
    csrw sepc, s2
    LOAD 1
    LOAD 3
    LOAD 4
    LOAD 5
    LOAD 6
    LOAD 7
    LOAD 8
    LOAD 9
    LOAD 10
    LOAD 11
    LOAD 12
    LOAD 13
    LOAD 14
    LOAD 15
    LOAD 16
    LOAD 17
    LOAD 18
    LOAD 19
    LOAD 20
    LOAD 21
    LOAD 22
    LOAD 23
    LOAD 24
    LOAD 25
    LOAD 26
    LOAD 27
    LOAD 28
    LOAD 29
    LOAD 30
    LOAD 31
    LOAD 2
.endm

    .section .text
    .globl __alltraps
    .align 4
__alltraps:
    SAVE_ALL
    mv a0, sp
    jal trap_handler

    .globl __trapret
__trapret:
    RESTORE_ALL
    sret