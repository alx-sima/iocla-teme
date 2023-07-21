;; Copyright (C) 2023 Alexandru Sima (312CA)

section .rodata
	;; Numarul de termeni ai seriei exponentiale.
	;; Cu cat mai mare, cu atat este acuratetea mai mare
	nr_iterations dd 11

section .text
	global do_math

;; ========================================================================== ;;
;; float do_math(float x, float y, float z)
;  returns x * sqrt(2) + y * sin(z * PI * 1/e)
do_math:
	push	ebp
	mov 	ebp, esp
	
	sub esp, 4				; allocate space for 1 var

	mov ax, 1				; k = 1
	xor ecx, ecx			; i = 0
	mov edx, [nr_iterations]; n = nr_iterations
	
	fldz					; series = 0;

exponential_series:			; do {
	fld1					; 	load 1

	mov [ebp-4], eax		; 	store k
	fild dword [ebp - 4]	; 	load k
	fdivp					; 	1 / k
	faddp					; 	series += 1 / k;

	inc ecx					; 	i++;

	imul eax, ecx			; 	k *= (-i);
	neg eax					;

	cmp ecx, edx			;
	jl exponential_series	; } while (i < n);

	fldpi					; load pi into st0
	fmulp					; st0 = pi / e;

	fld dword [ebp + 16]	; load z into st0
	fmulp					; st0 = z * pi / e;
	fsin					; st0 = sin(z * pi / e);

	fld dword [ebp + 12]	; load y into st0
	fmulp					; st0 = y * sin(z * pi / e);

	mov eax, 2
	mov [ebp-4], eax
	
	fild dword [ebp - 4]	; load 2 into st0
	fsqrt					; sqrt(2);

	fld dword [ebp + 8]		; load x into st0
	fmulp					; x * sqrt(2);

	faddp					; st0 = x * sqrt(2) + y * sin(z * pi / e);

	add esp, 4				; delete local variable
	leave
	ret
