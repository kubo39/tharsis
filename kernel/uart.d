module kernel.uart;

import core.volatile;

import kernel.memorylayout;

extern (C):
nothrow:
@nogc:
@system:

enum THR = 0;  // Transmit Holding Register

void writeBytes(const(ubyte)[] s)
{
    foreach (c; s)
    {
        writeByte(c);
    }
}

void writeByte(ubyte c)
{
    volatileStore(cast(ubyte*) (UART0 + THR), c);
}

void writeString(const(char)[] s)
{
    foreach (char c; s)
    {
        writeByte(cast(ubyte) c);
    }
}
