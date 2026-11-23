ENTRY(entry)

SECTIONS
{
    . = 0x80000000;
    PROVIDE(__kernel_base = .);

    .text : {
        KEEP(*(.text.boot));
        . = ALIGN(4);
        KEEP(*(.text.trap));
        *(.text .text.*)
    }

    . = ALIGN(0x1000);
    PROVIDE(__etext = .);

    .rodata : ALIGN(16) {
        PROVIDE(__rodata = .);
        *(.rodata .rodata.*);
        PROVIDE(__rodata_end = .);
    }

    .data : ALIGN(16) {
        PROVIDE(__data = .);
        *(.data .data.*);
        PROVIDE(__data_end = .);
    }

    .bss : ALIGN(16) {
        PROVIDE(__bss = .);
        *(.bss .bss.*);
        PROVIDE(__bss_end = .);
    }

    .stack(NOLOAD) : ALIGN(16) {
        PROVIDE(__stack_bottom = .);
        . += 4096;  /* スタックは4KiB */
        PROVIDE(__stack_top = .);
    }

    . = ALIGN(0x1000);
    PROVIDE(__free_ram = .);
    PROVIDE(__free_ram_end = 0x88000000);

    .comment          0 : { *(.comment) }
    .riscv.attributes 0 : { *(.riscv.attributes) }
    .symtab           0 : { *(.symtab) }
    .strtab           0 : { *(.strtab) }
    .shstrtab         0 : { *(.shstrtab) }

    .debug_abbrev     0 : { *(.debug_abbrev) }
    .debug_info       0 : { *(.debug_info) }
    .debug_str        0 : { *(.debug_str) }
    .debug_pubnames   0 : { *(.debug_pubnames) }
    .debug_pubtypes   0 : { *(.debug_pubtypes) }
    .debug_line       0 : { *(.debug_line) }
    .debug_loc        0 : { *(.debug_loc) }
    .debug_ranges     0 : { *(.debug_ranges) }
    .debug_frame      0 : { *(.debug_frame) }

    /DISCARD/ : {
        *(.eh_frame)
    }
}
