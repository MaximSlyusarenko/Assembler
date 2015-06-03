default rel

global stringCmp
global rabinkarp

extern calloc

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

; arg1 - first string
; arg2 - second string
; result - index of first entry
stringCmp:
	function_start
	push arg1
	push arg2
	mov arg1, [arg1]
	mov arg2, [arg2]
	xor result, result
	.loop:
		mov cl, byte [arg1]
		cmp cl, 0
		je .return_minus_one
		inc result
		mov r13, arg1
		mov r15, arg2
		mov r14, 1
		.loop2:
			mov bl, byte [r15]
			cmp bl, 0
			je .return_res
			mov cl, byte [r13]
			cmp bl, cl
			jne .notequals
			inc r13
			inc r15
			jmp .loop2

.notequals:
	inc arg1
	jmp .loop

.return_res:
	dec result
	pop arg2
	pop arg1
	function_end

.return_minus_one:
	mov result, -1
	pop arg2
	pop arg1
	function_end

; arg1 - first string
; arg2 - second string
; result - index of first entry
rabinkarp:
	function_start
	push arg1
	push arg2
	mov r15, 1
	xor r14, r14 ; size of second string (t)
	mov r13, [arg2]
	mov r11, [arg1]
	push r11
	push r13
	.loop:
		mov cl, byte [r13]
		cmp cl, 0
		je .finish_loop
		inc r14
		inc r13
		jmp .loop

.finish_loop:
	mov rbx, r14
	mov arg1, r14
	mov arg2, 8
	call calloc
	mov r12, result
	pop r13
	push r12
	push r13
	xor r9, r9
	.loop2:
		xor r10, r10
		xor rcx, rcx
		mov cl, byte [r13]
		cmp cl, 0
		je .finish_loop2
		mov r10, rcx
		sub r10, 'a'
		inc r10
		imul r10, r15
		imul r15, 17
		add r10, r9
		mov r9, r10
		mov [r12], r10
		add r12, 8
		inc r13
		jmp .loop2

.finish_loop2:
	pop r13
	pop r12
	pop r11
	push r11
	push r13
	xor r9, r9
	mov r15, 1
	.loop3:
		xor rcx, rcx
		mov cl, byte [r11]
		cmp cl, 0
		je .finish_loop3
		sub rcx, 'a'
		inc rcx
		imul rcx, r15
		imul r15, 17
		add r9, rcx
		inc r11
		jmp .loop3

.finish_loop3:
	pop r13 ; t
	pop r11 ; s
	push r11
	mov r14, rbx ; t.length()
	xor r8, r8
	.loop4:
		mov cl, byte[r11]
		cmp cl, 0
		je .finish_loop4
		inc r11
		inc r8
		jmp .loop4

.finish_loop4:
	pop r11
	; r8 - s.length()
	; r12 - array h from e-maxx
	; r9 = h_s - hash of s
	xor r10, r10 ; h[i - 1]
	mov r11, 1 ; p_pow[i]
	lea r12, [r12 + r8 * 8 - 8]
	mov rdx, r12
	cmp r8, r14
	jg .return_minus_one
	xor result, result
	xor r15, r15
	add r15, r8
	.loop5:
		mov r13, [r12] ; cur_h
		sub r13, r10
		imul r9, r11
		mov r11, 17
		cmp r9, r13
		je .return_result
		inc result
		cmp r15, r14
		je .return_minus_one
		inc r15
		add r12, 8
		mov r10, [rdx]
		add rdx, 8
		jmp .loop5

.return_result:
	pop arg2
	pop arg1
	function_end

.return_minus_one:
	mov result, -1
	pop arg2
	pop arg1
	function_end