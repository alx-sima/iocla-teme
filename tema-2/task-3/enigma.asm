%include "../include/io.mac"

;; defining constants, you can use these as immediate values in your code
LETTERS_COUNT EQU 26

section .data
    extern len_plain

section .text
    global rotate_x_positions
    global enigma


;; ========================================================================== ;;
;; void rotate_x_positions(int x, int rotor, char config[10][26], int forward)
rotate_x_positions:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; x
    mov ebx, [ebp + 12] ; rotor
    mov ecx, [ebp + 16] ; config (address of first element in matrix)
    mov edx, [ebp + 20] ; forward
    ;; DO NOT MODIFY
    ;; FREESTYLE STARTS HERE

    test edx, edx               ; if (forward == 0) {
    jnz select_rotor_start      ;
    neg eax                     ;   x = 26 - x;
    add eax, LETTERS_COUNT      ; }

select_rotor_start:
    test ebx, ebx               ; while (rotor != 0) {
    jz select_rotor_end         ;
    add ecx, 2 * LETTERS_COUNT  ;   config += 2 * 26; /* sare 2 randuri */
    dec ebx                     ;   rotor--;
    jmp select_rotor_start      ; }

select_rotor_end:
    push eax                    ;
    push ecx                    ;
    call rotate                 ; rotate(config, x);

    pop ecx                     ;
    add ecx, LETTERS_COUNT      ;
    push ecx                    ;
    call rotate                 ; rotate(config + 26, x);
    add esp, 8                  ;

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY


;; ========================================================================== ;;
;; void enigma(char *plain, char key[3], char notches[3], char config[10][26], 
;;             char *enc);
enigma:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; plain (address of first element in string)
    mov ebx, [ebp + 12] ; key
    mov ecx, [ebp + 16] ; notches
    mov edx, [ebp + 20] ; config (address of first element in matrix)
    mov edi, [ebp + 24] ; enc
    ;; DO NOT MODIFY
    ;; FREESTYLE STARTS HERE

    mov esi, [len_plain]; i = len_plain;

traverse_string:        ; do {
    pusha               ;   save registers

    push edx            ;
    push ecx            ;
    push ebx            ;
    push eax            ;
    call encrypt_letter ;   *enc = encrypt_letter(plain, key, notches, config);
    add esp, 16         ;
    mov [edi], al       ;

    popa                ;   restore registers

    inc eax             ;   plain++;
    inc edi             ;   enc++;

    dec esi             ;
    test esi, esi       ;
    jnz traverse_string ; } while (--i);
    
    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY


;; ========================================================================== ;;
;; void rotate(char *array, int distance)
rotate:
    enter LETTERS_COUNT, 0      ; buffer[26]

    mov edx, [ebp + 8]          ; array
    mov ebx, [ebp + 12]         ; distance

    xor ecx, ecx                ; i = 0;

rotate_char:                    ; do {
    lea edi, [ecx + ebx]        ;   new_index = i + distance;
    cmp edi, LETTERS_COUNT      ;   if (new_index >= 26) {
    jl index_in_bounds          ;       new_index -= 26;
    sub edi, LETTERS_COUNT      ;   }

index_in_bounds:
    mov al, [edx + ecx]         ;   temp = array[i];
    mov [esp + edi], al         ;   buffer[new_index] = temp;

    inc ecx                     ;   i++;
    cmp ecx, LETTERS_COUNT      ;
    jl rotate_char              ; } while  (i < 26);
                                
    mov edi, edx                ; 
    mov esi, esp                ;
    mov ecx, LETTERS_COUNT      ;
    rep movsb                   ; memcpy(array, buffer, 26);

    leave
    ret


;; ========================================================================== ;;
;; char encrypt_letter(char letter, char key[3], char notches[3], 
;;                     char config[10][26])
encrypt_letter:
    enter 0, 0
    push ebx                            ; save ebx

    mov ebx, [ebp + 12]                 ; key
    mov ecx, [ebp + 16]                 ; notches
    mov edx, [ebp + 20]                 ; config 

    push edx                            ;
    push ecx                            ;
    push ebx                            ;
    call shift_rotor                    ; shift_rotor(key, notches, config);
    add esp, 12                         ;
    
    mov eax, [ebp + 8]                  ; letter

    movzx eax, byte [eax]               ; letter = *letter;
    sub eax, 'A'                        ; letter -= 'A';

    lea ebx, [edx + 8 * LETTERS_COUNT]  ; plugboard = config[8]; 

    push 0                              ;
    push eax                            ;
    push ebx                            ; 
    call traverse_component             ; letter = traverse_component(
    add esp, 12                         ;               plugboard, letter, 0);

    mov edx, [ebp + 20]                 ; config
    lea ebx, [edx + 4 *LETTERS_COUNT]   ; rotor = config[4];
    mov ecx, 2                          ; i = 2;

traverse_r_to_l:                        ; do {
    push ecx;                           ; save ecx

    push 1                              ;
    push eax                            ;
    push ebx                            ;
    call traverse_component             ;   letter = traverse_component(
    add esp, 12                         ;               rotor, letter, 1);

    sub ebx, 2 * LETTERS_COUNT          ;   rotor = config[2 * (i - 1)];
    
    pop ecx                             ;   restore ecx
    dec ecx                             ;   i--;
    cmp ecx, 0                          ;
    jge traverse_r_to_l                 ; } while (i >= 0);

    mov edx, [ebp + 20]                 ; config
    lea ebx, [edx + 6 * LETTERS_COUNT]  ; reflector = config[6];

    push 0                              ;
    push eax                            ;
    push ebx                            ;
    call traverse_component             ; letter = traverse_component(
    add esp, 12                         ;               reflector, letter, 0);

    mov ebx, [ebp + 20]                 ; rotor = config[0];
    xor ecx, ecx                        ; i = 0;

traverse_l_to_r:                        ; do {
    push ecx                            ;   save ecx

    push 0                              ;
    push eax                            ;
    push ebx                            ;
    call traverse_component             ;   letter = traverse_component(
    add esp, 12                         ;               rotor, letter, 0);

    add ebx, 2 * LETTERS_COUNT          ;   rotor = config[2 * (i + 1)];

    pop ecx                             ;   restore ecx
    inc ecx                             ;   i++;
    cmp ecx, 2                          ;
    jle traverse_l_to_r                 ; } while (i <= 2);

    mov edx, [ebp + 20]                 ; config
    lea ebx, [edx + 8 * LETTERS_COUNT]  ; plugboard = config[8];

    push 0                              ;
    push eax                            ;
    push ebx                            ;
    call traverse_component             ; letter = traverse_component(
    add esp, 12                         ;               plugboard, letter, 0);

    pop ebx                             ; restore ebx
    add eax, 'A'                        ; letter += 'A';
    leave                               ; return letter;
    ret


;; ========================================================================== ;;
;; void shift_rotor(char key[3], char notches[3], char config[10][26])
shift_rotor:
    enter 0, 0
    push ebx                            ; save ebx

    mov ebx, [ebp + 8]                  ; key
    mov ecx, [ebp + 12]                 ; notches
    mov edx, [ebp + 16]                 ; config


    mov al, [ebx + 1]                   ;
    cmp al, byte [ecx + 1]              ; if (key[1] == notches[1])
    je rotate_1st_rotor                 ;   goto rotate_1st_rotor;
    
    mov al, [ebx + 2]                   ;
    cmp al, byte [ecx + 2]              ; if (key[2] == notches[2])
    je rotate_2nd_rotor                 ;   goto rotate_2nd_rotor;
    jmp rotate_3rd_rotor                ; else goto rotate_3rd_rotor;

rotate_1st_rotor:

    push 0                              ;
    push edx                            ;
    push 0                              ;
    push 1                              ;
    call rotate_x_positions             ; rotate_x_positions(1, 0, config, 0);
    add esp, 16                         ;

    inc byte [ebx]                      ; key[0]++;
    
rotate_2nd_rotor:
    push 0                              ;
    push edx                            ;
    push 1                              ;
    push 1                              ;
    call rotate_x_positions             ; rotate_x_positions(1, 1, config, 0);
    add esp, 16                         ;

    inc byte[ebx + 1]                   ; key[1]++;

rotate_3rd_rotor:
    push 0                              ;
    push edx                            ;
    push 2                              ;
    push 1                              ;
    call rotate_x_positions             ; rotate_x_positions(1, 2, config, 0);
    add esp, 16                         ;

    inc byte [ebx + 2]                  ; key[2]++;

    xor ecx, ecx                        ; i = 0;

check_letters:                          ; do {
    mov al, [ebx + ecx]                 ;
    cmp al, 'Z'                         ; if (key[i] > 'Z')
    jle letter_in_alphabet              ;   
    sub byte [ebx + ecx], LETTERS_COUNT ;   key[i] -= 26;

letter_in_alphabet:
    inc ecx                             ;   i++;
    cmp ecx, 3                          ;
    jl check_letters                    ; } while (i < 3);

    pop ebx ; restore ebx
    leave
    ret


;; ========================================================================== ;;
;; int traverse_component(char component[2][26], int index, int row)
traverse_component:
    enter 0, 0
    push ebx                        ; save registers
    push esi                        ;
    push edi                        ;

    mov ebx, [ebp + 12]             ; index
    mov esi, [ebp + 16]             ; row

    xor ecx, ecx                    ; i = 0;

    mov edx, [ebp + 8]              ; component[0]
    lea eax, [edx + LETTERS_COUNT]  ; component[1]

    test esi, esi                   ; if (row) {
    cmovnz edi, edx                 ;   other_row = component[0];
    cmovnz esi, eax                 ;   target = component[1]; }
                                    ; else {
    cmovz edi, eax                  ;   other_row = component[1];
    cmovz esi, edx                  ;   target = component[0]; }

    add esi, ebx                    ; target = row[index];

search_letter:                      ; do {
    mov al, [edi + ecx]             ;   if (other_row[i] == target) {
    cmp al, byte [esi]              ;       return i;
    je found_letter                 ;   }

    inc ecx                         ;   i++;
    jmp search_letter               ; } while (1);

found_letter:
    mov eax, ecx                    ; return i;
    pop edi                         ; restore registers
    pop esi                         ;
    pop ebx                         ;
    leave
    ret
