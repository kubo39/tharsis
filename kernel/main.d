module kernel.main;

import ldc.llvmasm : __asm;

import kernel.kalloc;
import kernel.klibc;
import kernel.pagetable;
import kernel.print;
import kernel.riscv;
import kernel.trap;
import kernel.uart;

extern (C):
@nogc:
nothrow:
@system:

extern __gshared ubyte[0] __bss;
extern __gshared ubyte[0] __bss_end;

noreturn kmain(ulong hartid, void* dtb)
{
    memset(__bss.ptr, 0x0, __bss_end.ptr - __bss.ptr);
    writeCsr!"stvec"(cast(ulong) &kernelEntry);
    kernel.uart.init();
    kernel.kalloc.init();
    kernel.pagetable.initKernelPageTable();
    kernel.pagetable.enablePaging();
    print("paging enabled: satp=", cast(void*) readCsr!"satp", "\n");

    kernel.print.print("Hello, World!\n");
    while (true)
    {
        __asm("wfi", "");
    }
}
