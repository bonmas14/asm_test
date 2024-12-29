default rel
section .text
global _start

extern MessageBoxA
extern ExitProcess

_start:
    and rsp, -16
    mov rcx, 0
    lea rdx, [rel text]
    lea r8, [rel caption]
    mov r9, 0
    
    sub rsp, 32
    call MessageBoxA
    add rsp, 32

    xor rcx, rcx

    call ExitProcess

section .data
text: db 'hello', 0
caption: db 'hello!', 0
