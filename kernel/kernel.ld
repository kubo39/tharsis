ENTRY(entry)

SECTIONS
{
    . = 0x80000000;

    .text : {
        KEEP(*(.text.boot))
        . = ALIGN(4);
        KEEP(*(.text.trap))
        *(.text .text.*)
    }

    . = ALIGN(0x1000);
    PROVIDE(__etext = .);

    .rodata : ALIGN(16) {
        __rodata = .;
        *(.rodata .rodata.*);
        __rodata_end = .;
    }

    .data : ALIGN(16) {
        __data = .;
        *(.data .data.*);
        __data_end = .;
    }

    .bss : ALIGN(16) {
        __bss = .;
        *(.bss .bss.*);
        __bss_end = .;
    }

    .stack(NOLOAD) : ALIGN(16) {
        PROVIDE(__stack_bottom = .);
        . += 4096;  /* スタックは4KiB */
        PROVIDE(__stack_top = .);
    }

    . = ALIGN(0x1000);

    .comment          0 : { *(.comment) }
    .riscv.attributes 0 : { *(.riscv.attributes) }
    .symtab           0 : { *(.symtab) }
    .strtab           0 : { *(.strtab) }
    .shstrtab         0 : { *(.shstrtab) }

    /DISCARD/ : {
        *(.eh_frame) *(.eh_frame_hdr)
    }
}
