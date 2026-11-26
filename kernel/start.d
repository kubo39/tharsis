module kernel.start;

import ldc.llvmasm : __asm;

import kernel.main;
import kernel.riscv;

extern (C):
@nogc:
nothrow:
@system:

// DTBはブートROMや前段のブートローダがa1で渡すことを想定している。
// 今のところはQEMUでしか動かさないのでこのままで問題ない。
void start(ulong hartid, void* dtb)
{
    // MPP: Machine Previous Privilege
    // Sモードにセットする
    clearCsr!"mstatus"(MSTATUS_MPP_MASK);
    setCsr!"mstatus"(MSTATUS_MPP_S);

    // mretで飛ぶ先をkmain関数にする
    writeCsr!"mepc"(cast(ulong) &kmain);

    // Sモードでのメモリへのアクセスを許可する
    writeCsr!"pmpaddr0"(0x3f_ffff_ffff_ffffUL);
    writeCsr!"pmpcfg0"(PMP_A_TOR | PMP_R | PMP_W | PMP_X);

    // satp = 0: ページング無効にした状態でSモードに入る
    writeCsr!"satp"(0);

    // 割り込み・例外をSモードに委譲する(書き込めないビットは無視される)
    writeCsr!"medeleg"(0xffff);
    writeCsr!"mideleg"(0xffff);    

    // Sstc: S-mode から stimecmp でタイマを設定できるようにする
    setCsr!"menvcfg"(MENVCFG_STCE);
    setCsr!"mcounteren"(MCOUNTEREN_TM);

    // Sモードに切り替え
    __asm("mret", "{a0},{a1}", hartid, dtb);
}
