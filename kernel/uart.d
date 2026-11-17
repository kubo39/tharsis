module kernel.uart;

import core.volatile;

import kernel.memorylayout;

extern (C):
nothrow:
@nogc:
@system:

enum ulong THR = 0;  // Transmit Holding Register

enum ulong IER = 1;  // Interrupt Enable Register

enum ubyte IER_RX_ENABLE = 1 << 0;  // receiver interrupts
enum ubyte IER_TX_ENABLE = 1 << 1; // transmit interrupts

enum ulong FCR = 2;

enum ubyte FCR_FIFO_ENABLE = 1 << 0;
enum ubyte FCR_FIFO_CLEAR = 3 << 1;  // clear the content of the two FIFOs

enum ulong LCR = 3;  // Line Control Register

enum ubyte LCR_EIGHT_BITS = 3 << 0;
enum ubyte LCR_BAUD_LATCH = 1 << 7;  // special mode to set baud rate

enum ulong LSR = 5;  // Line Status Register

enum ubyte LSR_THRE = 1 << 5;  // THR Empty


ubyte readByte(ulong reg)
{
    return volatileLoad(cast(ubyte*) (UART0 + reg));
}

void writeByte(ulong reg, ubyte c)
{
    volatileStore(cast(ubyte*) (UART0 + reg), c);
}

void putchar(ubyte b)
{
    while (!(readByte(LSR) & LSR_THRE)) {}
    writeByte(THR, b);
}

void init()
{
    // 割り込みを無効にする(設定中に割り込みが来ないように)
    writeByte(IER, ubyte(0x0));

    // LCRのDLAB(bit7)を立てる。オフセット0/1が分周値レジスタ(DLL/DLM)に切り替わる
    writeByte(LCR, LCR_BAUD_LATCH);

    // 分周値の下位バイト(DLL)。基準115200 / 3 = 38400 baud
    writeByte(0, ubyte(0x3));

    // 分周値の上位バイト(DLM)
    writeByte(1, ubyte(0x0));

    // ワード長8bit・パリティなし・ストップビット1(8N1)。同時にDLABを下ろし、オフセット0/1をTHR/IERに戻す
    writeByte(LCR, LCR_EIGHT_BITS);

    // FIFOを有効にし、送受信FIFOの中身をクリアする
    writeByte(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);

    // 送信・受信割り込みを有効にする
    writeByte(IER, IER_TX_ENABLE | IER_RX_ENABLE);
}
