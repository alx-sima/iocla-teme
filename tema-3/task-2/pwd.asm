;; Copyright (C) 2023 Alexandru Sima (312CA)

section .data
	back db "..", 0
	curr db ".", 0
	slash db "/", 0
	; declare global vars here

section .text
	global pwd
	extern strcat
	extern strcmp

;; ========================================================================== ;;
;;	void pwd(char **directories, int n, char *output)
;	Adauga in parametrul output path-ul rezultat din
;	parcurgerea celor n foldere din directories
pwd:
	enter 0, 0

	push ebx			; save preserved registers
	push esi			;
	push edi			;

	mov edi, esp		; file_stack_bottom

	mov esi, [ebp + 8]	; directories
	mov ecx, [ebp + 12] ; n

parse_dirs:				; do {
	mov ebx, ecx		; save ecx

	push dword [esi]	;
	push curr			;
	call strcmp			; 	
	add esp, 8			;
	test eax, eax		;	if (!strcmp(*directories, curr))
	jz skip_dir			;		continue;

	push dword [esi]	;
	push back			;
	call strcmp			;
	add esp, 8			;
	test eax, eax		; 	if (!strcmp(*directories, back))
	jnz skip_pop		;

	cmp esp, edi		; 		if (!stack.is_empty()) {
	je skip_pop			;
	add esp, 4			; 			stack.pop();
	jmp skip_dir		;			continue; }

skip_pop:

	push dword [esi]	; 	push *directories

skip_dir:
	add esi, 4			; 	directories += sizeof(char *);
	mov ecx, ebx		; 	restore ecx
	loop parse_dirs		; } while (--n);

	mov ebx, edi		; file_stack_bottom
	mov esi, edi		; curr_dir
	mov edi, [ebp + 16]	; output

add_dirs:				; do {
	sub esi, 4			;	curr_dir += sizeof(char *);

	push slash			;
	push edi			;
	call strcat			; 	strcat(output, slash);
	add esp, 8			;

	push dword [esi]	;
	push edi			;
	call strcat			; 	strcat(output, *curr_dir);
	add esp, 8			;
	
	cmp esi, esp		;
	jne add_dirs		; } while (curr_dir != stack.top());

	push slash			;
	push edi			;
	call strcat			; strcat(output, slash);
	add esp, 8			;

	mov esp, ebx		; restore preserved registers
	pop edi				;
	pop esi				;
	pop ebx				;

	leave
	ret