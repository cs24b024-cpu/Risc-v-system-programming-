# RISC-V Low-Level Systems and Architecture Portfolio

This repository contains a comprehensive portfolio of low-level RISC-V assembly programs. These projects explore core architectural patterns in the RISC-V ISA, focusing on multi-level privilege mode transitions, custom trap and interrupt vector routing, virtual memory configurations via the 3-level Sv39 page-walk algorithm, memory-isolated exception handling, and stack frame telemetry.

---

## 🛠️ Repository File Inventory

The portfolio consists of the following production-ready RISC-V assembly files:
1. **`pagefault handling.s`**: Demonstrates Sv39 virtual translation setup coupled with an explicit Machine-mode handler processing dynamic instruction and data page faults.
2. **`interupt.s`**: Implements an exception monitoring harness that catches illegal instructions, software breakpoints, misaligned memory targets, and system environment calls via custom vectoring.
3. **`privelege modes transition.S`**: Orchestrates state-driven horizontal and vertical trap routing across all three privilege rings (Machine $\rightarrow$ Supervisor $\rightarrow$ User) utilizing hardware delegation registers.
4. **`pagehandling and satp memory.s`**: Configures an isolated 3-level Sv39 hierarchical page table mapping in Supervisor mode, validates it via TLB invalidation, and hands off execution to an explicit User-mode sandboxed text frame.
5. **`Bubblesort.s`**: An optimized algorithmic implementation executing direct word-boundary vector sorting on registers using conditional loops and physical swapping.
6. **`sum of digits.s`**: Uses mathematical division recursion to compute data processing while monitoring absolute hardware stack frame depth via high-water baseline tracking registers.

---

## 📂 Deep-Dive Technical Breakdowns

### 1. Advanced Sv39 Page Fault Interception (`pagefault handling.s`)
* **Core Concepts**: `satp` initialization, Sv39 multi-level translation, `mcause` routing, instruction/data page faults.
* **Architecture Setup**:
  * The code structures a multi-level page hierarchy starting at root base address `0x81000000`.
  * Configures the system trap pointer `mtvec` to target `page_fault_handler` globally.
  * Transitions privilege from Machine mode to Supervisor mode using `mret`, where it sets up the `satp` registration mask (`0x8000000000081000`) enabling Mode 8 (Sv39).
* **Trap Resolution Flow**:
  * **Instruction Page Fault (`mcause == 12`)**: Redirects control to `inst_fault`, executing a dedicated word-aligned recovery loop (`copy_loop`) that moves memory contexts from `0x80001000` out to safe landing targets at `0x80003000`.
  * **Load/Store Data Page Fault (`mcause == 15`)**: Redirects to `data_fault`, refreshing target reference configurations into register `t3` before yielding execution back via `mret`.

### 2. Micro-Kernel Privilege Escalation (`privelege modes transition.S`)
* **Core Concepts**: Hardware exception delegation (`medeleg`), state token control loops, custom `ecall` intercept routing.
* **Architecture Setup**:
  * Configures the Machine Exception Delegation Register (`medeleg`) by masking bit 8 (`li t0, (1 << 8); csrw medeleg, t0`), forcing User-mode environment calls to bypass Machine mode and trap directly into Supervisor mode (`strap_handler`).
* **Execution State Flow Trace**:

| Operational Stage | Active Privilege Ring | Applied Architectural Logic | Register `a1` | Register `a2` | Control State (`a0`) |
| :--- | :---: | :--- | :---: | :---: | :---: |
| **`ucode`** | User (`U`) | Memory Initialization (`val1`, `val2`) | `5` | `3` | `0` |
| **`strap_handler`** | Supervisor (`S`) | Catches delegated User `ecall`. State `a0==0` routes to `scode`. | `5` | `3` | `0` |
| **`ucode1`** | User (`U`) | Computes addition (`a1 = a1 + a2`); toggles state flag. | **`8`** | `3` | **`1`** |
| **`strap_handler`** | Supervisor (`S`) | Catches `ecall`. State `a0==1` forces elevation upward via custom `ecall`. | `8` | `3` | `1` |
| **`mtrap_handler`** | Machine (`M`) | Processes structural computation (`a1 = a1 * a2`); clears state token. | **`24`** | `3` | **`0`** |

### 3. Hierarchical Sv39 Virtual Translation Engine (`pagehandling and satp memory.s`)
* **Core Concepts**: Physical Memory Protection (`PMP`), Radix Page-Walk hierarchy, Translation Lookaside Buffer (TLB) synchronization.
* **Architecture Setup**:
  * Grants raw platform memory rights across all pages using Physical Memory Protection registers (`pmpaddr0` / `pmpcfg0`).
  * Constructs an explicit 3-level radix hierarchical translation network starting at Level 1 (`0x8F003000`) mapping down through structural memory blocks up to Leaf entries at Level 3 (`0x8F006000`).
* **Page Mapping Table Topology**:
  * **Level 1 (Root Table @ `0x8F003000`)**: Maps pointer index 0 to target descriptor table at physical base `0x8F004000`.
  * **Level 2 (Middle Table @ `0x8F004000`)**: Branches pointer paths directly down to lower physical pages `0x8F005000` and `0x8F007000`.
  * **Level 3 (Leaf Table @ `0x8F005000` / `0x8F006000`)**: Constructs isolated physical frames enforcing specific permissions:
    * Frame base `0x8F001000` mapped with flags `0xDB` (Valid, Readable, Writable, Executable, User-accessible, Accessed, Dirty).
    * Frame base `0x8F002000` mapped with flags `0xD7` (Valid, Readable, Writable, User-accessible, Accessed, Dirty).
  * **Translation Activation**: Compiles a 64-bit translation mask (`8 << 60`) to enable Sv39 mode, links the root page frame pointer, writes the result to the `satp` CSR, and flushes hardware caches via `sfence.vma zero, zero` to enforce the new memory mapping.

### 4. Bare-Metal Interrupt Monitor and Handler (`interupt.s`)
* **Core Concepts**: Core trap vector tracking, exception identifier matching, program counter forward-stepping.
* **Architecture Setup**:
  * Allocates static stack environments (`_stack_low` / `_stack_top`) and sets up raw trap boundaries by assigning `trap_handler` directly into the `mtvec` CSR.
* **Exception Mapping Actions**:
  * The code features a user space (`ucode`) structured to purposefully trip exceptions, which are decoded by checking `mcause` against the following hardware parameters:
    * `mcause = 2` (Illegal Instruction): Intercepts the illegal `.word 0x00000000` signature.
    * `mcause = 3` (Breakpoint Fault): Catches standard software debugging `ebreak` assertions.
    * `mcause = 4` (Misaligned Address): Traps invalid unaligned storage requests, storing tracking footprints inside `0(sp)`.
    * `mcause = 5` (Load Access Fault): Catches memory privilege check violations and backs up tracking metrics across stack boundaries.
    * `mcause = 8` (Environment Call): Handles software execution system calls, outputting status flags into register `a0` (`0xFEED`).
  * All active paths parse the trapping context from `mepc`, append 4 bytes to clear the faulting instruction width (`addi t1, t1, 4`), write it back to `mepc`, and execute `mret` to continue execution smoothly.

### 5. Recursive Digit Summer with Stack Telemetry (`sum of digits.s`)
* **Core Concepts**: Subroutine tracking layout, ABI frame management, stack usage tracking.
* **Architecture Setup**:
  * Implements a recursive algorithm calculating base-10 digit summation alongside runtime monitoring tracking metrics.
* **Stack Telemetry Mechanism**:
  * Captures the initial stack state baseline position inside variable tracking registers (`initial_sp`).
  * Throughout the recursive execution paths (`sumDigits`), the application evaluates the real-time stack assignment register (`sp`) against a tracking register (`min_sp`).
  * If the stack register sinks beneath the tracked watermark (`blt sp, t1, update_min`), the metric updates immediately.
  * Upon hitting the base boundary, the final calculation unrolls, computing the total structural stack memory footprint: `stack_usage = initial_sp - min_sp`.

### 6. Array Sorting Optimization Engine (`Bubblesort.s`)
* **Core Concepts**: Register offsetting, pointer tracking adjustments, comparison loops.
* **Architecture Setup**:
  * Provides optimized sorting capabilities across continuous 32-bit signed data words.
  * Employs structured register arithmetic loops (`rowloop` and `colloop`).
  * Shifts counter values via logical left shifts (`slli t6, t4, 2`) to align index indices with structural word memory boundaries, using data swaps to order the vector elements.

---

## 🛠️ Compilation and Linker Guidelines

To assemble and link these bare-metal binaries using a 64-bit cross-compilation toolchain (`riscv64-unknown-elf-`), use the commands below:

```bash
# 1. Assemble source scripts into ELF object blocks
riscv64-unknown-elf-as -march=rv64g -mabi=lp64d "pagefault handling.s" -o pagefault_handling.o
riscv64-unknown-elf-as -march=rv64g -mabi=lp64d interupt.s -o interupt.o
riscv64-unknown-elf-as -march=rv64g -mabi=lp64d "privelege modes transition.S" -o privilege_transition.o
riscv64-unknown-elf-as -march=rv64g -mabi=lp64d "pagehandling and satp memory.s" -o pagehandling_satp.o
riscv64-unknown-elf-as -march=rv64g -mabi=lp64d "sum of digits.s" -o sum_of_digits.o
riscv64-unknown-elf-as -march=rv64g -mabi=lp64d Bubblesort.s -o bubblesort.o

# 2. Link object modules targeting physical text base limits (e.g., 0x80000000)
riscv64-unknown-elf-ld -Ttext 0x80000000 pagefault_handling.o -o pagefault_handling.elf
riscv64-unknown-elf-ld -Ttext 0x80000000 interupt.o -o interupt.elf
riscv64-unknown-elf-ld -Ttext 0x80000000 privilege_transition.o -o privilege_transition.elf
riscv64-unknown-elf-ld -Ttext 0x80000000 pagehandling_satp.o -o pagehandling_satp.elf
riscv64-unknown-elf-ld -Ttext 0x80000000 sum_of_digits.o -o sum_of_digits.elf
riscv64-unknown-elf-ld -Ttext 0x80000000 bubblesort.o -o bubblesort.elf
