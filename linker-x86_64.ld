
OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

/* Define explicit program header segments with strict permission flags */
PHDRS
{
    text   PT_LOAD FLAGS(5); /* 5 = Read (4) + Execute (1) */
    rodata PT_LOAD FLAGS(4); /* 4 = Read Only (4) */
    data   PT_LOAD FLAGS(6); /* 6 = Read (4) + Write (2) */
}

SECTIONS {
    . = 0xffffffff80000000;

    /* 1. Executable Code Segment */
    .text : {
        *(.text*)
    } :text

    . = ALIGN(4K);

    /* 2. Read-Only Data Segment */
    .rodata : {
        *(.rodata*)
    } :rodata

    . = ALIGN(4K);

    /* 3. Read/Write Data Segment */
    .data : {
        /* Move Limine requests into the writable data segment */
        /* Provide tracking symbols so Limine can safely query the boundaries */
        _limine_reqs_start = .;
        KEEP(*(.limine_reqs))
        _limine_reqs_end = .;

        *(.data*)
    } :data

    /* BSS shares the same Read/Write data segment page bounds */
    .bss : {
        *(.bss*)
    } :data
}
