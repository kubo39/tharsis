module kernel.main;

import ldc.llvmasm : __asm;

import kernel.print;

extern (C):
@nogc:
nothrow:
@system:

noreturn kmain(ulong hartid, void* dtb)
{
    kernel.print.print("Hello, World!\n");
    while (true)
    {
        __asm("wfi", "");
    }
}
