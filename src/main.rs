#![no_std]
#![no_main]

use blog_os::println;
use blog_os::sbi_call::shutdown;
use blog_os::trap;
use core::arch::{asm, global_asm};
use core::panic::PanicInfo;

global_asm!(include_str!("entry_riscv64.asm"));

#[no_mangle]
#[allow(unconditional_panic)]
pub extern "C" fn main() -> ! {
    trap::init();
    println!("Hello World! It's println.");
    unsafe {
        asm!("ebreak");
    }
    println!("recovered from trap");
    shutdown()
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    println!("{}", _info);
    shutdown()
}
