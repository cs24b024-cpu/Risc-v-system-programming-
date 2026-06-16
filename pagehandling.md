# RISC-V Page Fault Handling and Virtual Memory Setup

This repository contains a low-level RISC-V assembly program (`pagefault_handling.s`) designed to demonstrate the configuration of the Sv39 virtual memory system, privilege mode transitions, and Machine-mode (`M-mode`) trap/page-fault handling. 

The program begins execution in Machine mode, transitions down to Supervisor mode (`S-mode`) to construct a multi-level page table hierarchy, activates address translation, and schedules the execution of User-mode (`U-mode`) code.

---

## 1. Architectural Setup & Flow

The code moves through three distinct phases of execution based on RISC-V privilege levels:

1. **Machine Mode (`main`)**:
   * Configures `mstatus.MPP` to `01` (Supervisor mode) so that `mret` drops privilege.
   * Registers `page_fault_handler` into `mtvec` to handle traps/faults globally.
   * Sets `mepc` to the `supervisor` label and executes `mret`.

2. **Supervisor Mode (`supervisor`)**:
   * Dynamically constructs a 3-level **Sv39** page table layout in physical memory.
   * Clears `sstatus.SPP` to `00` (User mode) preparing to drop privilege to User mode.
   * Enforces memory synchronization via `sfence.vma`.
   * Enacts virtual memory by writing the root page table pointer to the `satp` CSR.
   * Sets `sepc` to virtual address `0x0` and executes `sret` to jump to User mode.

3. **User Mode (`user_code` / Virtual Execution)**:
   * Runs under address translation using mapped virtual spaces. 
   * Triggers implicit instruction and data accesses meant to challenge the configured page permissions and cause deliberate page faults.

---

## 2. Page Table Mapping Layout (Sv39)

The script provisions memory structures using Sv39 (39-bit virtual address translation consisting of 3 levels: L2, L1, and L0). The root page table (`satp`) points to physical address **`0x81000000`**.

Below is a map of how the entries are established in the code:

### Level 2 Table (Root at `0x81000000`)
* **Offset `16` (`0x81000010`)**: Points to an L1 Table at PPN `0x82000` (Flags: Valid `0x01`).
* **Offset `0` (`0x81000000`)**: Points to an alternate L1 Table at PPN `0x82001` (Flags: Valid `0x01`).

### Level 1 Tables
* **At `0x82000000`**:
  * Offset `0`: Points to an L0 Table at PPN `0x83000` (Flags: Valid `0x01`).
* **At `0x82001000`**:
  * Offset `0`: Points to an L0 Table at PPN `0x83001` (Flags: Valid `0x01`).

### Level 0 Tables (Leaf Entries)
* **At `0x83000000`**:
  * Offset `0`: Maps to Physical Page `0x80000` (Flags: `0xef` -> V, R, W, X, U).
  * Offset `8`: Maps to Physical Page `0x80001` (Flags: `0xef` -> V, R, W, X, U).
* **At `0x83001000`**:
  * Offset `0`: Maps to Physical Page `0x80001` (Flags: `0xfb` -> Valid, Readable, Executable, User, Accessed, Dirty).
  * Offset `8`: Maps to Physical Page `0x80002` (Flags: `0xf7` -> Valid, Readable, Writable, User, Accessed, Dirty).

---

## 3. Trap and Page Fault Handling

When a violation of permissions or missing page map occurs in Supervisor or User space, the hardware traps into Machine Mode at `page_fault_handler`. The handler evaluates `mcause` to isolate the problem:

* **Instruction Page Fault (`mcause == 12`)**:
  * Branches to `inst_fault`.
  * Executes a software loop (`copy_loop`) migrating an instruction payload block from physical address `0x80001000` to a destination backup/cache area at `0x80003000`.
  * *Note: There is an intentional dead-loop hazard in the source code sequence (`blt t3, t3, copy_loop`) which comparison logic can be modified/fixed if a runtime breakout is required.*
  
* **Load/Store Data Page Fault (`mcause == 15`)**:
  * Branches to `data_fault`.
  * Loads the immediate fault-handling physical reference address `0x80002000` into `t3` before issuing `mret`.

---

## 4. Source Parameters Configurations

At the tail of the program, raw operational data and the static `satp` registration mask are declared:

* **`var_count`**: Active tracking word variable manipulated by the user program state.
* **`code_jump_position`**: Target displacement tracking word used for calculating virtual program-counter branches (`jalr`).
* **`satp_config`**: Contains the quad-word configuration value `0x8000000000081000`. 
  * `Mode = 8` (Sv39 enabled).
  * `ASID = 0`.
  * `PPN = 0x81000` (Base physical page matching `0x81000000`).

---

## 5. How to Compile and Run

To compile and assemble this program using the RISC-V GNU Toolchain, run:

```bash
# Assemble the source file
riscv64-unknown-elf-as -march=rv64g -mabi=lp64d pagefault_handling.s -o pagefault_handling.o

# Link the object file into an ELF executable
riscv64-unknown-elf-ld -Ttext 0x80000000 pagefault_handling.o -o pagefault_handling.elf