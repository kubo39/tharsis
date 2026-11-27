# 物理メモリアロケータ

## 物理メモリアロケータとは

物理メモリを4KiB単位(ページ)で貸し出したり、返してもらったりする仕組みをこう呼ぶ。

## QEMUの場合

QEMU virtの場合だと、RAMの領域は `0x80000000` から128MiBになる。そのうちカーネルが使っている部分(`.text`から`.stack`)より後ろ側で4KiB境界に揃えた値(4KiB境界で揃えてないとページテーブルに登録できない)から `0x88000000` までが利用できる。

## 手法

代表的な物理メモリアロケータの実装方法は以下のようなものがある。

- bump allocator方式
- freelist方式
- buddy allocator方式
- bitmap方式

## freelist方式

今回はfreelist方式を使っていく。

freelist方式は、利用可能なページ領域を連結リストとして表現し、ページ領域そのもの(先頭8バイト)にリストの次の要素(next)への参照を書き込むことで別に管理領域を確保しなくてもすんでいる。

freelist方式のいいところとしては、実装が単純なのでバグを埋め込みにくい・allocもfreeもO(1)で完了する・(bitmap方式のように)別に管理する領域を置かなくてもよい、といった点があげられる。
反面、buddy allocatorのように連続した複数ページが確保できない・bitmap方式のように使用中のページがすぐにはわからないといった欠点もある。

コードは全体としてこのようになる。
要は確保したら(デバッグ用の値で埋めて)メモリ領域を返し、解放時にリストの先頭に追加して再利用可能なようにしているだけだ。また、初期化時にすべての利用可能なページをfreeしてリストに登録している。

`PAGE_SIZE` は `kernel.riscv`、リンカスクリプトのシンボル(`__free_ram` など)は `kernel.sections` で定義している。

```d
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
```
