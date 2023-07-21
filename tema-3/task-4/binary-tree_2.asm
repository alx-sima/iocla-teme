;; Copyright (C) 2023 Alexandru Sima (312CA)

extern array_idx_2      ;; int array_idx_2

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
    global inorder_intruders


;; ========================================================================== ;;
;;  inorder_intruders(struct node *node, struct node *parent, int *array)
;       functia va parcurge in inordine arborele binar de cautare, salvand
;       valorile nodurilor care nu respecta proprietatea de arbore binar
;       de cautare: |node->value > node->left->value, daca node->left exista
;                   |node->value < node->right->value, daca node->right exista
;
;    @params:
;        node   -> nodul actual din arborele de cautare;
;        parent -> tatal/parintele nodului actual din arborele de cautare;
;        array  -> adresa vectorului unde se vor salva valorile din noduri;

; ATENTIE: DOAR in frunze pot aparea valori gresite!
;          vectorul array este INDEXAT DE LA 0!
;          Cititi SI fisierul README.md din cadrul directorului pentru exemple,
;          explicatii mai detaliate!

; HINT: folositi variabila importata array_idx_2 pentru a retine pozitia
;       urmatorului element ce va fi salvat in vectorul array.
;       Este garantat ca aceasta variabila va fi setata pe 0 la fiecare
;       test al functiei inorder_intruders.      
inorder_intruders:
    enter 0, 0

    mov eax, [ebp + 8]          ; node
    
    test eax, eax               ; if (!node)
    jz inorder_fixing_end       ;   return;

    mov ecx, [eax + node.left]  ; node->left
    mov edx, [eax + node.right] ; node->right

    cmp ecx, edx                ; if (node->left == node->right /* (== NULL) */)
    je inorder_fixing_end       ;   return

    mov edx, [eax + node.left]  ; node->left
    
    push dword [ebp + 16]       ;
    push eax                    ;
    push edx                    ;
    call inorder_intruders      ; inorder_intruders(node->left, parent, array);
    add esp, 12                 ;

    mov eax, [ebp + 8]          ; node
    mov edx, [eax + node.left]  ; node->left

    test edx, edx               ; if (node->left) {
    jz done_left_node           ;

    mov eax, [eax + node.value] ;   node->value
    mov edx, [edx + node.value] ;   node->left->value

    cmp eax, edx                ;   if (node->value <= node->left->value) {
    jg done_left_node           ;

    mov eax, [ebp + 16]         ;       array
    mov ecx, [array_idx_2]      ;       array_idx_2

    mov [eax + 4 * ecx], edx    ;       array[array_idx_2] = node->value;
    inc dword [array_idx_2]     ;       ++array_idx_2;

done_left_node:                 ; } }
    mov eax, [ebp + 8]          ; node
    mov edx, [eax + node.right] ; node->right

    test edx, edx               ; if (node->right) {
    jz done_right_node          ;

    mov eax, [eax + node.value] ;   node->value
    mov edx, [edx + node.value] ;   node->right->value

    cmp eax, edx                ;   if (node->value >= node->right->value) {
    jl done_right_node          ;
    
    mov eax, [ebp + 16]         ;       array
    mov ecx, [array_idx_2]      ;       array_idx_2

    mov [eax + 4 * ecx], edx    ;       array[array_idx_2] = node->value;
    inc dword [array_idx_2]     ;       ++array_idx_2;

done_right_node:                ; } }
    mov eax, [ebp + 8]          ; node
    mov edx, [eax + node.right] ; node->right

    push dword [ebp + 16]       ;
    push eax                    ;
    push edx                    ;
    call inorder_intruders      ; inorder_intruders(node->right, parent, array);
    add esp, 12                 ;

inorder_fixing_end:
    leave
    ret
