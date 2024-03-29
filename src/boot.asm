
[org 0x7c00]

; why call 0x10 ???
mov ax, 0x03
int 0x10


mov ax, 0x00
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

; print "Hello, LOS"
mov si, greeting
call print


mov edi, 0x1000; 读取的目标内存
mov ecx, 1; 起始扇区
mov bl, 1; 扇区数量

call read_disk

xchg bx, bx; bochs 魔术断点

mov edi, 0x1000; 读取的目标内存
mov ecx, 2; 起始扇区
mov bl, 1; 扇区数量
call write_disk

xchg bx, bx
mov word [0x1000], 0xdead
jz 0x1002
jmp $

read_disk:

    ; 设置读写扇区的数量
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    inc dx; 0x1f3
    mov al, cl; 起始扇区的前八位
    out dx, al

    inc dx; 0x1f4
    shr ecx, 8
    mov al, cl; 起始扇区的中八位
    out dx, al

    inc dx; 0x1f5
    shr ecx, 8
    mov al, cl; 起始扇区的高八位
    out dx, al

    inc dx; 0x1f6
    shr ecx, 8
    and cl, 0b1111; 将高四位置为 0

    mov al, 0b1110_0000;
    or al, cl
    out dx, al; 主盘 - LBA 模式

    inc dx; 0x1f7
    mov al, 0x20; 读硬盘
    out dx, al

    xor ecx, ecx; 将 ecx 清空
    mov cl, bl; 得到读写扇区的数量

    .read:
        push cx; 保存 cx
        call .waits; 等待数据准备完毕
        call .reads; 读取一个扇区
        pop cx; 恢复 cx
        loop .read

    ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx
            jmp $+2; nop 直接跳转到下一行
            jmp $+2; 一点点延迟
            jmp $+2
            and al, 0b1000_1000
            cmp al, 0b0000_1000
            jnz .check
        ret

    .reads:
        mov dx, 0x1f0
        mov cx, 256; 一个扇区 256 字
        .readw:
            in ax, dx
            jmp $+2; 一点点延迟
            jmp $+2
            jmp $+2
            mov [edi], ax
            add edi, 2
            loop .readw
        ret

write_disk:

    ; 设置读写扇区的数量
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    inc dx; 0x1f3
    mov al, cl; 起始扇区的前八位
    out dx, al

    inc dx; 0x1f4
    shr ecx, 8
    mov al, cl; 起始扇区的中八位
    out dx, al

    inc dx; 0x1f5
    shr ecx, 8
    mov al, cl; 起始扇区的高八位
    out dx, al

    inc dx; 0x1f6
    shr ecx, 8
    and cl, 0b1111; 将高四位置为 0

    mov al, 0b1110_0000;
    or al, cl
    out dx, al; 主盘 - LBA 模式

    inc dx; 0x1f7
    mov al, 0x30; 写硬盘
    out dx, al

    xor ecx, ecx; 将 ecx 清空
    mov cl, bl; 得到读写扇区的数量

    .write:
        push cx; 保存 cx
        call .writes; 写一个扇区
        call .waits; 等待硬盘繁忙结束
        pop cx; 恢复 cx
        loop .write

    ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx
            jmp $+2; nop 直接跳转到下一行
            jmp $+2; 一点点延迟
            jmp $+2
            and al, 0b1000_0000
            cmp al, 0b0000_0000
            jnz .check
        ret

    .writes:
        mov dx, 0x1f0
        mov cx, 256; 一个扇区 256 字
        .writew:
            mov ax, [edi]
            out dx, ax
            jmp $+2; 一点点延迟
            jmp $+2
            jmp $+2
            add edi, 2
            loop .writew
        ret


print:
    mov ah, 0x0e

.continue:
    mov al, [si]
    cmp al, 0x00
    jz .done
    int 0x10
    inc si
    jmp .continue

.done:
    ret

greeting:
    db "Hello, LOS!", 0x0a, 0x0d, 0x00

times 510 - ($ - $$) db 0x00
db 0x55, 0xaa
