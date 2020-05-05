section .text

global mul_matrices
; dims in   %rdi
; m1 in     %rsi
; m2 in     %rdx -> move to r8
; res in    %rcx
mul_matrices:

; preserve framepointer etc xd (Wtf)
    push    rbp
    mov     rbp, rsp

    mov     r8, rdx ;rdx gets reset @ mul/div
;dims[0] @ [rdi]    rows M1y
;dims[1] @ [rdi+4]  columns M1x
;dims[2] @ [rdi+8]  rows M2y
;dims[3] @ [rdi+12] columns M2x
;														#
; L1 from beginning of M1 to M1_Y 	$t5	 currentm1y								#
;														#
;	#L2 from beginning of M2 to M2_X 	$t6		 currentm2x						#
;														#
;		#L3 from 0 to M1_X | M2_Y (equal)  	k						#
;														#
;			#m_out[counter] += M1[current_m1_y * m1_x + k] * M2[current_m2_x + m2_x * k ]		#
;	

; l1 counter in r15d, cmp[rdi]
; l2 counter in r14d, cmp[rdi+12]
; l3 counter in r13d, cmp[rdi+4]
;[rcx] += [rsi+ r15d*[rdi+4] + r13d] * [r8 + [rdi+12]* r13d]
    mov     r15d, 0
    mov     r11d, 0
loop_1:
    cmp     r15d, [rdi]
    je      loop_1_continue ;exit
    xor     r14d, r14d      ; r14d=0

loop_2:
    cmp     r14d, [rdi+12]
    je      loop_2_continue
    xor     r11d, r11d      ; m_out[counter] = 0
    xor     r13d, r13d      ; k  ==  r13d=0
    ;zero out different vals used in l3

loop_3:
    cmp     r13d, [rdi+4]
    je      loop_3_continue

    mov     eax, [rdi+4]    ; load m1_x to eax
    mul     r15d            ; multiply m1_x * current_m1_y
    mov     r9d, eax        ; store current_m1_y*m1_x in r9d
    add     r9d, r15d       ; add k
    shl     r9d, 2          ; mul M1[index*4] (sizeof(int)) for correct position


    mov     eax, [rdi+12]   ; load m2_x to eax
    mul     r15d            ; multiply m2_x * k
    mov     r10d, eax       ; store m2_x * k in r10d
    add     r10d, r14d      ; add current_m2_x
    shl     r10d, 2         ; mul M2[index*4]

    mov     r9d, [rsi+r9]  ; load int from M1 from correct index
    mov     eax, [r8+r10]  ; load int from M2
    mul     r9d             ; multiply values from M1, M2

    add     r11d, eax       ; m_out[counter] += M1[index] * M2[index]
    
    inc     r13d
    jmp     loop_3

loop_3_continue:
    mov     [rcx], r11d     ; store m_out[counter] calculated in above loop to output matrix (res)
    inc     r14d            ; increase current_m2_x
    add     rcx, 4          ; increase pointer in res
    jmp     loop_2


loop_2_continue:

    inc     r15d
    jmp     loop_1

loop_1_continue:
exit:
    mov     rsp, rbp
    pop     rbp
    ret


