default rel

extern malloc
extern calloc
extern free
extern memcpy

global matrixNew
global matrixDelete
global matrixGetRows
global matrixGetCols
global matrixGet
global matrixSet
global matrixScale
global matrixAdd
global matrixMul

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

; argument after the macro is divisible on 4
; argument after the macro >= argument before the macro
%macro align_4 1
	add %1, 3 ; to argument after the macro won't be less then argument before the macro
	and %1, ~3 ; set to zero last 2 binary digits
%endmacro

struc matrix
	.number_of_rows		resq 1
	.number_of_cols		resq 1
	.rows 				resq 1 ; rows aligned on 4
	.cols 				resq 1 ; cols aligned on 4
	.data				resq 1 ; pointer on matrix
endstruc

; arg1 - number of rows in matrix
; arg2 - number of cols in matrix
; result - pointer on matrix with given number of rows and given number of cols
matrixNew:
	function_start
	mov r15, arg1
	mov r14, arg2 ; save number of rows and cols, because i want to call malloc and need to use arg1 and arg2
	mov arg1, matrix_size
	mov r13, rsp
	and rsp, ~15 ; align the stack
	call malloc ; allocate memory for struct
	mov rsp, r13 ; restore value of rsp
	test result, result
	jz .bad_alloc
	mov r13, result ; pointer on struct is in r13 now
	mov [r13 + matrix.number_of_rows], r15 ; set number of rows in matrix
	mov [r13 + matrix.number_of_cols], r14 ; set number of cols in matrix
	align_4 r15 ; align rows on 4 bytes
	align_4 r14 ; align cols on 4 bytes
	mov [r13 + matrix.rows], r15
	mov [r13 + matrix.cols], r14
	mov rax, r15
	mul r14 ; it's needed memory for data in rax now
	mov arg1, rax ; number of elements in matrix
	mov arg2, 4 ; 4 bytes for every element, because it's float
	mov rbp, rsp
	and rsp, ~15 ; align the stack
	call calloc ; allocate memory for data
	mov rsp, rbp
	test result, result
	jz .bad_calloc
	mov [r13 + matrix.data], result
	mov result, r13 ; to return pointer on struct
	function_end

.bad_alloc: ; nothing allocated, so i mustn't free some memory, i can just finish function
	function_end

.bad_calloc: ; bad allocation memory for data => need to free memory, which was allocated for struct
	mov arg1, r13 ; pointer on matrix
	mov rbp, rsp
	and rsp, ~15 ; align the stack
	call free ; free memory allocated for struct
	mov rsp, rbp ; restore rsp
	function_end

; arg1 - matrix to copy
; result - pointer on copyied matrix
matrixCopy:	
	function_start
	push arg1 ; save value of arg1
	mov r15, arg1 ; save value of arg1, because i want to call matrixNew
	mov arg1, [r15 + matrix.number_of_rows]
	mov arg2, [r15 + matrix.number_of_cols]
	call matrixNew
	mov r14, result ; pointer on new matrix
	mov rax, [r14 + matrix.rows]
	mov r12, [r14 + matrix.cols]
	mul r12 ; calculate number of elements in matrix
	lea rax, [rax * 4] ; size of data in bytes
	mov r15, [r15 + matrix.data] ; pointer on data of given matrix
	mov r12, [r14 + matrix.data] ; pointer on data of copyied matrix
	mov arg1, r12
	mov arg2, r15
	mov arg3, rax ; arguments for memcpy
	mov rbp, rsp
	and rsp, ~15 ; align the stack before the call of memcpy
	call memcpy
	mov rsp, rbp ; restore value of rsp
	mov result, r14
	pop arg1 ; restore value of arg1
	function_end	

; arg1 - pointer on matrix to delete
; Function free all memory which is occupied by given matrix
matrixDelete:
	function_start
	mov r14, arg1 ; save value of arg1, because i need to use arg1 to call free
	mov r15, [arg1 + matrix.data]
	mov arg1, r15
	mov rbp, rsp
	and rsp, ~15
	call free ; free memory for data of matrix
	mov arg1, r14 ; pointer on matrix
	and rsp, ~15
	call free ; free memory for struct
	mov rsp, rbp ; restore value of rsp
	function_end

; arg1 - matrix
; result - number of rows in matrix
matrixGetRows:
	mov result, [arg1 + matrix.number_of_rows]
	ret

; arg1 - matrix
; result - number of cols in matrix
matrixGetCols:
	mov result, [arg1 + matrix.number_of_cols]
	ret

; arguments - matrix, row, column
; result of function is in xmm0 - element on position with given row and column in matrix
matrixGet:
	function_start	
	mov r15, arg3 ; because i want to do mul and must save value of rdx
	mov rax, [arg1 + matrix.cols]
	mul arg2
	add rax, r15
	shl rax, 2
	mov r14, [arg1 + matrix.data]
	add r14, rax ; r14 - address of given element in memory
	movss xmm0, [r14]
	function_end

; arguments - matrix, row, column, value
; set given value to position in matrix with given row and column
matrixSet:
	function_start
	mov r15, arg3 ; because i want to do mul and must save value of rdx
	mov rax, [arg1 + matrix.cols]
	mul arg2
	add rax, r15
	shl rax, 2
	mov r14, [arg1 + matrix.data]
	add r14, rax ; r14 - address of given element in memory
	movss [r14], xmm0 ; set given value to given element
	function_end

; arg1 - matrix
; xmm0 - float value
; result - xmm0 * arg1
matrixScale:
	function_start
	sub rsp, 4
	movss [rsp], xmm0 ; save xmm0 on stack
	call matrixCopy
	movss xmm1, [rsp] ; restore value of xmm0
	add rsp, 4
	pshufd xmm1, xmm1, 0
	mov r15, result ; pointer on copyied matrix
	mov r14, [r15 + matrix.rows]
	mov rax, [r15 + matrix.cols]
	mul r14 ; size of matrix is in rax now
	mov r13, [r15 + matrix.data]
	.loop:
		movups xmm0, [r13] ; get 4 float numbers
		mulps xmm0, xmm1
		movups [r13], xmm0 ; save new value of this 4 float numbers in memory
		lea r13, [r13 + 16] ; to next 4 float numbers of matrix
		sub rax, 4
		jnz .loop
	mov result, r15 ; move pointer on matrix to result
	function_end	

; arg1 - pointer on first matrix
; arg2 - pointer on second matrix
; After the function result = arg1 + arg2
matrixAdd:
	function_start
	mov r15, [arg1 + matrix.number_of_rows]
	cmp qword [arg2 + matrix.number_of_rows], r15
	jne .wrong_size ; if number of rows of arg1 != number of rows of arg2 then i can't add them
	mov r14, [arg1 + matrix.number_of_cols]
	cmp qword [arg2 + matrix.number_of_cols], r14
	jne .wrong_size ; if number of cols of arg1 != number of cols of arg2 then i can't add them
	mov r13, arg1
	mov r12, arg2 ; save values of arg1 and arg2 before the function matrixCopy call
	call matrixCopy
	mov r15, result ; pointer on copyied matrix is in r15 now
	mov r14, [r15 + matrix.rows]
	mov rax, [r15 + matrix.cols]
	mul r14 ; size of matrix is in rax now
	mov rbx, [r15 + matrix.data] ; data of copyied matrix
	mov r13, [r13 + matrix.data] ; data of arg1
	mov r12, [r12 + matrix.data] ; data of arg2
	.loop:
		movups xmm0, [r13 + 4 * rax - 16] ; 4 floats from data of arg1
		movups xmm1, [r12 + 4 * rax - 16] ; 4 floats from data of arg2
		addps xmm0, xmm1
		movups [rbx + 4 * rax - 16], xmm0 ; save resulted 4 floats to copyied matrix
		sub rax, 4 ; to next 4 float numbers of matrix
		jnz .loop
	mov result, r15 ; move pointer on matrix to result
	function_end	

.wrong_size:
	xor result, result ; return NULL if arg1 and arg2 have bad sizes, and i can't to add them
	function_end

; arg1 - pointer on first matrix
; arg2 - pointer on second matrix
; After the function result = arg1 * arg2
matrixMul:
	function_start
	mov r15, [arg1 + matrix.number_of_cols]
	cmp qword [arg2 + matrix.number_of_rows], r15
	jne .wrong_size ; if number of cols of arg1 != number of rows of arg2 then i can't mul them
	mov r15, arg1
	mov r14, arg2 ; save pointers on matrix
	mov arg1, [r15 + matrix.number_of_rows]
	mov arg2, [r14 + matrix.number_of_cols]
	mov rax, arg1
	mul arg2
	cmp rax, 0
	je .wrong_size ; size of matix is zero
	call matrixNew ; first matrix have size n * m, second matrix have size m * k => result matrix have size n * k
	test result, result
	jz .wrong_size ; something comes wrong in matrixNew
	mov r13, result ; pointer on new matrix is in r13 now
	mov r12, r15 ; pointer on first matrix is in r12 now
	mov r11, r14 ; pointer on second matrix is in r11 now
	xor r15, r15 ; init i for cycle
	.loop1:	; for (i = 0; i < A.rows; i++)
		xor r14, r14 ; init j
		.loop2: ; for (int j = 0; j < A.cols; j++)
			mov arg1, r12
			mov arg2, r15
			mov arg3, r14
			call matrixGet ; A[i][j] is in xmm0 now
			pshufd xmm0, xmm0, 0
			mov rax, [r11 + matrix.cols]
			mul r14
			shl rax, 2
			mov r10, [r11 + matrix.data]
			add r10, rax ; pointer on B[j][0] is in r10 now
			mov rax, [r13 + matrix.cols]
			mul r15
			shl rax, 2
			mov r9, [r13 + matrix.data]
			add r9, rax ; pointer in C[i][0] is in r9 now
			mov r8, [r11 + matrix.cols]
			.loop3: ; for (int i = B.cols; i > 0; i--)
				movups xmm1, [r10 + r8 * 4 - 16] ; B[j][k] is in xmm1 now
				movups xmm2, [r9 + r8 * 4 - 16] ; C[i][k] is in xmm2 now
				mulps xmm1, xmm0 ; A[i][j] * B[j][k] is in xmm1 now
				addps xmm2, xmm1 ; C[i][k] += A[i][j] * b[j][k]
				movups [r9 + r8 * 4 - 16], xmm2 ; save result in matrix
				sub r8, 4
				jnz .loop3
			inc r14 ; last thing to do in second cycle
			cmp r14, [r12 + matrix.cols]
			jl .loop2
		inc r15 ; last thing to do in first cycle
		cmp r15, [r12 + matrix.rows]
		jl .loop1		
	mov result, r13
	function_end
			
.wrong_size:
	xor result, result ; return NULL if arg1 and arg2 have bad sizes, and i can't to mul them
	function_end
