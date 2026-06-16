.section .text.init
.global _start

_start:
la sp, _stack_top

la t0, trap_handler
csrw mtvec, t0

 csrr t0, mstatus
 li t1, ~(3 << 11)
 and t0, t0, t1
 csrw mstatus, t0


la t0, ucode
csrw mepc, t0
mret

.section .text
.align  4
trap_handler:

csrr t2, mcause
li s1, 2
beq t2, s1, illegal
li s2, 3
beq t2, s2, breakpoint
li s3, 4
beq t2, s3, misalligned
li s4, 5
beq t2, s4, loadaccessfault
li s5, 8
beq t2, s5, ecall
illegal:
csrr s9, mtval
csrr  t1, mepc
addi t1, t1, 4
csrw mepc, t1
j end

misalligned:
sd t0, 0(sp)
csrr s10, mtval
csrr  t1, mepc
addi t1, t1, 4
csrw mepc, t1
j end

loadaccessfault:
sd t0, 8(sp)
sd t0, 16(sp)
csrr s11, mtval
csrr  t1, mepc
addi t1, t1, 4
csrw mepc, t1
j end

ecall:
la a0,  0xFEED
csrr  t1, mepc
addi t1, t1, 4
csrw mepc, t1
j end

breakpoint:
la a0,  0xBEEF
csrr  t1, mepc
addi t1, t1, 4
csrw mepc, t1
j end

end:
mret

ucode:

.word 0x00000000
ebreak
ecall
la t0, _stack_low
addi t0, t0, 1
ld t0, 0(t0)
li t0, 0x0
ld t1, 0(t0)

j loop
loop:

.section .bss
.align 16
_stack_low:
.space 4096
_stack_top:





