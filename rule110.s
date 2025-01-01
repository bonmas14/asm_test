%define map_size 64
%define output_size (map_size + 2)
%define steps_count 64

section .text
global _start

extern GetStdHandle
extern WriteConsoleA
extern ExitProcess

_start:
    and rsp, -16
    mov rcx, 0xFFFFFFF5 
    
    sub rsp, 32
    call GetStdHandle
    add rsp, 32

    mov [rel std_handle], rax

    lea rax, [rel result_code + map_size]
    mov byte [rax], 13
    add rax, 1
    mov byte [rax], 10

    lea rax, [rel map0]
    add qword rax, (map_size - 1)
    mov byte [rax], 1

    push rbp
    xor rbp, rbp

    .step:
        cmp rbp, steps_count
        jge .exit_loop

        call write
        call run
        call copy

        add rbp, 1
    jmp .step

.exit_loop:
    pop rbp

    xor rcx, rcx

    sub rsp, 32
    call ExitProcess


copy:
    push rbp
    push rax
    push rbx
    xor rbp, rbp

.loop:
    cmp rbp, map_size
    jge .exit_loop

    lea rax, [rel map1]
    add rax, rbp
    mov rbx, [rax] 

    lea rax, [rel map0]
    add rax, rbp

    mov [rax], bl

    add rbp, 1
    jmp .loop
.exit_loop:
    
    pop rbx
    pop rax
    pop rbp

    ret

run:
    push rbp
    xor rbp, rbp

.loop:
    cmp rbp, map_size
    jge .exit_loop

    push r10
    push r11
    push r12

    lea rax, [rel map0]
    add rax, rbp
    mov r11b, [rax] ; center cell

    ; bound checks here
    ; l

    push rbp
    sub rbp, 1
    jl .clear_left
        xor r10, r10
        sub rax, 1
        mov r10b, [rax]
        add rax, 1
    jmp .end_left
    .clear_left:
        xor r10, r10
.end_left:
    pop rbp
    ; r

    push rbp
    add rbp, 1
    cmp rbp, map_size
    jge .clear_right
        xor r12, r12
        add rax, 1
        mov r12b, [rax]
        sub rax, 1
        jmp .end_right
    .clear_right:
        xor r12, r12
.end_right:
    pop rbp

    ; calculate val
    xor r10b, -1
    and r10b, r11b
    xor r11b, r12b
    or r10b, r11b

    lea rax, [rel map1]
    add rax, rbp

    mov [rax], r10b

    pop r12
    pop r11
    pop r10

    add rbp, 1
    jmp .loop
.exit_loop:
    
    pop rbp

    ret

write:
    push rbp
    xor rbp, rbp

.loop:
    cmp rbp, map_size
    jge .exit_loop

    lea rax, [rel map0]
    add rax, rbp

    lea rcx, [rel result_code]
    add rcx, rbp

    xor rdx, rdx
    mov dl, [rax]

    cmp dl, 1
    jz .equal
        mov byte [rcx], ' '
        jmp .end_stmt
    .equal:
        mov byte [rcx], 'x'
    .end_stmt:

    add rbp, 1
    jmp .loop
.exit_loop:
    
    pop rbp

    mov rcx, [rel std_handle]  ; handle
    lea rdx, [rel result_code] ; buffer
    mov r8, output_size        ; number of chars to write
    lea r9, [rel ignore_ptr]   ; out_opt
    sub rsp, 16                ; (alingned to a stack) reserved

    sub rsp, 32
    call WriteConsoleA
    add rsp, 32

    add rsp, 16                ; Who "would know" about that 
    ret

section .data
ignore: db 0

section .bss
map0: resb map_size
map1: resb map_size
ignore_ptr: resb 8
std_handle: resb 8
result_code: resb output_size
