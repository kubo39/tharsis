module kernel.klibc;

extern (C):
@nogc:
nothrow:
@system:

import ldc.intrinsics : llvm_frameaddress;
import ldc.llvmasm : __asm;

import kernel.sections;
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

pragma(inline, false)
void backtrace()
{
    auto fp = cast(ulong) llvm_frameaddress(0);
    uint depth = 0;
    while (fp != 0
      && (fp & 7) == 0
      && fp > cast(ulong) __stack_bottom.ptr
      && fp <= cast(ulong) __stack_top.ptr  // 一番外側のフレームでは fp == __stack_top
      && depth < 16)
    {
        ulong ra = *cast(ulong*) (fp - 8);
        if (ra == 0)
            break;
        printf!"  #%d:%x\n"(depth, ra - 2);
        fp = *cast(ulong*) (fp - 16);
        depth++;
    }
}

private:

noreturn __assert(const(char)* msg, const(char)* file, int line)
{
    printf!"PANIC: %s:%d: %s\n"(file, line, msg);
    backtrace();
    while (true)
        __asm("wfi", "");
}
