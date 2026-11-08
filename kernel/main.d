module kernel.main;

import ldc.llvmasm : __asm;

import kernel.uart;

extern (C):
@nogc:
nothrow:
@system:

noreturn kmain(ulong hartid, void* dtb)
{
    kernel.uart.writeString("Hello, World!\n");
    while (true)
    {
        __asm("wfi", "");
    }
}
