section .text
    global simple

;; ========================================================================== ;;
;; void simple(int len, char *plain, char *enc_string, int step)
simple:
    ;; DO NOT MODIFY
    push    ebp
    mov     ebp, esp
    pusha

    mov     ecx, [ebp + 8]  ; len
    mov     esi, [ebp + 12] ; plain
    mov     edi, [ebp + 16] ; enc_string
    mov     edx, [ebp + 20] ; step

    ;; DO NOT MODIFY
   
    ;; Your code starts here

string_loop_start:          ; while (1) {
    cmp byte [esi], 0       ;   if (*plain == '\0')
    je string_loop_end      ;       break;

    movzx ax, byte [esi]    ;   chr = *plain;
    add ax, dx              ;   chr += step;
    sub ax, 'A'             ;   chr -= 'A';

    mov bl, 'Z' - 'A' + 1   ; 
    idiv bl                 ; chr %= 'Z' - 'A' + 1;

    add ah, 'A'             ; chr += 'A';
    mov byte [edi], ah      ; *enc_string = chr;

    inc esi                 ; plain++;
    inc edi                 ; enc_string++;
    jmp string_loop_start   ; }

string_loop_end:
    mov byte [edi], 0       ; *enc_string = '\0';

    ;; Your code ends here
    
    ;; DO NOT MODIFY

    popa
    leave
    ret
    
    ;; DO NOT MODIFY
