module kernel.riscv;

import ldc.llvmasm : __asm;

@nogc:
nothrow:
@system:

enum ulong MSTATUS_MPP_MASK = 3UL << 11;
enum ulong MSTATUS_MPP_S = 1UL << 11;

enum ulong PMP_R = 1UL << 0;
enum ulong PMP_W = 1UL << 1;
enum ulong PMP_X = 1UL << 2;

enum ulong PMP_A_TOR = 1UL << 3;

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
