use core::arch::global_asm;

use riscv::register::stvec::TrapMode;
use riscv::register::{sscratch, stvec};

use crate::context::Frame;
use crate::println;

global_asm!(include_str!("trap.S"));

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

#[no_mangle]
fn trap_handler(f: &mut Frame) {
    // if f.spec += 4, then it will either panic here or trap again
    f.sepc += 2;
    println!("trapped!");
}
