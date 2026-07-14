.section .text
.global _start
.type _start, @function
.align 8

_start:
    cli
    mov $0x90000, %rsp   
    mov $0, %rbp
    
    call main

_hang:
    hlt
    jmp _hang
