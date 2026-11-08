module kernel.main;

import ldc.llvmasm : __asm;

extern (C):
@nogc:
nothrow:
@system:

noreturn kmain(ulong hartid, void* dtb)
{
    while (true)
    {
        __asm("wfi", "");
    }
}
