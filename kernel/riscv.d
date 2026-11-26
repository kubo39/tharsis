module kernel.riscv;

import ldc.llvmasm : __asm;

@nogc:
nothrow:
@system:

enum PAGE_SIZE = 4096;

enum ulong MSTATUS_MPP_MASK = 3UL << 11;
enum ulong MSTATUS_MPP_S = 1UL << 11;

enum ulong PMP_R = 1UL << 0;
enum ulong PMP_W = 1UL << 1;
enum ulong PMP_X = 1UL << 2;

enum ulong PMP_A_TOR = 1UL << 3;

enum ulong MENVCFG_STCE = 1UL << 63;  // Sstc: stimecmp を有効にする
enum ulong MCOUNTEREN_TM = 1UL << 1;  // S-mode に time (と stimecmp) を許す

enum ulong SSTATUS_SIE = 1UL << 1;  // S-mode の割り込み全体の許可
enum ulong SIE_STIE = 1UL << 5;     // S-mode のタイマ割り込みの許可

enum ulong SCAUSE_INTERRUPT = 1UL << 63;
enum ulong SCAUSE_S_TIMER = SCAUSE_INTERRUPT | 5;

pragma(inline, true)
ulong readCsr(string csr)()
{
    return __asm!ulong("csrr $0, " ~ csr, "=r");
}

pragma(inline, true)
void writeCsr(string csr)(ulong v)
{
    __asm("csrw " ~ csr ~ ", $0", "r,~{memory}", v);
}

pragma(inline, true)
void setCsr(string csr)(ulong v)
{
    __asm("csrs " ~ csr ~ ", $0", "r,~{memory}", v);
}

pragma(inline, true)
void clearCsr(string csr)(ulong v)
{
    __asm("csrc " ~ csr ~ ", $0", "r,~{memory}", v);
}
