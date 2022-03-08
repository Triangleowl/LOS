
[org 0x7c00]

; why call 0x10 ???
mov ax, 0x03
int 0x10


mov ax, 0x00
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00


xchg bx, bx

mov si, greeting
call print

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
    db "Hello, LOS", 0x0a, 0x0d, 0x00

times 510 - ($ - $$) db 0x00
db 0x55, 0xaa
