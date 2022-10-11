use riscv::register::{scause::Scause, sstatus::Sstatus};

// referred to in trap/mod.rs, value set by codes in trap.S
#[repr(C)]
pub struct Frame {
    pub x: [usize; 32],
    pub sstatus: Sstatus,
    pub sepc: usize,
    pub stval: usize,
    pub scause: Scause,
}
