.section .text
.global main

main:
    li t1, 1
    slli t1, t1, 11
    csrs mstatus, t1
    
    la t4, supervisor
    csrrw zero, mepc, t4
    
    la t5, page_fault_handler
    csrw mtvec, t5
   
    mret

supervisor:

    li a0,0x81000000
    li a1, 0x82000
    slli a1, a1, 0xa
    ori a1, a1, 0x01
    sd a1, 16(a0)

    li a1, 0x82001
    slli a1, a1, 0xa
    ori a1, a1, 0x01
    sd a1, 0(a0)

    li a0,0x82000000
    li a1, 0x83000
    slli a1, a1, 0xa
    ori a1, a1, 0x01
    sd a1, 0(a0)

    li a0,0x83000000
    li a1, 0x80000
    slli a1, a1, 0xa
    ori a1, a1, 0xef
    sd a1, 0(a0)

    li a1, 0x80001
    slli a1, a1, 0xa
    ori a1, a1, 0xef
    sd a1, 8(a0)

    li a0,0x82001000
    li a1, 0x83001
    slli a1, a1, 0xa
    ori a1, a1, 0x01
    sd a1, 0(a0)

    li a0,0x83001000
    li a1, 0x80001
    slli a1, a1, 0xa
    ori a1, a1, 0xfb
    sd a1, 0(a0)

    li a1, 0x80002
    slli a1, a1, 0xa
    ori a1, a1, 0xf7
    sd a1, 8(a0)

    li t1, 0
    slli t1, t1, 8
    csrs sstatus, t1

    la t1, satp_config 
    ld t2, 0(t1)
    sfence.vma zero, zero
    csrrw zero, satp, t2
    sfence.vma zero, zero

    li t4, 0
    csrrw zero, sepc, t4
    
    sret

.align 4
page_fault_handler:
    csrr t0, mcause
    csrr t1, mtval

    li t2, 12
    beq t0, t2, inst_fault

    li t2, 15
    beq t0, t2, data_fault

    mret

inst_fault:
    li t3, 0x80001000
    li t4, 0x80003000

copy_loop:
    lw t5, 0(t3)
    sw t5, 0(t4)
    addi t3, t3, 4
    addi t4, t4, 4
    blt t3, t3, copy_loop

    mret

data_fault:
    li t3, 0x80002000
    mret

.align 12
user_code:
    la t1,var_count
    lw t2, 0(t1)
    addi t2, t2, 1
    sw t2, 0(t1)

    la t5, code_jump_position
    lw t3, 0(t5)
    li t4, 0x2000
    add t3, t3, t4
    sw t3, 0(t5)
    
    jalr x0, t3

.data
.align 12
var_count:  .word  0
code_jump_position: .word 0x0000

.align 8
satp_config: .dword 0x8000000000081000
