[org 0x7c00]

mov ax, 3
int 0x10

;初始化段寄存器
mov ax, 0x00
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

; 往显存写Hello
mov ax, 0xb800
mov ds, ax
mov byte[0], 'H'
mov byte[2], 'e'
mov byte[4], 'l'
mov byte[6], 'l'
mov byte[8], 'o'
mov byte[10], '!'

; 阻塞
jmp $

times 510 - ($ - $$) db 0x00
db 0x55, 0xaa