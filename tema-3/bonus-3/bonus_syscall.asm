;; Copyright (C) 2023 Alexandru Sima (312CA) 

section .rodata:
	; taken from fnctl.h
	O_RDONLY	equ 00000
	O_WRONLY	equ 00001
	O_TRUNC		equ 01000
	O_CREAT		equ 00100
	S_IRUSR		equ 00400
	S_IRGRP		equ 00040
	S_IROTH		equ 00004

	BUFSIZ		equ 8192
	MARCO		db 'Marco', 0x0
	POLO		db 'Polo', 0x0

section .text
	global	replace_marco

	extern strlen
	extern strstr

;; ========================================================================== ;;
;; void replace_marco(const char *in_file_name, const char *out_file_name)
;  it replaces all occurences of the word "Marco" with the word "Polo",
;  using system calls to open, read, write and close files.

replace_marco:
	push ebp
	mov ebp, esp

	push ebx								; save registers
	push esi								;
	push edi								;

	sub esp, BUFSIZ							; buffer[BUFIZ]

	mov eax, 5								;
	mov ebx, [ebp + 8]						; in_file_name
	mov ecx, O_RDONLY						;
	xor edx, edx							;
	int 0x80								; in_file_fd = open(in_file_name, flags, 0);

	cmp eax, 0								; if (in_file_fd < 0)
	jl end_replace_marco_error				;	exit(-in_file_fd);

	mov esi, eax							; in_file_fd

	mov eax, 5
	mov ebx, [ebp + 12]						; out_file_name
	mov ecx, O_WRONLY | O_TRUNC | O_CREAT	;
	mov edx, S_IRUSR | S_IRGRP | S_IROTH	;
	int 0x80								; out_file_fd = open(out_file_name, flags, perms);

	cmp eax, 0								; if (out_file_fd < 0)
	jl end_replace_marco_error				;	exit(-out_file_fd);

	mov edi, eax							; out_file_fd

read_buffer:								; while (1) {
	mov eax, 3								;
	mov ebx, esi							;
	lea ecx, [ebp - BUFSIZ]					;
	mov edx, BUFSIZ							;
	int 0x80								; 	len = read(in_file_fd, buffer, BUFSIZ);

	test eax, eax							; 	if (len == 0)
	jz end_reading							;   	break;

	lea eax, [ebp - BUFSIZ]					;
	push eax								; 	save buffer position
find_next_marco:							; 	while (1) {
	mov eax, [esp]							; 		retreive buffer position

	push MARCO								;
	push eax								;
	call strstr								; 		position = strstr(buffer, MARCO);
	add esp, 8								;

	test eax, eax							; 		if (!position)
	jz no_more_marcos						;			break;

	mov edx, eax							;
	pop ecx									;  		retrieve buffer position
	sub edx, ecx							; 		len = position - buffer;

	add eax, 5								;
	push eax								; 		save new buffer position (after Marco)

	mov eax, 4								;
	mov ebx, edi							;
	int 0x80								; 		write(out_file_fd, buffer, len);

	mov eax, 4								;
	mov ebx, edi							;
	mov ecx, POLO							;
	mov edx, 4								;
	int 0x80								;		write(out_file_fd, POLO, 4);
	
	jmp find_next_marco						; 	}

no_more_marcos:
	call strlen								;
	pop ecx									;
	mov edx, eax							;	len = strlen(buffer);

	mov eax, 4								;
	mov ebx, edi							;
	int 0x80								;	write(out_file_fd, buffer, len);

	jmp read_buffer							; }

end_reading:
	mov eax, 6								;
	mov ebx, edi							;
	int 0x80								; close(out_file_fd);

	mov eax, 6								;
	mov ebx, esi							;
	int 0x80								; close(in_file_fd);


	add esp, BUFSIZ							; deallocate 8k buffer on the stack

	xor eax, eax							; return 0;

	pop edi									; restore registers
	pop esi									;
	pop ebx									;
	
	leave
	ret

end_replace_marco_error:
	mov ebx, eax							;
	neg ebx									;
	mov eax, 1								;
	int 0x80								; exit(ERRNO); /* No need to return. */
