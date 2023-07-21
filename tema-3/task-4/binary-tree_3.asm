;; Copyright (C) 2023 Alexandru Sima (312CA)

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
    global inorder_fixing


;; ========================================================================== ;;
;;  inorder_fixing(struct node *node, struct node *parent)
;       functia va parcurge in inordine arborele binar de cautare, modificand
;       valorile nodurilor care nu respecta proprietatea de arbore binar
;       de cautare: |node->value > node->left->value, daca node->left exista
;                   |node->value < node->right->value, daca node->right exista.
;
;       Unde este nevoie de modificari se va aplica algoritmul:
;           - daca nodul actual este fiul stang, va primi valoare tatalui - 1,
;                altfel spus: node->value = parent->value - 1;
;           - daca nodul actual este fiul drept, va primi valoare tatalui + 1,
;                altfel spus: node->value = parent->value + 1;

;    @params:
;        node   -> nodul actual din arborele de cautare;
;        parent -> tatal/parintele nodului actual din arborele de cautare;

; ATENTIE: DOAR in frunze pot aparea valori gresite! 
;          Cititi SI fisierul README.md din cadrul directorului pentru exemple,
;          explicatii mai detaliate!

inorder_fixing:
    enter 0, 0

    mov eax, [ebp + 8]          ; node
    
    test eax, eax               ; if (!node)
    jz inorder_fixing_end       ;   return;

    mov ecx, [eax + node.left]  ; node->left
    mov edx, [eax + node.right] ; node->right

    ;; Arborii binari de cautare au cei 2 fii egali doar
    ;; cand acestia sunt nuli (nodul curent este frunza).
    cmp ecx, edx                ; if (node->left == node->right /* (== NULL) */)
    je inorder_fixing_end       ;   return

    mov edx, [eax + node.left]  ; node->left
    
    push eax                    ;
    push edx                    ;
    call inorder_fixing         ; inorder_fixing(node->left, parent);
    add esp, 8                  ;

    mov eax, [ebp + 8]          ; node
    mov edx, [eax + node.left]  ; node->left

    test edx, edx               ; if (node->left) {
    jz done_left_node           ;

    mov eax, [eax + node.value] ;   node->value
    lea edx, [edx + node.value] ;   &node->left->value

    cmp eax, [edx]              ;   if (node->value <= node->left->value) {
    jg done_left_node           ;

    mov [edx], eax              ;       node->value->left = node->left - 1;
    dec dword [edx]             ;

done_left_node:                 ; } }
    mov eax, [ebp + 8]          ; node
    mov edx, [eax + node.right] ; node->right

    test edx, edx               ; if (node->right) {
    jz done_right_node          ;

    mov eax, [eax + node.value] ;   node->value
    lea edx, [edx + node.value] ;   &node->right->value

    cmp eax, [edx]              ;   if (node->value >= node->right->value) {
    jl done_right_node          ;

    mov [edx], eax              ;       node->value->right = node->right + 1;
    inc dword [edx]             ;

done_right_node:                ; } }
    mov eax, [ebp + 8]          ; node
    mov edx, [eax + node.right] ; node->right

    push eax                    ;
    push edx                    ;
    call inorder_fixing         ; inorder_fixing(node->right, parent);
    add esp, 8

inorder_fixing_end:
    leave
    ret
