;; Copyright (C) 2023 Alexandru Sima (312CA)

extern array_idx_1      ;; int array_idx_1

;   struct node {
;       int value;
;       struct node *left;
;       struct node *right;
;   } __attribute__((packed));
struc node
    .value: resd 1
    .left:  resd 1
    .right: resd 1
endstruc

section .text
    global inorder_parc


;; ========================================================================== ;;
;;  inorder_parc(struct node *node, int *array);
;       functia va parcurge in inordine arborele binar de cautare, salvand
;       valorile nodurilor in vectorul array.
;    @params:
;        node  -> nodul actual din arborele de cautare;
;        array -> adresa vectorului unde se vor salva valorile din noduri;

; ATENTIE: vectorul array este INDEXAT DE LA 0!
;          Cititi SI fisierul README.md din cadrul directorului pentru exemple,
;          explicatii mai detaliate!
; HINT: folositi variabila importata array_idx_1 pentru a retine pozitia
;       urmatorului element ce va fi salvat in vectorul array.
;       Este garantat ca aceasta variabila va fi setata pe 0 la fiecare
;       test.
inorder_parc:
    enter 0, 0

    mov eax, [ebp + 8]          ; node
    
    test eax, eax               ; if (!node)
    jz inorder_fixing_end         ;   return;

    mov eax, [eax + node.left]  ; node->left
    
    push dword [ebp + 12]       ;
    push eax                    ;
    call inorder_parc           ; inorder_parc(node->left, array);
    add esp, 8                  ;

    mov eax, [ebp + 8]          ; node
    mov edx, [ebp + 12]         ; array
    mov eax, [eax + node.value] ; val = node->value;

    mov ecx, [array_idx_1]      ;
    mov [edx + 4 * ecx], eax    ; array[array_idx_1] = val;
    inc dword [array_idx_1]     ; ++array_idx_1;

    mov eax, [ebp + 8]          ; node
    mov eax, [eax + node.right] ; node->right;

    push dword [ebp + 12]       ;
    push eax                    ;
    call inorder_parc           ; inorder_parc(node->right, array);
    add esp, 8                  ;

inorder_fixing_end:
    leave
    ret
