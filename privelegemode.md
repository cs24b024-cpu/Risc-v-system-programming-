# RISC-V Multi-Mode Trap Delegation and Privilege Transition

This repository contains a low-level RISC-V assembly program demonstrating advanced architectural concepts, including **multi-level privilege transitions (Machine $\rightarrow$ Supervisor $\rightarrow$ User)**, **trap delegation configurations**, and **cooperative software dispatching** across execution modes.

The code demonstrates how a RISC-V processor handles environment calls (`ecall`) dynamically using hardware delegation registers (`medeleg`) to distribute tasks dynamically between Supervisor Mode (`S-mode`) and Machine Mode (`M-mode`).

---

## 1. Architectural Flow & Privilege Transitions

The program executes across three distinct RISC-V privilege levels, transitioning deterministically through control state registers (`CSRs`):

1. **Machine Mode (`main`)**:
   * Registers `mtrap_handler` in `mtvec` and `strap_handler` in `stvec`.
   * Sets up execution delegation by routing User-mode environment calls (`ecall` from U-mode) directly to Supervisor mode via the `medeleg` register.
   * Manually clears the `mstatus.MPP` bits to `00` (User Mode) and issues an `mret` to jump directly into the first User-mode payload (`ucode`).

2. **User Mode Initial Payload (`ucode`)**:
   * Loads two static memory inputs (`val1 = 5` and `val2 = 3`) into registers `a1` and `a2`.
   * Triggers an `ecall`. Due to the delegation rule established in `main`, this exception bypasses M-mode and is trapped directly into S-mode.

3. **Supervisor Trap Handler / Dispatcher (`strap_handler` & `scode`)**:
   * Acts as a state-based software dispatcher using register `a0` as a control variable.
   * **First Pass (`a0 == 0`)**: Routes the execution context to `scode`, lowers the privilege level back to User Mode (`sstatus.SPP = 0`), and jumps via `sret` to the second User payload (`ucode1`).
   * **Second Pass (`a0 == 1`)**: Promotes the trap upward by executing a Supervisor-level `ecall`, forcing an explicit elevation into Machine Mode (`mtrap_handler`).

4. **User Mode Worker Payload (`ucode1`)**:
   * Computes an addition operation: `a1 = a1 + a2` ($5 + 3 = 8$).
   * Toggles the dispatcher state flag (`a0 = 1`) to alert the supervisor layer.
   * Invokes an `ecall` to return control to the supervisor.

5. **Machine Mode Trap Handler (`mtrap_handler`)**:
   * Invoked explicitly by the Supervisor's promoted `ecall`.
   * Executes a hardware-level mathematical computation: `a1 = a1 * a2` ($8 \times 3 = 24$).
   * Resets the control flag (`a0 = 0`), forces the return tracking target back onto the supervisor trap vector, updates `mstatus.MPP` to `01` (Supervisor Mode), and yields control via `mret`.

---

## 2. Key Architectural Concepts Demonstrated

* **Trap Delegation (`medeleg`)**: Demonstrates how a microkernel or hypervisor can bypass processing overhead in higher privilege states by delegating specific traps (like Environment Calls from U-mode) directly to a lower supervisor layer.
* **Privilege State Manipulation**: Manual bitmasking of `mstatus.MPP` and `sstatus.SPP` fields to control exactly where the hardware drops when execution states are unrolled via `mret` and `sret`.
* **State-Driven Routing**: Utilizing a volatile CPU register (`a0`) as an asynchronous flag/token to dynamically dictate path execution within isolated trap vector handlers.

---

## 3. Register State Evolution Trace

Below is the conceptual trace of the program's mathematical and control operations across registers `a1`, `a2`, and `a0`:

| Execution Stage | Target Mode | Active Logic / Operation | `a1` State | `a2` State | `a0` State |
| :--- | :---: | :--- | :---: | :---: | :---: |
| **`ucode`** | User | Memory Initialization | `5` | `3` | `0` |
| **`strap_handler`** | Supervisor | Dispatcher Check (`a0 == 0`) $\rightarrow$ Routes to `ucode1` | `5` | `3` | `0` |
| **`ucode1`** | User | Addition (`a1 = a1 + a2`) | **`8`** | `3` | **`1`** |
| **`strap_handler`** | Supervisor | Dispatcher Check (`a0 == 1`) $\rightarrow$ Raises `ecall` | `8` | `3` | `1` |
| **`mtrap_handler`** | Machine | Multiplication (`a1 = a1 * a2`) | **`24`** | `3` | **`0`** |

---

## 4. How to Compile and Simulate

### Compilation (RISC-V GNU Toolchain)
To assemble and link this code into a standard bare-metal 64-bit ELF executable, execute the following commands:

```bash
# Assemble the source file
riscv64-unknown-elf-as -march=rv64g -mabi=lp64d implementation.s -o implementation.o

# Link the object code into an ELF binary executable
riscv64-unknown-elf-ld -Ttext 0x80000000 implementation.o -o implementation.elf