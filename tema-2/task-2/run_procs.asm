struc avg
    .quo:       resw 1
    .remain:    resw 1
endstruc

struc proc
    .pid:   resw 1
    .prio:  resb 1
    .time:  resw 1
endstruc

section .data
    prio_result dd 0, 0, 0, 0, 0
    time_result dd 0, 0, 0, 0, 0

section .text
    extern printf
    global run_procs

;; ========================================================================== ;;
;; void run_procs(struct proc *processes, int length, struct avg *proc_avg)
run_procs:
    ;; DO NOT MODIFY

    push ebp
    mov ebp, esp
    pusha

    xor ecx, ecx

clean_results:
    mov dword [time_result + 4 * ecx], dword 0
    mov dword [prio_result + 4 * ecx],  0

    inc ecx
    cmp ecx, 5
    jne clean_results

    mov ecx, [ebp + 8]      ; processes
    mov ebx, [ebp + 12]     ; length
    mov eax, [ebp + 16]     ; proc_avg
    ;; DO NOT MODIFY
   
    ;; Your code starts here

    mov edx, ecx                            ; processes
    mov ecx, ebx                            ; length

traverse_array:                             ; do {
    movzx ebx, byte [edx + proc.prio]       ;   prio = processes->prio;
    inc dword [prio_result + 4 * (ebx - 1)] ;   prio_result[prio - 1]++;

    movzx edi, word [edx + proc.time]       ;   time = processes->time;
    add [time_result + 4 * (ebx - 1)], edi  ;   time_result[prio - 1] += time;

    add edx, proc_size                      ;   processes++;
    loop traverse_array                     ; } while (--length);

    xor ecx, ecx                            ; i = 0;
    mov edi, eax                            ; proc_avg

calc_divisions:                             ; do {
    mov ebx, [prio_result + 4 * ecx]        ;   prio = prio_result[i];
    cmp ebx, 0                              ;   if (prio == 0)
    je skip_division                        ;       goto skip_division;
    
    mov eax, [time_result + 4 * ecx]        ;   time = time_result[i];
    
    xor edx, edx                            ;   quo = time / prio, 
    div ebx                                 ;   remain = time % prio;

    mov [edi + 4 * ecx + avg.quo], ax       ;   proc_avg[i].quo = quo;
    mov [edi + 4 * ecx + avg.remain], dx    ;   proc_avg[i].remain = remain;

skip_division:
    inc ecx                                 ;   i++;
    cmp ecx, 5                              ;
    jne calc_divisions                      ; } while (length < 5);

    ;; Your code ends here
    
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY