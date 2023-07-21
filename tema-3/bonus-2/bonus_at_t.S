/* Copyright (C) 2023 Alexandru Sima (312CA) */
#include "positions.h"

.macro sub_values nthpos, nthval
	movb %bl, %al				// pos = n;

	movb $\nthpos, %dl			//
	mul %dl						// pos *= nthpos;

	movb $10, %dl				//
	div %dl						// pos /= 10;
	xor %edx, %edx				//
	movb %al, %dl				// 

	movl (%edi, %edx, 4), %esi 	//
	subl $\nthval, %esi			//	
	movl %esi, (%edi, %edx, 4)	// v[pos] -= nthval;
.endm

.section .text
.global add_vect

/* 
 * void add_vect(int *v1, int *v2, int n, int *v)
 *
 * add v1 and v2, that have both the length n, and store the result in v3.
 * also, substract from v3 the values provided in positions.S, as described
 * in the task
 */

add_vect:
	pushl %ebp
	movl %esp, %ebp

	pushl %ebx 					// save registers
	pushl %esi					//
	pushl %edi 					//

	movl 8(%ebp), %esi			// v1
	movl 12(%ebp), %edx			// v2
	movl 16(%ebp), %ebx			// n
	movl 20(%ebp), %edi			// v

	xor %ecx, %ecx				// i = 0;	

add_vectors:					// do {
	movl (%esi, %ecx, 4), %eax	//
	addl (%edx, %ecx, 4), %eax	//
	movl %eax, (%edi, %ecx, 4)	//

	inc %ecx					// 	i++;
	cmp %ecx, %ebx				//
	jne add_vectors				// } while (i < n);

	sub_values FIRST_POSITION, FIRST_VALUE
	sub_values SECOND_POSITION, SECOND_VALUE
	sub_values THIRD_POSITION, THIRD_VALUE

	popl %edi					// restore registers
	popl %esi					//
	popl %ebx					//

	leave
	ret
