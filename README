# XV6 Process Tree System Call (`pstree`)

This project introduces a new system call `pstree()` in the XV6 operating system that prints a **hierarchical process tree** with **ASCII formatting**, **color-coded process states**, and **orphan process detection**. It includes stress tests and performance benchmarks to evaluate the robustness of the implementation.

---
## Features

- New system call `pstree()` to visualize process hierarchy.
- Color-coded process states:
  - 🟢 **Running**
  - 🟡 **Runnable**
  - 🔵 **Sleeping**
  - ⚪ **Used**
  - ⚫ **Unused**
  - 🔴 **Zombie**
- Orphan Process Detection
- Includes testing for basic, forked, zombie, and stress conditions.
- Performance benchmarking.

## Snapshot

> example command outputs 
> simple:  
> ![pstree output](/snapshots/simple_test.png)
> 5-level:  
> ![pstree output](/snapshots/level_5.png)
> zombie:  
> ![pstree output](/snapshots/zombie.png)
> orphan:  
> ![pstree output](/snapshots/orphan.png)
---


---

## Kernel Modifications

### `proc.c`

**Added color definitions:**
```c
#define COLOR_RESET    "\x1b[0m"
#define COLOR_UNUSED   "\x1b[90m"
#define COLOR_USED     "\x1b[37m"
#define COLOR_SLEEPING "\x1b[34m"
#define COLOR_RUNNABLE "\x1b[33m"
#define COLOR_RUNNING  "\x1b[32m"
#define COLOR_ZOMBIE   "\x1b[31m"
```

**Process Table Lock Protection:**
- `acquire(&ptable.lock)` and `release()` added in `pstree()` for race prevention.

**Orphan Process Support:**
- Added `is_orphan = 0;` initialization.
- In `exit()` function:
```c
acquire(&p->lock);
if(p->parent != initproc) 
  p->is_orphan = 1;
release(&p->lock);
```
- Note **orphan process** is reparented to init process (firest process in user space)

**New Functions:**
```c
const char* get_state_color(enum procstate state);
int pstree(void);
void print_tree_ascii(struct proc *p, int depth, int is_last);
```

---

### `proc.h`

Added to `struct proc`:
```c
int is_orphan; // Orphan flag
```

---

### `defs.h`

```c
int pstree(void);
```

---

### `syscall.h`

```c
#define SYS_pstree 22
```

---

### `syscall.c`

```c
extern uint64 sys_pstree(void);
[SYS_pstree] sys_pstree,
```

---

### `sysproc.c`

```c
uint64 sys_pstree(void) {
  return pstree();
}
```

---

## User Programs

### `user/pstree.c`

```c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
  pstree();
  exit(0);
}
```

---

### `user/testps.c`

Contains 5 major tests:
- Basic Tree Test
- Fork Hierarchy Test (5 levels)
- Zombie Process Test
- Stress Test (10 forks)
- Performance Benchmark (100 iterations)

---

## Problems Faced & Solutions

| #  | Problem Description | Solution |
|----|---------------------|----------|
| 1 | Race condition when accessing `ptable` | Added `acquire()` / `release()` locks around `ptable` and `wait_lock` |
| 2 | Race didn't appear under stress test due to `printf` (Heisenbug) | Removed unnecessary `printf` as per XV6 Book, Section 6.1 |
| 3 | Crash on floating point usage in benchmark | Used integer math for averages (no FPU in XV6) |
| 4 | No built-in orphan flag | Added `is_orphan` field in `struct proc` |
| 5 | Zombie process cleaned up too early | Added `sleep(50)` delay before printing tree |

---

## Limitations

- Only supports up to 64 processes (default `NPROC`)
- Time Complexity: O(n²) due to nested traversal
- Tree formatting is static
- Locking introduces some kernel overhead
- Not interactive or collapsible (text-based)

---

## How to Use

### 1. Build & Run

```bash
$ make qemu
```

### 2. Run `pstree`

```bash
$ pstree
```

### 3. Run Tests

```bash
$ testps
```

---

## Technical Notes

### Integer Division in Benchmarking

Floating-point operations are unsupported in XV6 (no FPU):
```c
uint num = total_ticks / ITERATIONS;
uint frac = (total_ticks % ITERATIONS) * 1000 / ITERATIONS;
```

### About Zombie & Orphan States

- Zombie: Process has exited, but parent hasn’t called `wait()`
- Orphan: Parent has exited, process is adopted by `init`

---

## References

- [MIT XV6 Book](https://pdos.csail.mit.edu/6.1810/2024/xv6/book-riscv-rev4.pdf)

---

## Contributors

- Mohamed Goma
- Mohamed Khalid   
- Nezar Emad
- Mohamed Yehia
- Hassan 
- Zaynab Abdullah 
---
## Acknowledgments

Special thanks to **Mr.Mohamed Murad** for his guidance and support throughout the Operating Systems course. His enthusiasm and expertise made the learning experience significantly more engaging and impactful.
