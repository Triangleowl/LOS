[bits 32]

extern init_kernel
global _start

_start:
    xchg bx, bx
    ; mov byte [0xb8000], 'K'
    call init_kernel
    jmp $