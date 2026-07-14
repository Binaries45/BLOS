
OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

PHDRS
{
    text   PT_LOAD FLAGS(5);
    rodata PT_LOAD FLAGS(4);
    data   PT_LOAD FLAGS(6);
}

SECTIONS {
    . = 0xffffffff80000000;

    .text : {
        *(.text*)
    } :text

    . = ALIGN(4K);

    .rodata : {
        *(.rodata*)
    } :rodata

    . = ALIGN(4K);

    .data : {
        _limine_reqs_start = .;
        KEEP(*(.limine_reqs))
        _limine_reqs_end = .;

        *(.data*)
    } :data

    .bss : {
        *(.bss*)
    } :data
}
