module kernel.timer;

import kernel.print;
import kernel.riscv;

nothrow:
@nogc:
@system:

// QEMU virt の timebase は 10MHz なので約 0.1 秒
enum ulong TIMER_INTERVAL = 1_000_000;

__gshared ulong ticks;

void init()
{
    scheduleNext();
    setCsr!"sie"(SIE_STIE);
}

void handleInterrupt()
{
    ticks++;
    if (ticks % 10 == 0)
        printf!"tick: %d\n"(ticks);
    // 次の予約。Sstc では stimecmp を書くことで STIP も下がる
    scheduleNext();
}

private void scheduleNext()
{
    writeCsr!"stimecmp"(readCsr!"time" + TIMER_INTERVAL);
}
