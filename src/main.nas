; vim: set ft=nasm:
ORG 0x7c00
CPU 8086

; main

start:
    mov al,[dim]
    inc al
    cmp al,20
    jl dim_fine
    mov al,3
dim_fine:
    mov [dim],al
	xor bh, bh
    xor ax,ax
    inc ax
    mov [col],ax
right:
    mov [col],al
    call print_circle

    mov al,byte [col]
    inc al
    cmp al,[dim]
    jne right

down:
    mov al,[row]
    inc al
    cmp al,[dim]
    je left

    mov [row],al
    call print_circle
    jmp down

left:
    mov al,[col]
    dec al
    cmp al,0xff
    je up

    mov [col],al
    call print_circle
    jmp left

up:
    mov al,[row]
    dec al
    cmp al,0xff
    je start

    mov [row],al
    call print_circle
    jmp up

    cli
    hlt

; funcs

print_top_bottom:
    mov al,0xdb
    call print_repeating
    call print_crlf
    ret

print_crlf:
    mov si,crlf
    jmp print

print_repeating:
    mov cl,[dim]
    mov ah,0x0e
next_tb:
    int 0x10
    dec cl
    jnz next_tb
    ret

print_left_right:
    mov al, 0xdb
    call print_char

    mov al, ' '
    call print_repeating

    call cur_pos
    dec dl
    dec dl
    call pos_cur

    mov al, 0xdb
    call print_char

    jmp print_crlf

print_circle:
    xor dx, dx
    call pos_cur

    call print_top_bottom

    xor al,al
next_left_right:
    mov [cur_left_right],al
    call print_left_right
    mov al,[cur_left_right]
    inc al
    mov ah,[dim]
    dec ah
    dec ah
    cmp al,ah
    jne next_left_right

    call print_top_bottom

    mov dx,[col]
    call print_spinny

    jmp wait_frame

; si = string pointer
_next_print:
	int 0x10
_begin_print:
    lodsb
    or al,al
    jnz _next_print
    ret
print:
    mov ah, 0x0e
    jmp _begin_print

; dx = row/col
pos_cur:
    mov ah, 0x02
    int 0x10
    ret

; dx = row/col
cur_pos:
    mov ah, 0x03
    int 0x10
    ret

wait_frame:
    xor cx,cx
    mov dx,0x8235
    mov ah,0x86
    int 0x15
    ret

; dx = row/col
print_spinny:
    call pos_cur

    mov al,' '
    call print_char

    call cur_pos

    or dh,dh
    jz dh_inc
    mov al,[dim]
    dec al
    cmp dh,al
    jne dh_fine
    dec dh
    jmp dh_fine
dh_inc:
    inc dh
dh_fine:

    dec dl
    or dl,dl
    jz dl_inc
    cmp dl,al
    jne dl_fine
    dec dl
    jmp dl_fine
dl_inc:
    inc dl
dl_fine:

    call pos_cur

    mov al,0xdb
    jmp print_char

; al = char
print_char:
    mov ah,0x0e
    int 0x10
    ret

; vars

col:
    db 0x00
row:
    db 0x00

dim:
    db 0x03

cur_left_right:
    db 0x00

; consts

crlf:
    db 0x0d,0x0a,0x00

; to check code size
%if 1
    ; black magic whoo
    times   446 - ($-$$)  db  0

    ; all parts emptisch
    times   16 db 0
    times   16 db 0
    times   16 db 0
    times   16 db 0

    dw 0xaa55
%endif
