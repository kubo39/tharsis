# make run-qemu DEBUG=1 で起動した QEMU に接続する
# 使い方: gdb-multiarch -x debug.gdb
file build/kernel.elf
target remote localhost:1234
