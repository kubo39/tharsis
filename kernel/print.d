module kernel.print;

import kernel.uart;

nothrow:
@nogc:
@system:

/**
 * とりあえずのデバッグ用に使いたい
 */
void print(Args...)(Args args)
{
    foreach (arg; args)
    {
        printOne(arg);
    }
}

private void printOne(T)(T v)
{
    static if (is(T : const(char)[]))
    {
        foreach (char c; v)
        {
            putchar(c);
        }
    }
    else static if (is(T == char))
    {
        putchar(v);
    }
    else static if (is(T == bool))
    {
        print(v ? "true" : "false");
    }
    else static if (__traits(isIntegral, T))
    {
        printDecimal(v);
    }
    else static if (is(T : const(void)*))
    {
        printHex(cast(size_t) v);
    }
    else static assert(false, "unsupported type: " ~ T.stringof);
}

private void printDecimal(T)(T v)
{
    ulong u;
    static if (__traits(isUnsigned, T))
    {
        u = v;
    }
    else
    {
        if (v < 0)
        {
            putchar('-');
            u = 0UL - cast(ulong) v;
        }
        else
        {
            u = v;
        }
    }

    char[20] buf;
    size_t i = buf.length;
    do
    {
        buf[--i] = cast(char)('0' + u % 10);
        u /= 10;
    } while (u != 0);

    foreach (char c; buf[i .. $])
    {
        putchar(c);
    }
}

private void printHex(ulong v)
{
    enum digits = "0123456789abcdef";
    print("0x");
    foreach_reverse (i; 0 .. 16)
    {
        putchar(digits[(v >> (i * 4)) & 0xf]);
    }
}

void putchar(char c)
{
    kernel.uart.writeByte(cast(ubyte) c);
}
