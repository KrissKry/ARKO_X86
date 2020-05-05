section .text

global det_matrix
; dims in   %rdi
; m1 in     %rsi
; res in     %rdx -> move to r8
det_matrix:
    push    rbp
    mov     rbp, rsp

    mov     r8, rdx

    mov     ecx, [rdi]
    cmp     ecx, 2
    jg      det_3x3
    jl      det_1x1
    ;je      det_2x2

; [0][1]
; [2][3]
det_2x2:
    mov     eax, [rsi] ;[0]
    mov     r15d, [rsi+12] ;[3]
    mul     r15d
    mov     r15d, eax

    mov     eax, [rsi+4]
    mov     r14d, [rsi+8]
    mul     r14d
    mov     r14d, eax
    sub     r15d, r14d

    mov     [r8], r15
    jmp     exit

det_1x1:
    ;mov    [r8], [rsi]
    mov     eax, [rsi] 
    mov     [r8], eax
    jmp     exit

det_3x3:
; [0][1][2]
; [3][4][5]
; [6][7][8]
; mul by 4 to get correct index 
; [0][4][8]+[1][5][6]+[2][3][7]-[2][4][6]-[0][5][7]-[8][1][3]

    ;[0][4][8]
    mov     eax, [rsi]
    mov     r15d, [rsi+16]
    mul     r15d
    mov     r15d, [rsi+32]
    mul     r15d
    mov     r9d, eax

    ;[1][5][6]
    mov     eax, [rsi+4]
    mov     r15d, [rsi+20]
    mul     r15d
    mov     r15d, [rsi+24]
    mul     r15d
    add     r9d, eax

    ;[2][3][7]
    mov     eax, [rsi+8]
    mov     r15d, [rsi+12]
    mul     r15d
    mov     r15d, [rsi+28]
    mul     r15d
    add     r9d, eax

    ;[2][4][6]
    mov     eax, [rsi+8]
    mov     r15d, [rsi+16]
    mul     r15d
    mov     r15d, [rsi+24]
    mul     r15d
    mov     r10d, eax

    ;[5][7][0]
    mov     eax, [rsi+20]
    mov     r15d, [rsi+28]
    mul     r15d
    mov     r15d, [rsi]
    mul     r15d
    add     r10d, r15d

    ;[8][1][3]
    mov     eax, [rsi+32]
    mov     r15d, [rsi+4]
    mul     r15d
    mov     r15d, [rsi+12]
    mul     r15d
    add     r10d, r15d

    sub     r9d, r10d
    mov     [r8], r9

exit:
    mov     rsp, rbp
    pop     rbp
    ret
