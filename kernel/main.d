module kernel.main;

import ldc.llvmasm : __asm;

import kernel.print;
import kernel.riscv;
import kernel.trap;
import kernel.uart;

extern (C):
@nogc:
nothrow:
@system:

noreturn kmain(ulong hartid, void* dtb)
{
    writeCsr!"stvec"(cast(ulong) &kernelEntry);
    kernel.uart.init();
    kernel.print.print("Hello, World!\n");
    while (true)
    {
        __asm("wfi", "");
    }
}
