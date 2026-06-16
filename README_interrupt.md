# Interrupt and Exception Handling in RISC-V Assembly

This lab demonstrates the implementation of **trap handling and exception management** using **RISC-V Assembly Language**.  
The program configures a trap handler, switches execution to user mode, and handles different exceptions such as illegal instructions, breakpoints, misaligned memory access, load access faults, and system calls.

---

## Objective

- Understand interrupt and exception handling in RISC-V
- Learn how trap handlers work
- Practice CSR (Control and Status Register) operations
- Understand machine mode to user mode transition
- Learn exception identification using `mcause`

---

## Concepts Covered

- Trap Handling
- Exception Handling
- Machine Mode and User Mode
- CSR Instructions
- Stack Initialization
- Interrupt Vector Table
- Memory Access Faults
- Breakpoint Handling
- System Calls (`ecall`)
- Illegal Instruction Handling

---

## File Information

```text
File Name : interupt.s
Language  : RISC-V Assembly
```

---

## Exceptions Handled

| Exception | mcause Value |
|---|---|
| Illegal Instruction | 2 |
| Breakpoint | 3 |
| Misaligned Load | 4 |
| Load Access Fault | 5 |
| Environment Call (`ecall`) | 8 |

---

## Program Flow

1. Initialize stack pointer
2. Configure trap handler using `mtvec`
3. Set machine status register
4. Switch execution to user code using `mret`
5. Trigger different exceptions intentionally
6. Trap handler checks `mcause`
7. Control jumps to corresponding exception handler
8. Exception is handled and execution resumes

---

## Trap Handler

The trap handler identifies the exception source using the `mcause` register.

```assembly
csrr t2, mcause
```

Based on the exception value, control is transferred to the appropriate handler.

---

## Exception Handling

### Illegal Instruction
Handles invalid instruction execution.

### Breakpoint
Handles `ebreak` instruction.

### Misaligned Access
Handles invalid memory alignment access.

### Load Access Fault
Handles invalid memory access operations.

### ECALL
Handles environment/system calls.

---

## Registers Used

| Register | Purpose |
|---|---|
| `sp` | Stack pointer |
| `t0-t2` | Temporary registers |
| `s1-s5` | Exception code comparison |
| `s9-s11` | Store fault-related values |
| `a0` | Return/debug value |

---

## How to Run

### Using Spike

1. Open the assembly file
2. Assemble the program
3. Run the code
4. Observe trap handling behavior and register changes

---

## Learning Outcomes

After completing this lab, one can understand:

- How exceptions are generated in RISC-V
- How trap handlers work internally
- Usage of CSRs like `mcause`, `mepc`, and `mtvec`
- Low-level exception management
- Mode switching in processors

---

## Applications

- Operating Systems
- Embedded Systems
- Processor Design
- Low-Level System Programming
- Kernel Development

---

## Author

Submitted as part of the **RISC-V Assembly Language Lab**.
