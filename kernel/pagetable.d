module kernel.pagetable;

import ldc.llvmasm : __asm;

import kernel.kalloc;
import kernel.klibc : memset;
import kernel.memorylayout : UART0;
import kernel.print;
import kernel.riscv;
import kernel.sections;
import kernel.types;

@nogc:
nothrow:
@system:

enum ulong SATP_SV39 = 8UL << 60;

enum ulong PAGE_V = 1 << 0;  // 有効化ビット
enum ulong PAGE_R = 1 << 1;  // 読み込み可能
enum ulong PAGE_W = 1 << 2;  // 書き込み可能
enum ulong PAGE_X = 1 << 3;  // 実行可能
enum ulong PAGE_U = 1 << 4;  // ユーザモードアクセス可能
enum ulong PAGE_A = 1 << 6;  // アクセスされたか
enum ulong PAGE_D = 1 << 7;  // Dirty(書き込みがあったか)

__gshared PageTable* kernelPageTable;

pragma(inline, true)
private ulong pageTableIndex(VAddr vaddr, uint level)
{
    return (vaddr >> (12 + 9 * level)) & 0x1ff;
}

/// ページテーブルエントリ(PTE)
/// bit 53:10 がPPN(物理アドレス >> 12)、bit 9:0 がフラグ
struct PageTableEntry
{
@nogc:
nothrow:
@system:

    static PageTableEntry make(PAddr paddr, ulong flags)
    {
        return PageTableEntry(((paddr >> 12) << 10) | flags);
    }

    bool valid() const
    {
        return (raw & PAGE_V) != 0;
    }

    PAddr physAddr() const
    {
        // 上位bit(63:54)は拡張用なのでPPNの44bitだけを取り出す
        return PAddr(((raw >> 10) & ((1UL << 44) - 1)) << 12);
    }

private:
    ulong raw;
}
static assert(PageTableEntry.sizeof == 8);

struct PageTable
{
@nogc:
nothrow:
@system:

    bool map(VAddr vaddr, PAddr paddr, size_t size, ulong perm)
    {
        if (size == 0)
            panic!"map size: 0";

        if (vaddr % PAGE_SIZE != 0)
            panic!"unaligned vaddr: %d"(cast(ulong) vaddr);
        if (paddr % PAGE_SIZE != 0)
            panic!"unaligned paddr: %d"(cast(ulong) paddr);

        for (ulong offset = 0; offset < size; offset += PAGE_SIZE)
        {
            PageTableEntry* entry = walk(vaddr + offset, true);
            if (entry is null)
                return false;
            if (entry.valid)
                panic!"map: remap occurred!";
            *entry = PageTableEntry.make(paddr + offset, perm | PAGE_A | PAGE_D | PAGE_V);
        }
        return true;
    }

    PageTableEntry* walk(VAddr vaddr, bool alloc)
    {
        PageTable* table = &this;
        foreach_reverse (level; 1 .. 3)
        {
            PageTableEntry* entry = &table.entries[pageTableIndex(vaddr, level)];
            if (entry.valid)
            {
                table = cast(PageTable*) cast(ulong) entry.physAddr;
            }
            else
            {
                if (!alloc)
                    return null;
                table = cast(PageTable*) pageAllocator.alloc();
                if (table is null)
                    return null;
                memset(table, 0x0, PAGE_SIZE);
                // R/W/X=0 なので「次の段のページテーブルを指す」PTEになる
                *entry = PageTableEntry.make(
                    PAddr(cast(ulong) table),
                    PAGE_V
                );
            }
        }
        return &table.entries[pageTableIndex(vaddr, 0)];
    }

private:
    @disable this(this);  // コピー禁止

    @disable ref PageTable opAssign(ref PageTable);  // 代入禁止

    PageTableEntry[512] entries;
}
static assert(PageTable.sizeof == PAGE_SIZE);

pragma(inline, true)
void enablePaging()
{
    __asm(`
        sfence.vma      # ページテーブルの中身をMMUにみえるように
        csrw satp, $0   # satpに書き込み
        sfence.vma      # 古いTLBを捨てる
    `, "r", SATP_SV39 | (cast(ulong) kernelPageTable >> 12));
}

void initKernelPageTable()
{
    auto root = cast(PageTable*) pageAllocator.alloc();
    if (root is null)
        panic!"kernel page table allocation failed.";
    memset(root, 0x0, PAGE_SIZE);

    // UART
    if (!root.map(
            VAddr(UART0),
            PAddr(UART0),
            PAGE_SIZE,
            PAGE_R | PAGE_W)
        )
        panic!"failed to map UART.";

    // .text(カーネルコード)
    if (!root.map(
        VAddr(cast(ulong) __kernel_base.ptr),
        PAddr(cast(ulong) __kernel_base.ptr),
        cast(ulong) (__etext.ptr - __kernel_base.ptr),
        PAGE_R | PAGE_X
    ))
        panic!"failed to map kernel code.";

    // .rodata/.data/.bss/.stack/RAM
    if (!root.map(
        VAddr(cast(ulong) __etext.ptr),
        PAddr(cast(ulong) __etext.ptr),
        cast(ulong) (__free_ram_end.ptr - __etext.ptr),
        PAGE_R | PAGE_W
    ))
        panic!"failed to map kernel data/RAM sections.";

    kernelPageTable = root;
}
