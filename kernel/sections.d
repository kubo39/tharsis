module kernel.sections;

// kernel.ld で定義しているシンボル。
// アドレスだけに意味があるので ubyte[0] で宣言して .ptr で使う。

extern (C):
@nogc:
nothrow:
@system:

extern __gshared ubyte[0] __kernel_base;
extern __gshared ubyte[0] __etext;

extern __gshared ubyte[0] __rodata;
extern __gshared ubyte[0] __rodata_end;

extern __gshared ubyte[0] __data;
extern __gshared ubyte[0] __data_end;

extern __gshared ubyte[0] __bss;
extern __gshared ubyte[0] __bss_end;

extern __gshared ubyte[0] __stack_bottom;
extern __gshared ubyte[0] __stack_top;

extern __gshared ubyte[0] __free_ram;
extern __gshared ubyte[0] __free_ram_end;
