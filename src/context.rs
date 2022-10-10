use riscv::register::{scause::Scause, sstatus::Sstatus};

#[repr(C)]
pub struct Frame {
    pub x: [usize; 32],
    pub sstatus: Sstatus,
    pub sepc: usize,
    pub stval: usize,
    pub scause: Scause,
}
