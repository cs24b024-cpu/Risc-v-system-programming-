# --------------------------------------------------
# Author: Priscilla
# Date: June 2026
#
# Project:
# Recursive Sum of Digits in RISC-V Assembly
#
# Description:
# This program calculates the sum of digits of an
# integer using recursion in RISC-V assembly.
#
# Features:
# - Recursive function calls
# - Manual stack frame management
# - Stack usage tracking
# - Base case handling
#
# Input:
#   N = integer number
#
# Output:
#   a0 = sum of digits
#   a1 = total stack usage in bytes
# --------------------------------------------------

.data

N:          .word 12345      # Input number

initial_sp: .word 0          # Stores initial stack pointer
min_sp:     .word 0          # Stores lowest stack pointer reached


.text
.globl main

# --------------------------------------------------
# Main Function
# --------------------------------------------------

main:

    # Load input number into a0
    la t0, N
    lw a0, 0(t0)

    # Save initial stack pointer
    mv t1, sp

    la t2, initial_sp
    sw t1, 0(t2)

    # Initialize minimum stack pointer
    la t3, min_sp
    sw t1, 0(t3)

    # Call recursive function
    jal ra, sumDigits

    # --------------------------------------------------
    # Compute total stack usage
    # stack_usage = initial_sp - min_sp
    # --------------------------------------------------

    la t0, initial_sp
    lw t1, 0(t0)

    la t2, min_sp
    lw t3, 0(t2)

    sub a1, t1, t3

    # --------------------------------------------------
    # Program End
    # a0 = sum of digits
    # a1 = stack usage
    # --------------------------------------------------

    li a7, 10
    ecall


# --------------------------------------------------
# Function: sumDigits
#
# Input:
#   a0 = integer N
#
# Output:
#   a0 = sum of digits of N
# --------------------------------------------------

sumDigits:

    # --------------------------------------------------
    # Base Case:
    # If N < 10, return N
    # --------------------------------------------------

    li t0, 10
    blt a0, t0, base_case


    # --------------------------------------------------
    # Allocate stack frame
    # Stack Frame Layout:
    #
    #   0(sp) -> original a0
    #   4(sp) -> return address (ra)
    # --------------------------------------------------

    addi sp, sp, -8

    sw a0, 0(sp)
    sw ra, 4(sp)


    # --------------------------------------------------
    # Update minimum stack pointer
    # --------------------------------------------------

    la t0, min_sp
    lw t1, 0(t0)

    blt sp, t1, update_min
    j continue_execution

update_min:
    sw sp, 0(t0)

continue_execution:

    # --------------------------------------------------
    # Compute:
    # quotient  = N / 10
    # remainder = N % 10
    # --------------------------------------------------

    li t0, 10

    div t1, a0, t0
    rem t2, a0, t0


    # --------------------------------------------------
    # Recursive call with quotient
    # --------------------------------------------------

    mv a0, t1

    jal ra, sumDigits


    # --------------------------------------------------
    # Restore stack frame
    # --------------------------------------------------

    lw t3, 0(sp)
    lw ra, 4(sp)

    addi sp, sp, 8


    # --------------------------------------------------
    # Add current digit to recursive result
    # --------------------------------------------------

    li t0, 10
    rem t2, t3, t0

    add a0, a0, t2


    # Return to caller
    jr ra


# --------------------------------------------------
# Base Case Return
# --------------------------------------------------

base_case:
    jr ra