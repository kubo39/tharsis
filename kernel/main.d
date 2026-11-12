module kernel.main;

import ldc.llvmasm : __asm;

import kernel.print;
import kernel.riscv;
import kernel.trap;

extern (C):
@nogc:
nothrow:
@system:

noreturn kmain(ulong hartid, void* dtb)
{
    writeCsr!"stvec"(cast(ulong) &kernelEntry);
    // __asm("unimp", "");
    kernel.print.print("Hello, World!\n");
    while (true)
    {
        __asm("wfi", "");
    }
}
