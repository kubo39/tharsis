module kernel.print;

import ldc.llvmasm;

import kernel.uart;

nothrow:
@nogc:
@system:

noreturn panic(string fmt, string file = __FILE__, size_t line = __LINE__, Args...)(Args args)
{
    printf!("PANIC: " ~ file ~ ":" ~ toDecString!line ~ ": " ~ fmt ~ "\n")(args);
    while (true)
    {
        __asm("wfi", "");
    }
}

void putchar(char c)
{
    kernel.uart.putchar(cast(ubyte) c);
}

void putStr(const(char)[] s)
{
    foreach (char c; s)
        putchar(c);
}

void putCStr(const(char)* s)
{
    while (*s)
        putchar(*s++);
}

void putDec(long value)
{
    ulong magnitude = value;
    if (value < 0)
    {
        putchar('-');
        magnitude = -magnitude;
    }
    putDec(magnitude);
}

void putDec(ulong magnitude)
{
    ulong divisor = 1;
    while (magnitude / divisor > 9)
        divisor *= 10;

    while (divisor > 0)
    {
        putchar(cast(char)('0' + magnitude / divisor));
        magnitude %= divisor;
        divisor /= 10;
    }
}

void putHex(ulong value)
{
    foreach_reverse (i; 0 .. 16)
    {
        uint nibble = (value >> (i * 4)) & 0xf;
        putchar("0123456789abcdef"[nibble]);
    }
}

void printf(string fmt, Args...)(Args args)
{
    enum segs = parseFormat!fmt();
    static assert(countArgs(segs) == Args.length,
        "printf: argument count mismatch: \"" ~ fmt ~ "\"");

    static foreach (seg; segs)
    {
        static if (seg.kind == Seg.Kind.literal)
            putStr(seg.lit);
        else
            putArg!(seg.kind, fmt)(args[seg.arg]);
    }
}

private:

template toDecString(size_t n)
{
    static if (n < 10)
        enum toDecString = "0123456789"[n .. n + 1];
    else
        enum toDecString = toDecString!(n / 10) ~ toDecString!(n % 10);
}

struct Seg
{
    enum Kind : char
    {
        literal = 'L',
        dec = 'd',
        hex = 'x',
        str = 's',
    }
    Kind kind;
    string lit;
    size_t arg;
}

void putArg(Seg.Kind kind, string fmt, T)(T value)
{
    static if (kind == Seg.Kind.dec)
    {
        static if (__traits(isUnsigned, T))
            putDec(cast(ulong) value);
        else
            putDec(cast(long) value);
    }
    else static if (kind == Seg.Kind.hex)
    {
        putHex(cast(ulong) value);
    }
    else static if (kind == Seg.Kind.str)
    {
        static assert(is(T : const(char)[]) || is(T : const(char)*),
            "printf: %s expects a string (const(char)[] or const(char)*), got "
            ~ T.stringof ~ ": \"" ~ fmt ~ "\"");
        static if (is(T : const(char)[]))
            putStr(value);
        else
            putCStr(value);
    }
}

size_t countSegs()(string fmt)
{
    size_t n = 0;
    size_t i = 0;
    while (i < fmt.length)
    {
        if (fmt[i] == '%')
        {
            i += 2;
        }
        else
        {
            while (i < fmt.length && fmt[i] != '%')
                i++;
        }
        n++;
    }
    return n;
}

Seg[countSegs(fmt)] parseFormat(string fmt)()
{
    Seg[countSegs(fmt)] segs;
    size_t n = 0;
    size_t arg = 0;
    size_t i = 0;
    while (i < fmt.length)
    {
        if (fmt[i] == '%')
        {
            if (i + 1 >= fmt.length)
                assert(false, "printf: trailing '%' in format: \"" ~ fmt ~ "\"");
            switch (fmt[i + 1])
            {
            case '%':
                segs[n] = Seg(Seg.Kind.literal, "%");
                break;
            case 'd':
                segs[n] = Seg(Seg.Kind.dec, null, arg++);
                break;
            case 'x':
                segs[n] = Seg(Seg.Kind.hex, null, arg++);
                break;
            case 's':
                segs[n] = Seg(Seg.Kind.str, null, arg++);
                break;
            default:
                assert(false, "printf: unsupported format specifier %" ~ fmt[i + 1 .. i + 2]
                    ~ ": \"" ~ fmt ~ "\"");
            }
            i += 2;
        }
        else
        {
            const start = i;
            while (i < fmt.length && fmt[i] != '%')
                i++;
            segs[n] = Seg(Seg.Kind.literal, fmt[start .. i]);
        }
        n++;
    }
    return segs;
}

size_t countArgs(size_t N)(const Seg[N] segs)
{
    size_t n = 0;
    foreach (seg; segs)
    {
        if (seg.kind != Seg.Kind.literal)
            n++;
    }
    return n;
}
