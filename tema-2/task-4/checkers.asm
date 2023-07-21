section .rodata
    ;; Vecinii celulei: stanga-jos, stanga-sus, 
    ;;                    dreapta-sus, dreapta-jos
    x_dir: dd -1, -1, 1, 1
    y_dir: dd -1, 1, 1, -1

section .text
    global checkers

;; ========================================================================== ;;
;; void checkers(int x, int y, int table[8][8])
checkers:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; x
    mov ebx, [ebp + 12] ; y
    mov ecx, [ebp + 16] ; table

    ;; DO NOT MODIFY
    ;; FREESTYLE STARTS HERE

    xor edx, edx                ; i = 0;

mark_cells:                     ; do {
    mov esi, [x_dir + 4 * edx]  ;   neigh_x = directions[i];
    add esi, eax                ;   neigh_x += x;
    
    cmp esi, 0                  ;   if (neigh_x < 0 || neigh_x > 7)
    jl end_mark_cells           ;       goto end_mark_cells;
    cmp esi, 7                  ; 
    jg end_mark_cells           ;

    lea edi, [ecx + 8 * esi]    ;   row = table[neigh_x];
    
    mov esi, [y_dir + 4 * edx]  ;   neigh_y = directions[i];
    add esi, ebx                ;   neigh_y += y;

    cmp esi, 0                  ;   if (neigh_y >= 0 && neigh_y <= 7)
    jl end_mark_cells           ;
    cmp esi, 7                  ;
    jg end_mark_cells           ;
    inc byte [edi + esi]        ;       row[neigh_y]++;

end_mark_cells:
    inc edx                     ;   i++; 
    cmp edx, 4                  ;
    jl mark_cells               ; } while (i < 4);


    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY