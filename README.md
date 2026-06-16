# Bubble Sort in RISC-V Assembly

This lab demonstrates the implementation of the **Bubble Sort algorithm** using **RISC-V Assembly Language**.  
The program sorts an array of integers in ascending order using nested loops and swap operations.

---

## Objective

- Understand array handling in RISC-V Assembly
- Learn loop implementation using branch instructions
- Practice memory access using load/store operations
- Implement a basic sorting algorithm at low level

---

## Algorithm Used

### Bubble Sort
Bubble Sort repeatedly compares adjacent elements and swaps them if they are in the wrong order.

Example:

```text
Input  : 5 2 9 1 3 6
Output : 1 2 3 5 6 9
```

---

## Concepts Covered

- Arrays in Assembly
- Nested Loops
- Conditional Branching
- Register Usage
- Memory Addressing
- Swapping Values
- Sorting Algorithms

---

## File Information

```text
File Name : BubbleSort.s
Language  : RISC-V Assembly
```

---

## Registers Used

| Register | Purpose |
|---|---|
| `t0` | Base address of array |
| `t1` | Number of passes |
| `t2` | Outer loop counter |
| `t4` | Inner loop counter |
| `t5` | Remaining comparisons |
| `t6` | Address of current element |
| `a1` | Current element value |
| `a2` | Next element value |
| `s0` | Address of next element |

---

## Program Flow

1. Load array base address
2. Run outer loop for passes
3. Run inner loop for comparisons
4. Compare adjacent elements
5. Swap if elements are not in order
6. Repeat until array becomes sorted

---

## Time Complexity

```text
Best Case    : O(n)
Average Case : O(n²)
Worst Case   : O(n²)
```

---

## Space Complexity

```text
O(1)
```

---

## How to Run

### Using RARS Simulator

1. Open RARS
2. Load `BubbleSort.s`
3. Assemble the program
4. Run the code
5. Observe the sorted array in memory

---

## Learning Outcomes

After completing this lab, one can understand:

- How sorting works internally
- How loops are implemented in Assembly
- How memory is accessed using addresses
- Basic low-level programming in RISC-V

---

## Author

Submitted as part of the **RISC-V Assembly Language Lab**.
