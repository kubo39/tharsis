# RISC-V・D言語・LDC

なんでRISC-V・D言語・LDCなのか、それぞれ書いてみる。

## RISC-V

RISC-Vを選定したのは

- [OS in 1,000 Lines](https://operating-system-in-1000-lines.vercel.app/ja/02-assembly)にもあるように、仕様がシンプル・意図がわかる形で残っている
- 上記にあるように、OS開発の資料がそこそこ豊富にある
  - https://github.com/riscv/learn とかにもリソースがまとまっているし、自作OS先駆者もけっこういる([xv6-riscv](https://github.com/mit-pdos/xv6-riscv)など)

といったあたり。

## D言語

自作OSではC言語とRust、C++が使われることが多いが、もちろんそれ以外の言語でもできる。うん、できるはず。

それでもブートシーケンスから開始するのであれば、やっぱり低レイヤを触れるような言語、たとえばZig・D・Nimあたりまでになるだろう。

今回はD言語を選んでいるが、Nimで書き直してみるのもおもしろいだろう。

本実装で利用しているD言語の特徴として:

- テンプレートによる強力な抽象化能力
- `extern(C)` でC言語の呼び出し規約を利用できる、OS開発ではCの呼び出し規約を前提にするような仕組みもあるのでこれは有用になる
- `noreturn` で戻ってこない関数呼び出しを表現可能

## LDC

RISC-Vをターゲットにするので、利用するコンパイラはLDCになる。実際のところ、LLVMの低レベルへの機能へのアクセスが可能である点やクロスコンパイルの簡易さの観点からどのターゲットでもLDCを利用することになるとは思うが。

LDCはLLVMをバックエンドとしたD言語のコンパイラだ。
なので基本的にはコード生成はLLVMの機能が使えるし、同時にLLVMならではの制約をうける。

OS開発においてよく利用する機能としては:

- インラインアセンブリ
- 一部の関数属性 (`ldc.attributes.naked`, `ldc.attributes.section`)

### インラインアセンブリ

LDCのインラインアセンブリはほとんどLLVM内部に渡すだけだが、一部意識しておくことがある。

```d
    __asm(`
        la sp, __stack_top  # スタックポインタに stack topのアドレスをセット
        csrr a0, mhartid
        slli t0, a0, 12     # a0 (mhartid) x 4096
        sub sp, sp, t0
        j start
    `, "");
```

- 常に`volatile`/`memory clobber`相当が付与されているので、最適化によって消されたり並べ替えられたりしない(CPUのリオーダリングは別なのでfence命令などでガードする必要はある)。
  - 参考: [LLVMインラインアセンブラのmemory constraints/clobberのはなし](https://qiita.com/kubo39/items/a121a3c4c8cbaa5e5807)
- コメントも書けるが、上述のようにLLVMに渡しているだけなのでLLVM側の仕様(アーキテクチャによってコメント表現がかわる)を意識する必要がある。RISC-Vは `#` でコメントになる。

