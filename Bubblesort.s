# Bubble Sort in RISC-V Assembly

```assembly
.data
# Input array
arr: .word 5,2,9,1,3,6

# Array size
n: .word 6

.text
.global main

main:

    # Load base address of array
    la t0, arr

    # Number of passes = n - 1
    li t1, 5

    # Outer loop counter i = 0
    li t2, 0

# -------------------------------------------------
# Outer Loop
# -------------------------------------------------
rowloop:

    # if i >= n-1 -> end
    bge t2, t1, end

    # Inner loop counter j = 0
    li t4, 0

    # Remaining comparisons
    sub t5, t1, t2

# -------------------------------------------------
# Inner Loop
# -------------------------------------------------
colloop:

    # if j >= remaining comparisons
    bge t4, t5, nextloop

    # Calculate address of arr[j]
    slli t6, t4, 2
    add  t6, t6, t0

    # Load arr[j]
    lw a1, 0(t6)

    # Calculate address of arr[j+1]
    addi s0, t4, 1
    slli s0, s0, 2
    add s0, s0, t0

    # Load arr[j+1]
    lw a2, 0(s0)

    # If already sorted, skip swap
    ble a1, a2, out

    # Swap elements
    sw a2, 0(t6)
    sw a1, 0(s0)

out:

    # j++
    addi t4, t4, 1
    j colloop

nextloop:

    # i++
    addi t2, t2, 1
    j rowloop

# -------------------------------------------------
# Program Exit
# -------------------------------------------------
end:
    li a7, 93
    ecall
```
