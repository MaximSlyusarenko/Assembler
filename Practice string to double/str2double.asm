default rel

global str2double

section .text

str2double:
	push rbx
	; rax - position of .
	; rcx - integer number without thinking about .
	xor rcx, rcx
	xor rax, rax
	xor rsi, rsi ; counter - length of number
	xor r11, r11
	cmp byte [rdi], '-'
	je .set_minus
	jmp .loop
	
.set_minus:
	mov r11, 1
	inc rdi	
		
.loop:
	cmp byte [rdi], 0
	je .end
	cmp byte [rdi], '.'
	je .increment_rdi
	inc rax
.continue:
	xor rdx, rdx
	mov dl, byte [rdi]
	sub dl, '0'
	mov rbx, rcx
	imul rbx, 10
	cmp rbx, 0
	jl .end
	add rbx, rdx
	cmp rbx, 0
	jl .end
	mov rcx, rbx
	inc rsi
	inc rdi
	jmp .loop

.increment_rdi:
	push rax
	inc rdi
	jmp .loop
	
.negate_number:
	neg rcx
	jmp .after_negation
	
.end:
	cmp r11, 1
	je .negate_number
.after_negation:	
	pop rax
	xorps xmm0, xmm0
	sub rsi, rax
	mov rax, 10
	cvtsi2sd xmm0, rcx
	.final_loop:
		cvtsi2sd xmm1, rax
		divsd xmm0, xmm1
		dec rsi
		jnz .final_loop
		jmp .finish_program

.finish_program:		
	pop rbx
    ret
