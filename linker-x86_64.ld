/*
    Linker script from:
        https://github.com/sweetbbak/asukaOS/blob/main/src/linker.ld
*/

/* the name of the entry label */
ENTRY(_start)
 
SECTIONS {
    . = 1M; /* the code should be loaded at 1MB (bios, bootloader, mmap IO lives in the first 1MB) */

    .text : ALIGN(8K) { /* align at 8KB */
        *(.multiboot)
        *(.text) /* all text sections from all files */
    }
 
    .rodata : ALIGN(8K) {
        *(.rodata) /* all read-only data sections */
    }
 
    .data : ALIGN(8K) {
        *(.data) /* all data sections */
    }
 
    .bss : ALIGN(8K) {
        *(COMMON) /* all COMMON sections */
        *(.bss) /* all bss sections */
    }
}

/* OUTPUT_FORMAT(elf64-x86-64) */
/* ENTRY(_start) */

/* SECTIONS { */
    /* . = 1M; */

    /* .text : { */
        /* KEEP(*(.multiboot)) */
        /* *(.text) */
    /* } */

    /* .rodata : { *(.rodata) } */
    /* .data   : { *(.data) } */
    /* .bss    : { *(.bss) } */
/* } */
