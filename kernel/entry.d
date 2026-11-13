module kernel.entry;

import ldc.attributes : naked, section;
import ldc.llvmasm : __asm;

extern (C):
@nogc:
nothrow:
@system:

@section(".text.boot")
@naked void entry()
{
    // スタックをセットする。
    // 今のところqemuで-smp 1を指定しているので、
    // mhartid: 0 でspは __stack_top から変わってない。
    __asm(`
        la sp, __stack_top  # スタックポインタに stack topのアドレスをセット
        csrr a0, mhartid
        slli t0, a0, 12     # a0 (mhartid) x 4096
        sub sp, sp, t0
        j start
    `, "");
}
