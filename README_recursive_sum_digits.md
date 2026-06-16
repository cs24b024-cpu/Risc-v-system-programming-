# Recursive Sum of Digits in RISC-V Assembly

## Overview

This project implements the **recursive sum of digits algorithm** using **RISC-V Assembly Language**.

The program demonstrates how recursion works at the assembly level by manually managing stack frames, preserving return addresses, and tracking stack usage during recursive calls.

---

## Features

- Recursive function implementation in RISC-V
- Manual stack frame management
- Stack pointer tracking
- Base case handling
- Quotient and remainder computation
- Stack usage analysis

---

## Problem Statement

Given an integer `N`, compute the sum of its digits recursively.

### Example

```text
Input  : 12345
Output : 15
```

Explanation:

```text
1 + 2 + 3 + 4 + 5 = 15
```

---

## Concepts Used

- Recursion in Assembly
- Function Calls using `jal`
- Return using `jr ra`
- Stack Frame Allocation
- Stack Pointer Management
- Register Preservation
- Division and Modulus Operations
- Base Case Handling

---

## File Information

```text
File Name : recursive_sum_digits.s
Language  : RISC-V Assembly
```

---

## Program Structure

### Data Section

Stores:

- Input number
- Initial stack pointer
- Minimum stack pointer reached

```assembly
N:          .word 12345
initial_sp: .word 0
min_sp:     .word 0
```

---

## Main Function

The `main` function:

1. Loads the input number
2. Stores the initial stack pointer
3. Calls the recursive function
4. Computes total stack usage
5. Terminates the program

---

## Recursive Function: `sumDigits`

### Base Case

If the number is less than 10:

```assembly
blt a0, t0, base_case
```

The function directly returns the number.

---

### Recursive Case

The function:

1. Saves registers on stack
2. Divides number by 10
3. Calls itself recursively
4. Adds current digit to recursive result
5. Restores stack frame
6. Returns result

---

## Stack Frame Layout

```text
0(sp) -> original input number
4(sp) -> return address (ra)
```

Each recursive call allocates 8 bytes on stack.

---

## Stack Usage Tracking

The program tracks:

- Initial stack pointer
- Lowest stack pointer reached

Final stack usage is computed as:

```text
stack_usage = initial_sp - min_sp
```

The total stack usage is returned in register `a1`.

---

## Registers Used

| Register | Purpose |
|---|---|
| `a0` | Function argument / result |
| `a1` | Stack usage output |
| `sp` | Stack pointer |
| `ra` | Return address |
| `t0-t3` | Temporary calculations |

---

## Expected Output

After execution:

```text
a0 = Sum of digits
a1 = Total stack usage in bytes
```

For input `12345`:

```text
a0 = 15
```

---

## Time Complexity

```text
O(d)
```

Where `d` is the number of digits.

---

## Space Complexity

```text
O(d)
```

Due to recursive stack calls.

---

## How to Run

### Using RARS Simulator

1. Open RARS
2. Load the assembly file
3. Assemble the code
4. Run the program
5. Observe register values

---

## Learning Outcomes

This project helps in understanding:

- How recursion works internally
- Stack memory organization
- Function call mechanisms in Assembly
- Register preservation
- Low-level execution flow

---

## Applications

- Embedded Systems
- Compiler Design
- Operating Systems
- Low-Level Programming
- Processor Architecture Learning

---

## Author

**Priscilla**  
RISC-V Assembly Language Lab  
June 2026
