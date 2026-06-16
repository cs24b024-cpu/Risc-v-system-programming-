.section .data
val1:   .word 5
val2:   .word 3

.section .text
.global main

# -------------------------------------------------
# MAIN : Start in Machine Mode
# Configure trap handlers and drop to User Mode
# -------------------------------------------------
main:

    # Set machine trap vector
    la t0, mtrap_handler
    csrw mtvec, t0

    # Set supervisor trap vector
    la t0, strap_handler
    csrw stvec, t0

    # Delegate ECALL from user to supervisor
    li t0, (1 << 8)
    csrw medeleg, t0

    # Prepare to jump to user code
    la t0, ucode
    csrw mepc, t0

    # Set MPP = User mode (00)
    csrr t1, mstatus
    li t2, ~(3 << 11)
    and t1, t1, t2
    csrw mstatus, t1

    # initial dispatcher condition
    li a0, 0

    mret


# -------------------------------------------------
# MACHINE TRAP HANDLER
# Executes multiplication worker
# -------------------------------------------------
.align 4
mtrap_handler:

    # a1 = a1 * a2
    mul a1, a1, a2

    # flip control variable
    li a0, 0

    # return to supervisor dispatcher
    la t0, strap_handler
    csrw mepc, t0

    # set MPP = Supervisor
    csrr t1, mstatus
    li t2, ~(3 << 11)
    and t1, t1, t2
    li t2, (1 << 11)
    or t1, t1, t2
    csrw mstatus, t1

    mret


# -------------------------------------------------
# SUPERVISOR CODE
# Used to drop from S → U
# -------------------------------------------------
scode:

    la t0, ucode1
    csrw sepc, t0

    # set SPP = User
    csrr t1, sstatus
    li t2, ~(1 << 8)
    and t1, t1, t2
    csrw sstatus, t1

    sret


# -------------------------------------------------
# SUPERVISOR TRAP HANDLER (Dispatcher)
# -------------------------------------------------
.align 4
strap_handler:

    # check condition
    beqz a0, go_user

    # ascend to machine mode
    ecall

go_user:
    j scode


# -------------------------------------------------
# USER MODE INITIAL CODE
# Loads variables then traps to supervisor
# -------------------------------------------------
ucode:

    la t0, val1
    lw a1, 0(t0)

    la t0, val2
    lw a2, 0(t0)

    ecall


# -------------------------------------------------
# USER MODE WORKER
# Performs addition
# -------------------------------------------------
ucode1:

    add a1, a1, a2

    # flip dispatcher flag
    li a0, 1

    # trap back to supervisor
    ecall