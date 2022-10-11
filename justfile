set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]

build:
    @echo 'Building the os!'
    cargo build --release
    rust-objcopy --strip-all ./target/riscv64gc-unknown-none-elf/release/blog_os -O binary ./target/riscv64gc-unknown-none-elf/release/blog_os.bin

build-debug:
    @echo 'Building the os with debug symbols!'
    cargo build
    rust-objcopy --strip-all ./target/riscv64gc-unknown-none-elf/debug/blog_os -O binary ./target/riscv64gc-unknown-none-elf/debug/blog_os.bin

run: build
    qemu-system-riscv64 -machine virt -bios ./fw_jump.bin -device loader,file=./target/riscv64gc-unknown-none-elf/release/blog_os.bin,addr=0x80200000 -display none

run-gdb: build
    qemu-system-riscv64 -machine virt -bios ./fw_jump.bin -device loader,file=./target/riscv64gc-unknown-none-elf/release/blog_os.bin,addr=0x80200000 -display none -s -S

gdb: 
    riscv64-unknown-elf-gdb -ex 'file target/riscv64gc-unknown-none-elf/release/blog_os' -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234' -q

run-gdb-debug: build-debug
    qemu-system-riscv64 -machine virt -bios ./fw_jump.bin -device loader,file=./target/riscv64gc-unknown-none-elf/debug/blog_os.bin,addr=0x80200000 -display none -s -S

gdb-debug: 
    riscv64-unknown-elf-gdb -ex 'file target/riscv64gc-unknown-none-elf/debug/blog_os' -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234' -q