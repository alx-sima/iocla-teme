section .rodata    
    ;; Vecinii celulei: stanga-jos, stanga-sus, 
    ;;                    dreapta-sus, dreapta-jos
    x_dir: dd -1, -1, 1, 1
    y_dir: dd -1, 1, 1, -1

section .text
    global bonus

;; ========================================================================== ;;
;; void set_bit(int cell[2], int pos)
set_bit:
    enter 0, 0
    pusha

    mov edi, [ebp + 8]  ; cell
    mov ecx, [ebp + 12] ; pos
    
    cmp ecx, 32         ; if (pos < 32)
    jge first_dword     ;
    add edi, 4          ;   cell++;

first_dword:
    and ebx, 0b11111    ; pos %= 32;

    ;; Seteaza al `pos`-lea bit din `cell`.
    mov eax, 1          ; accumulator = 1;
    shl eax, cl         ; accumulator <<= pos;
    or [edi], eax       ; cell |= accumulator;

    popa
    leave
    ret

;; ========================================================================== ;;
;; void bonus(int x, int y, int board[2])
bonus:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]	; x
    mov ebx, [ebp + 12]	; y
    mov ecx, [ebp + 16] ; board

    ;; DO NOT MODIFY
    ;; FREESTYLE STARTS HERE

    mov edx, 0                  ; counter = 0;

mark_cells:                     ; do {
    mov esi, [x_dir + 4 * edx]  ;   line = x_directions[counter];
    add esi, eax                ;   line += x;

    cmp esi, 0                  ;   if (line < 0 || line > 7)
    jl mark_cells_cond          ;       goto mark_cells_cond;
    cmp esi, 7                  ;
    jg mark_cells_cond          ;

    shl esi, 3                  ; pos = line * 8;


    mov edi, [y_dir + 4 * edx]  ;   column = y_directions[counter];
    add edi, ebx                ;   column += y;

    cmp edi, 0                  ;   if (column < 0 || column > 7)
    jl mark_cells_cond          ;       goto mark_cells_cond;
    cmp edi, 7                  ;
    jg mark_cells_cond          ;

    add esi, edi                ;   pos = line * 8 + column;

    push esi                    ;
    push ecx                    ;
    call set_bit                ;   set_bit(byte, pos);
    add esp, 8                  ;

mark_cells_cond:
    inc edx                     ;   counter++;
    cmp edx, 4                  ;
    jl mark_cells               ; } while (counter < 4);

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY