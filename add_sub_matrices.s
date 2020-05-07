section .text

global add_sub_matrices
; dims in   %rdi
; m1 in     %rsi
; m2 in     %rdx
; res in    %rcx
; type in   %r8
add_sub_matrices:

    push    rbp
    mov     rbp, rsp

begin:
    ;move m2 from rdx to r11
    mov     r11, rdx

    ;load dims[0], dims[1]
    mov     eax, [rdi]
    add     rdi, 4
    mov     r15d, [rdi]

    ;mul dims -> result in eax
    mul     r15d

    ;moved to r15
    mov     r15d, eax


    ;sub flag in r12
    mov     r12d, [r8]
   


loop_start:
    ;load values from m1, m2
    mov     r14d, [rsi]
    mov     r13d, [r11]


    cmp     r12d, 0
    jne     loop_sub

    ;add values from m1, m2
    add     r14d, r13d

loop_continue:
    ;store value in res
    mov     [rcx], r14d

    ;increase pointers for m1, m2, res    
    add     rsi, 4
    add     r11, 4
    add     rcx, 4

    ;decrease number of elements to add
    dec     rax

    ;if no more elements are to be processed, exit
    cmp     rax, 0
    jne     loop_start
    jmp     exit

;if flag was set to subtract
loop_sub: 
    sub     r14d, r13d
    jmp     loop_continue

exit:
    mov     rsp, rbp
    pop     rbp
    ret