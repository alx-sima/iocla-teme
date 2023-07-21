;; Copyright (C) 2023 Alexandru Sima (312CA)

section .text
	global intertwine

;; ========================================================================== ;;
;; void intertwine(int *v1, int n1, int *v2, int n2, int *v);
;
;  Take the 2 arrays, v1 and v2 with varying lengths, n1 and n2,
;  and intertwine them
;  The resulting array is stored in v
intertwine:
	push	rbp
	mov 	rbp, rsp

	; rdi = v1
	; rsi = n1
	; rdx = v2
	; rcx = n2
	; r8  = v

intertwine_both_vectors:			; while (n1 && n2) {
	test rsi, rsi					;
	jz intertwine_both_vectors_end	;
	test rcx, rcx					;
	jz intertwine_both_vectors_end	;

	mov eax, [rdi]					;
	mov [r8], eax					; 	v[0] = *v1;

	mov eax, [rdx]					;
	mov [r8 + 4], eax				; 	v[1] = *v2;

	add r8, 8						; 	v += 2;
	add rdi, 4						; 	v1++;
	add rdx, 4						; 	v2++;

	dec rsi							; 	n1--;
	dec rcx							; 	n2--;
	jmp intertwine_both_vectors		; }

intertwine_both_vectors_end:

	mov rax, rcx		; save n2

	mov rcx, rsi		; n1
	mov rsi, rdi		; v1
	mov rdi, r8			; v

	rep movsd			; memcpy(v, v1, n1);

	mov rcx, rax		; n2
	mov rsi, rdx		; v2

	rep movsd			; memcpy(v, v2, n2);

	leave
	ret
