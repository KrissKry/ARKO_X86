section .text

global mul_matrices
; dims in   %rdi
; m1 in     %rsi
; m2 in     %rdx -> move to r8
; res in    %rcx
mul_matrices:
    push    rbp
    mov     rbp, rsp

    mov     r8, rdx 
;rdx gets reset @ mul/div, so content is moved to r8

; mul algorithm:
; L1 from beginning of M1 to M1_Y                                                               (current_m1_y)
;	L2 from beginning of M2 to M2_X                                                             (current_m2_x)
;		L3 from 0 to M1_X | M2_Y (equal)                                                        (k)
;			m_out[counter] += M1[current_m1_y * m1_x + k] * M2[current_m2_x + m2_x * k ]

; l1 counter in r15d, cmp[rdi]
; l2 counter in r14d, cmp[rdi+12]
; l3 counter in r13d, cmp[rdi+4]
;[rcx] += rsi[r15d*[rdi+4] + r13d] * r8[[rdi+12]* r13d]

    xor     r15d, r15d
    
loop_1:
    
    xor     r14d, r14d      ; r14d=0

loop_2:
    
    xor     r11d, r11d      ; m_out[counter] = 0
    xor     r13d, r13d      ; k  ==  r13d=0

loop_3:
    
    mov     eax, [rdi+4]    ; load m1_x to eax
    mul     r15d            ; multiply m1_x * current_m1_y
    mov     r9d, eax        ; store current_m1_y*m1_x in r9d
    add     r9d, r13d       ; add k
    shl     r9d, 2          ; mul M1[index*4] (sizeof(int)) for correct position

    mov     eax, [rdi+12]   ; load m2_x to eax
    mul     r13d            ; multiply m2_x * k
    mov     r10d, eax       ; store m2_x * k in r10d
    add     r10d, r14d      ; add current_m2_x
    shl     r10d, 2         ; mul M2[index*4]

    mov     r9d, [rsi+r9]   ; load int from M1 from correct index
    mov     eax, [r8+r10]   ; load int from M2
    mul     r9d             ; multiply values from M1, M2

    add     r11d, eax       ; m_out[counter] += M1[index] * M2[index]
    
    inc     r13d            ; increase counter (k)
    cmp     r13d, [rdi+4]   ; if k == M1_X
    jne     loop_3

loop_3_continue:

    mov     [rcx], r11d     ; store m_out[counter] calculated in above loop to output matrix (res)
    add     rcx, 4          ; increase pointer in res

loop_2_continue:

    inc     r14d            ; increase current_m2_x
    cmp     r14d, [rdi+12]  ; if current_m2_x == M2_X
    jne     loop_2
    
loop_1_continue:

    inc     r15d            ; increase current_m1_y
    cmp     r15d, [rdi]
    jne     loop_1

exit:

    mov     rsp, rbp
    pop     rbp
    ret