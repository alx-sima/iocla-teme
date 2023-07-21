;; Copyright (C) 2023 Alexandru Sima (312CA)

section .text
	global get_rand
	extern printf


;; ========================================================================== ;;
;; int get_rand(void)
get_rand:
	push ebp
	mov ebp, esp

	push ebx		; save ebp

	rdtsc			; 
	mov ecx, eax	; start_timestamp

rdrand_here:
	rdseed ebx		; generate random number

	rdtsc			; end_timestamp
	sub eax, ecx	; duration = end_timestamp - start_timestamp;

	cmp eax, 10000	; if (duration > 20000) /* empiric determinat */
	ja gdb_detected	; 	return 0;

	mov eax, ebx	; return generated value
	pop ebx			; restore ebp
	leave
	ret

;; V-ati bagat nasul unde nu va fierbe oala!🤥
gdb_detected:
	xor eax, eax	; return 0
	leave
	ret
	