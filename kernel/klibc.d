module kernel.klibc;

extern (C):
@nogc:
nothrow:
@system:

void* memset(void* buf, int c, size_t n)
{
    ubyte* p = cast(ubyte*) buf;
    while (n--)
    {
        *p++ = cast(ubyte) c;
    }
    return buf;
}
