;; Copyright (C) 2023 Alexandru Sima (312CA)

section .rodata
	vowels: db "aeiouu", 0x0
	vowels_len: equ $ - vowels

section .text
	global reverse_vowels

;; ========================================================================== ;;
;;	void reverse_vowels(char *string)
;	Cauta toate vocalele din string-ul `string` si afiseaza-le
;	in ordine inversa. Consoanele raman nemodificate.
;	Modificare se va face in-place
reverse_vowels:
	push ebp				; enter 0, 0
	push esp				;
	pop ebp					;

	push ebx				; save registers
	push esi				;
	push edi				;

	push dword [ebp + 8]	; 
	pop esi					; string

get_vowels:
	cmp byte [esi], 0		; while (*string) {
	je string_end			;

	push word [esi]			;
	pop ax					; 	needle = *string;

	push vowels				;
	pop edi					; 	haystack = vowels;

	push vowels_len 		;
	pop ecx					; 	haystack_len = vowels_len;

	repne scasb				; 	haystack = "strchr"(haystack, needle);
	cmp byte [edi], 0		; 	if (*haystack == '\0')
	je not_vowel			;
	push word [esi]			;		push needle;

not_vowel:
	inc esi					; 	string++;
	jmp get_vowels			; }

string_end:
	push dword [ebp + 8]	;
	pop esi					; string

next_char_2:
	cmp byte [esi], 0		; while (*string) {
	je reverse_vowels_end	;
	
	push word [esi]			;
	pop ax					; 	needle = *string;
	
	push vowels				;
	pop edi					; 	haystack = vowels;

	push vowels_len 		;
	pop ecx					; 	haystack_len = vowels_len;

	repne scasb				; 	haystack = "strchr"(haystack, needle);
	cmp byte [edi], 0		; 	if (*haystack == '\0') 
	je not_vowel_2			;

	pop word ax				; 		*string = needle;
	xor al, byte [esi]		;
	xor byte [esi], al		;
	xor al, byte [esi]		;
	
not_vowel_2:
	inc esi					; 	string++;
	jmp next_char_2			; }

reverse_vowels_end:
	pop edi					; restore registers
	pop esi					;	
	pop ebx					;

	push ebp				; leave
	pop esp					;
	pop ebp					;
	ret