[org 0x1000]

dw 0xdead

xchg bx, bx

mov si, loading
call print

jmp prepare_protected_mode

prepare_protected_mode:
    xchg bx, bx
    ; 关闭中断
    cli

    ; 开启A20地址线
    in al, 0x92
    or al, 0b10
    out 0x92, al

    lgdt [gdt_ptr]

    ; 启动保护模式
    mov eax, cr0
    or eax, 0x01
    mov cr0, eax

    jmp dword code_selector:protect_mode

print:
    mov ah, 0x0e
.next:
    mov al, [si]
    cmp al, 0x00
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret

loading:
    db "loading LOS ...", 0x0a, 0x0d, 0



[bits 32]
protect_mode:
    xchg bx, bx
    mov ax, data_selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x10000
    mov byte[0xb8000], 'P'

    jmp $

code_selector equ (1 << 3)
data_selector equ (2 << 3)
memory_base equ 0
memory_limit equ ((1024 * 1024 * 1024 * 4) / (1025 * 4)) - 1

gdt_ptr:
    dw (gdt_end - gdt_base) - 1
    dd gdt_base
gdt_base:
    ; 0号 描述符
    dd 0, 00; 

gdt_code:
    dw memory_limit & 0xffff; 段界限 0 ~ 15 位
    dw memory_base & 0xffff; // 基地址 0 ~ 16 位
    db (memory_base >> 16) & 0xff; // 基地址 0 ~ 16 位
    ; 存在 - dlp 0 - S _ 代码 - 非依从 - 可读 - 没有被访问过
    db 0b_1_00_1_1_0_1_0;
    ; 4k - 32 位 - 不是 64 位 - 段界限 16 ~ 19
    db 0b1_1_0_0_0000 | (memory_limit >> 16) & 0xf;
    db (memory_base >> 24) & 0xff; 基地址 24 ~ 31 位
gdt_data:
    dw memory_limit & 0xffff; 段界限 0 ~ 15 位
    dw memory_base & 0xffff; // 基地址 0 ~ 16 位
    db (memory_base >> 16) & 0xff; // 基地址 0 ~ 16 位
    ; 存在 - dlp 0 - S _ 数据 - 向上 - 可写 - 没有被访问过
    db 0b_1_00_1_0_0_1_0;
    ; 4k - 32 位 - 不是 64 位 - 段界限 16 ~ 19
    db 0b1_1_0_0_0000 | (memory_limit >> 16) & 0xf;
    db (memory_base >> 24) & 0xff; 基地址 24 ~ 31 位
gdt_end:

ards_count:
    dw 0
ards_buffer: