[org 0x1000]

dw 0xdead

xchg bx, bx

mov si, loading
call print

jmp $


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