struc proc
    .pid: resw 1
    .prio: resb 1
    .time: resw 1
endstruc

section .text
    global sort_procs

;; ========================================================================== ;;
;; Interschimba 2 structuri `proc`.
;; void swap_procs(struct proc *p1, struct proc *p2)
swap_procs:
    enter 0, 0
    pusha
    
    mov ebx, [ebp + 8]  ; p1
    mov edx, [ebp + 12] ; p2
    
    mov ecx, proc_size  ; i = proc_size;

swap_byte:              ; do {
    mov al, [ebx]       ;   aux = *p1;
    xchg al, [edx]      ;   aux, *p2 = *p2, aux;
    mov [ebx], al       ;   *p1 = aux;
    
    inc ebx             ;   p1++;
    inc edx             ;   p2++;
    loop swap_byte      ; } while (--i);

    popa
    leave
    ret


;; ========================================================================== ;;
;; Returneaza 1 daca cele 2 structuri sunt in ordine.
;; int cmp_procs(struct proc *p1, struct proc *p2)
cmp_procs:
    enter 0, 0
    push ebx                    ; save registers
    push ecx                    ;
    push edx                    ;
    
    xor eax, eax                ; default retval = 0
    mov ebx, [ebp + 8]          ; p1
    mov ecx, [ebp + 12]         ; p2

    mov dl, [ebx + proc.prio]  ; if (p1->prio < p2->prio)
    cmp dl, [ecx + proc.prio]  ;   return 1;
    jl exit_cmp_procs_ordered  ; else if (p1->prio > p2->prio)
    jg exit_cmp_procs          ;   return 0;
    
    mov dx, [ebx + proc.time]   ; if (p1->time < p2->time)
    cmp dx, [ecx + proc.time]   ;   return 1;
    jl exit_cmp_procs_ordered   ; else if (p1->time > p2->time)
    jg exit_cmp_procs           ;   return 0;

    mov dx, [ebx + proc.pid]    ; if (p1->pid < p2->pid)
    cmp dx, [ecx + proc.pid]    ;   return 0;
    jg exit_cmp_procs           ;

exit_cmp_procs_ordered:
    mov eax, 1                  ; return 1;

exit_cmp_procs:
    pop edx                     ; restore registers
    pop ecx                     ;
    pop ebx                     ;
    leave
    ret


;; ========================================================================== ;;
;; Sorteaza un vector de `proc`, folosind algoritmul quicksort
;; void sort_procs(struct proc *processes, int length)
sort_procs:
    ;; DO NOT MODIFY
    enter 0,0
    pusha
    
    mov edx, [ebp + 8]      ; processes
    mov eax, [ebp + 12]     ; length
    ;; DO NOT MODIFY

    ;; Your code starts here
    cmp eax, 1                      ; if (length <= 1)
    jle exit_function               ;   return;
    
    ;; Pivotul (ultimul element)
    imul ecx, eax, proc_size        ; size = length * sizeof(structproc);
    lea esi, [edx + ecx - proc_size]; pivot = processes + size - sizeof(struct proc);

    mov edi, edx                    ; pos = processes;  /* pozitia pivotului in vectorul sortat */
    xor ebx, ebx                    ; index = 0;        /* indicele pivotului */
    mov ecx, edx                    ;
    sub ecx, proc_size              ; curr = processes - sizeof(struct proc);

partitioning:                       ; do {
    add ecx, proc_size              ;   curr += sizeof(struct proc);
    cmp ecx, esi                    ;   if (curr == pivot)
    je end_partitioning             ;       break;
    
    push eax                        ;   save eax
    
    ;; Compara procesul curent cu pivotul
    push esi                        ;
    push ecx                        ;
    call cmp_procs                  ; order = cmp_procs(curr, pivot);
    add esp, 8                      ;

    cmp eax, 0                      ;

    pop eax                         ;   restore eax

    je partitioning                 ;   if (order == 0) continue;
    
    ;; Muta procesul curent la stanga pivotului
    push ecx                        ;
    push edi                        ;
    call swap_procs                 ;   swap_procs(pos, curr);
    add esp, 8                      ;

    inc ebx                         ;  index++;
    add edi, proc_size              ;  pos++;
    jmp partitioning                ; } while (1);

end_partitioning:
    ;; Muta pivotul pe noua sa pozitie
    push esi                        ;
    push edi                        ;
    call swap_procs                 ; swap_procs(pos, pivot);
    add esp, 8                      ;
    
    ;; Sorteaza subvectorul din stanga pivotului
    push ebx                        ;
    push edx                        ;
    call sort_procs                 ; sort_procs(processes, index);
    add esp, 8                      ; 

    ;; Sorteaza elementele din dreapta pivotului
    sub eax, ebx                    ; length -= index;
    push eax                        ;
    push edi                        ;
    call sort_procs                 ; sort_procs(pos + 1, length);
    add esp, 8                      ;

exit_function:
    ;; Your code ends here
    
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY
