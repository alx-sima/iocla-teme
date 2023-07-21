;; Copyright (C) 2023 Alexandru Sima (312CA)

section .text
	global vectorial_ops

;; ========================================================================== ;;
;; void vectorial_ops(int *s, int A[], int B[], int C[], int n, int D[])
;  
;  Compute the result of s * A + B .* C, and store it in D. n is the size of
;  A, B, C and D. n is a multiple of 16. The result of any multiplication will
;  fit in 32 bits. Use MMX, SSE or AVX instructions for this task.

vectorial_ops:
	push		rbp
	mov		rbp, rsp

	; rdi - &s
	; rsi - A
	; rdx - B
	; rcx - C
	; r8  - n
	; r9  - D

	push rdi

	movss xmm0, [rdi]				;
	shufps xmm0, xmm0, 0x00			; xmm0 = [s s s s];

	xor	rax, rax					; i = 0;

sse_loop:							; do {
	movdqu xmm1, [rsi + 4 * rax] 	; 	load A
	pmulld xmm1, xmm0				; 	xmm1 = s * A;
	

	movdqu	xmm2, [rdx + 4 * rax]	; 	load B
	movdqu	xmm3, [rcx + 4 * rax]	; 	load C
	pmulld xmm3, xmm2				; 	xmm3 = B .* C;

	vpaddd		xmm2, xmm1, xmm3 	; 	xmm2 = s * A + B .* C;
	movdqu	[r9 + 4 * rax], xmm2	; 	D = xmm2;

	add		rax, 4					; i += 4;
	cmp		rax, r8					;
	jl		sse_loop				; } while (i < n);

	leave
	ret
