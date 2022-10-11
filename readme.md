# MyOS

This is a RISC-V port of Phil-Opp's BlogOS. Part of its code comes from rCore-Tutorial [v2](https://github.com/rcore-os/rCore_tutorial_doc) and [v3](https://github.com/rcore-os/rCore-Tutorial-v3). It can currently boot, shutdown, print to the screen, and print to the serial port successfully. It has a primitive trap handling module as well, which simply jumps over the trapping instruction.

## How to run

### Requirements

1. rust-std-riscv64gc-unknown-none-elf
2. rust-src
3. qemu-system-riscv64
4. (Recommended) [just](https://just.systems/)
5. (Optional) [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)

### Test

Assuming that you have `just` installed, type in the project directory:

```sh
just run
```

If you need to use gdb, run these following commands:

```sh
just run-gdb-debug
# In another shell
just gdb-debug
```

## Booting

The first several steps of the booting process of x86_64 and RISC-V are a little bit different.

For x86 architecture, after the CPU is powered on, it works in real mode and resets all its registers and set the IP, CS Selector, and CS Base to ba a predefined value, which are usually 0xfff0, 0xf000, and 0xffff0000. Then, the CPU finds the first intruction at the address 0xfffffff0 determined by these three registers. At 0xfffffff0, it is usually a `jmp` instruction pointing to BIOS. Then, BIOS starts checking the hardwares and so on. After that, if it is recorded in the BIOS that boot from a hard drive, the BIOS will check the MBR on the selected hard drive to find the next instructions, and this is when the OS kernel or the bootloader (Grub2, bootmgr) is loaded. 

For RISC-V architecture, after the CPU is powered on, the registers are reset under the first instructions located starting at 0x1000. Then, if the value of MSEL (Mode Select) is larger than 4, the CPU is on M-mode and starts ZSBL (Zeroth Stage Bootloader), which is located in the ROM and loads FSBL (First Stage Bootloader) to the memory according to MSEL. Usually, FSBL is located at 0x80000000 in the memory. After FSBL, the CPU jumps to 0x80200000 as the next stage. With OpenSBI, it handles hardware initiation and resides in the memory acting as a bridge between M-mode and S-mode. At the next stage, we can use U-Boot (runs on M-mode) to control the following booting process, or directly invoke the kernel (runs on S-mode).

There are several differences between these two booting processes:

1. x86 CPUs switch from real mode to protected mode during the next stage bootloader, whereas RISC-V CPUs from M-mode to S-mode when OpenSBI or U-Boot loads the kernel.
2. BIOS no longer exists in the memory after the kernel or the bootloader is invoked, whereas OpenSBI resides in the memory and continues operating as a bridge between the M-mode and S-mode.

There are several difficulties when porting the booting process. 

Firstly, there is no way to specify the address of the entry point of a program using the rust compiler. If we want to place the entry point of the program at 0x80200000, we have to try linker scripts to specify the address of the `.text` segment. However, the rust compiler would inserts several instructions before and after the `_start()` function, which is our entry point. Consequently, the address of `_start()` was usually 0x8020008e, 0x8020005e, or so on, depending on the different compiling options. At the beginning, I tried using U-Boot to specify the address of the kernel, but it was also troublesome, because everytime it was compiled, we had to confirm the address of the entry point and change the U-Boot commands accordingly. Then, I found that the problem seemed to be solved if `-Zbuild-std` was turned on. It may be the solution, but I am not sure, because I cannot find any information about the problem, and the solution of the next problem also helped to solve this error.

Then, after solving the previous problem (or at least coincidently avoiding the problem), I found that the virtual machine reset after the second instruction of the kernel when not using U-Boot. Strangely, this error would not occur when using U-Boot. The very instruction that caused the resetting was something like `sd ra, 144(sp)`. Later I realized that the value of $sp could be inaccessible because it is on OpenSBI's stack. Therefore, after reading the rCore tutorial, I learned that [rust could not modify the value of $sp](https://zhuanlan.zhihu.com/p/270379116), so it was necessary to write a piece of assembly code as the entry point to allocate a block of space as the kernel stack as well as to invoke the rust main function, which contributed to solve the previous problem.

