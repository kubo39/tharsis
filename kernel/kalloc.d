module kernel.kalloc;

import kernel.klibc;
import kernel.print;
import kernel.riscv;
import kernel.sections;

@nogc:
nothrow:
@system:

__gshared PageAllocator pageAllocator;

private struct FreePage
{
    FreePage* next;
}

struct PageAllocator
{
@nogc:
nothrow:
@system:

    void* alloc()
    {
        FreePage* p = head;
        if (p is null)
            return null;
        head = p.next;
        memset(p, 5 /* デバッグ用 */, PAGE_SIZE);
        return p;
    }

    void free(void* p)
    {
        const addr = cast(size_t) p;
        if (addr % PAGE_SIZE != 0
            || p < __free_ram.ptr
            || p >= __free_ram_end.ptr)
        {
            panic!"free: invalid page %x"(p);
        }
        auto page = cast(FreePage*) p;
        page.next = head;
        head = page;
    }

private:
    @disable this(this);  // コピー禁止

    @disable ref PageAllocator opAssign(ref PageAllocator);  // 代入禁止

    FreePage* head;
}

void init()
{
    ubyte* p = __free_ram.ptr;
    ubyte* end = __free_ram_end.ptr;
    for (; p + PAGE_SIZE <= end; p += PAGE_SIZE)
        pageAllocator.free(p);
}
