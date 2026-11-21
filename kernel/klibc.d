module kernel.klibc;

extern (C):
@nogc:
nothrow:
@system:

import ldc.llvmasm : __asm;

import kernel.print;

void* memset(void* buf, int c, size_t n)
{
    ubyte* p = cast(ubyte*) buf;
    while (n--)
    {
        *p++ = cast(ubyte) c;
    }
    return buf;
}

private:

extern(C) noreturn __assert(const(char)* msg, const(char)* file, int line)
{
    printf!"PANIC: %s:%d: %s\n"(file, line, msg);
    while (true)
        __asm("wfi", "");
}
