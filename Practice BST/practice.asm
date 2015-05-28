default rel

extern calloc
extern free
extern memcpy

global treeNew
global treeInsert
global treeFind
global nextTree
global prevTree

section .text

%define arg1 rdi
%define arg2 rsi
%define arg3 rdx
%define arg4 rcx
%define result rax  ; Registers which are arguments and result for functions accordingly to System V calling convention

%macro function_start 0  ; Save register values which we must save accordingly to System V calling convention
	push rbp
	push rbx
	push r12
	push r13
	push r14
	push r15
%endmacro	

%macro function_end 0  ; Restore registers values
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
%endmacro	

%macro alloc_with_align 1  ; Allocates memory with align 16 bytes. Result of executing is in rax (previously defined result)
	push rbp
	push arg1
	push arg2
	mov rbp, rsp
	mov arg1, %1
	mov arg2, 8 ; qword = 8 bytes
	and rsp, ~15  ; align the stack
	call calloc
	test result, result
	jnz %%correct
	ret                    ; Can't allocate, finish program
%%correct:
	mov rsp, rbp
	pop arg2
	pop arg1
	pop rbp
%endmacro	

struc node
	.value:		resq 1
	.left:		resq 1
	.right:		resq 1
	.parent:	resq 1
endstruc

; arg1 - pointer on tree
; arg2 - element to insert
; result - pointer on node
treeInsert:
	function_start
	mov r13, arg1
	cmp arg1, 0
	je .insert_first
	mov r15, [arg1 + node.value]
	xor r14, r14
	.loop:
		mov r12, [r13 + node.value]
		cmp r12, arg2
		jl .go_right
		jg .go_left
		je .return

.go_right:
	mov r11, r13
	mov r13, [r13 + node.right]
	cmp r13, r14
	je .set_element_rigth
	jmp .loop

.go_left:
	mov r11, r13
	mov r13, [r13 + node.left]
	cmp r13, r14
	je .set_element_left
	jmp .loop

.set_element_rigth:
	push r11
	alloc_with_align 32
	pop r11
	mov [r11 + node.right], result
	mov [result + node.parent], r11
	mov [result + node.value], arg2
	jmp .return

.set_element_left:	
	push r11
	alloc_with_align 32
	pop r11
	mov [r11 + node.left], result
	mov [result + node.parent], r11
	mov [result + node.value], arg2
	jmp .return

.insert_first:
	alloc_with_align 32
	mov qword [result + node.left], 0
	mov qword [result + node.right], 0
	mov [result + node.value], arg2
	mov qword [result + node.parent], 0
	function_end

.return:
	mov result, r13
	function_end

; arg1 - pointer on tree
; arg2 - element to insert
; result - pointer on node
treeFind:
	function_start
	mov r13, arg1
	mov r15, [arg1 + node.value]
	xor r14, r14
	.loop:
		mov r12, [r13 + node.value]
		cmp r12, arg2
		jl .go_right
		jg .go_left
		je .return

.go_right:
	mov r13, [r13 + node.right]
	cmp r13, r14
	je .return_null
	jmp .loop

.go_left:
	mov r13, [r13 + node.left]
	cmp r13, r14
	je .return_null
	jmp .loop

.return_null:
	xor r13, r13

.return:
	mov result, r13
	function_end

; arg1 - pointer on tree
; result - pointer on result node
nextTree:
	function_start
	mov r13, arg1
	xor r14, r14 ; NULL
	cmp qword [r13 + node.right], 0
	jne .find_min_in_right
	mov r15, [r13 + node.parent] ; y
	.loop:
		cmp r15, 0
		je .return_r15
		cmp [r15 + node.right], r13
		jne .return_r15
		mov r13, r15
		mov r15, [r13 + node.parent]
		jmp .loop

.find_min_in_right:
	mov r15, [r13 + node.right]
	.loop1:
		cmp qword [r15 + node.left], 0
		je .return_r15
		mov r15, [r15 + node.left]
		jmp .loop1

.return_r15:
	mov result, r15
	function_end


prevTree:
	function_start
	mov r13, arg1
	xor r14, r14 ; NULL
	cmp qword [r13 + node.left], 0
	jne .find_max_in_left
	mov r15, [r13 + node.parent] ; y
	.loop:
		cmp r15, 0
		je .return_r15
		cmp [r15 + node.left], r13
		jne .return_r15
		mov r13, r15
		mov r15, [r13 + node.parent]
		jmp .loop

.find_max_in_left:
	mov r15, [r13 + node.left]
	.loop1:
		cmp qword [r15 + node.right], 0
		je .return_r15
		mov r15, [r15 + node.right]
		jmp .loop1

.return_r15:
	mov result, r15
	function_end	