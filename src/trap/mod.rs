use core::arch::global_asm;

use riscv::register::stvec::TrapMode;
use riscv::register::{sscratch, stvec};

use crate::context::Frame;
use crate::println;

// the entry point of trap handler,
// preserves and restores the env and calls trap_handler
global_asm!(include_str!("trap.S"));

// register the trap handler
pub fn init() {
    extern "C" {
        fn __alltraps();
    }
    unsafe {
        sscratch::write(0);
        stvec::write(__alltraps as usize, TrapMode::Direct);
        println!("++++ setup interrupt! ++++");
    }
}

// the real trap handler that handles traps
#[no_mangle]
fn trap_handler(f: &mut Frame) {
    // the length of ebreak instruction is 2
    f.sepc += 2;
    println!("trapped!");
}
