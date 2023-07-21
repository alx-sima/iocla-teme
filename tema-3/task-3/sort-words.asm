;; Copyright (C) 2023 Alexandru Sima (312CA)

section .rodata
    delims: db " ,.", 0xa, 0x0

section .text
    global get_words
    global compare_func
    global sort

    extern qsort
    extern strcmp
    extern strlen
    extern strtok


;; ========================================================================== ;;
;; int compare(const void *s1, const void *s2)
compare:
    enter 0, 0
 
    mov edx, [ebp + 12] ;
    push dword [edx]    ;
    call strlen         ; l2 = strlen(s2);
    add esp, 4          ;
    
    push eax            ; save l1

    mov edx, [ebp + 8]  ;
    push dword [edx]    ;
    call strlen         ; l1 = strlen(s1);
    add esp, 4          ;

    pop ecx             ; restore l1

    sub eax, ecx        ;
    jne compare_end     ; if (l1 -= l2) return l1;

    mov eax, [ebp + 8]  ; s1
    mov edx, [ebp + 12] ; s2

    push dword [edx]    ;
    push dword [eax]    ;
    call strcmp         ; return strcmp(s1, s2);
    add esp, 8          ;

compare_end:
    leave
    ret


;; ========================================================================== ;;
;; vpod sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru soratrea cuvintelor 
;  dupa lungime si apoi lexicografic
sort:
    enter 0, 0
    push ebx            ; save ebx
    
    mov edx, [ebp + 8]  ; words
    mov ecx, [ebp + 12] ; number_of_words
    mov ebx, [ebp + 16] ; size

    push compare        ;
    push ebx            ;
    push ecx            ;
    push edx            ;
    call qsort          ; qsort (words, number_of_words, size, compare);
    add esp, 16         ;
    
    pop ebx             ; restore ebx
    leave
    ret


;; ========================================================================== ;;
;; void get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    enter 0, 0
    push esi            ; save registers
    push edi            ;

    mov esi, [ebp + 8]  ; s
    mov edi, [ebp + 12] ; words

    push delims         ;
    push esi            ;
    call strtok         ; word = strtok(s, delims);
    add esp, 8          ;

get_next_word:
    test eax, eax       ; while (word) {
    jz get_words_ret    ;

    mov [edi], eax      ;   *words = word;
    add edi, 4          ;   words += sizeof(char *);

    push delims         ;
    push 0x0            ;
    call strtok         ;   word = strtok(NULL, delims);
    add esp, 8          ;

    jmp get_next_word   ; }


get_words_ret:
    pop edi             ; restore registers
    pop esi             ;
    leave
    ret
