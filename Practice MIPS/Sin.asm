.data
str1: .asciiz "bbb"
str2: .asciiz "bbbb"
one: .float 1
zero: .float 0
mone: .float -1

.text

.globl main
main:
	la $v0, 6
	syscall
	la $t0, 4
	l.s $f5, one
	mov.s $f1, $f0
	l.s $f2, zero
	l.s $f7, one
loop:
	add.s $f2, $f2, $f1
	mul.s $f1, $f1, $f0
	mul.s $f1, $f1, $f0
	mov.s $f6, $f5
	add.s $f6, $f6, $f7	
	mov.s $f3, $f6
	div.s $f1, $f1, $f3
	add.s $f6, $f6, $f7
	mov.s $f3, $f6
	div.s $f1, $f1, $f3
	mov.s $f5, $f6
	l.s $f3, mone
	mul.s $f1, $f1, $f3
	sub $t0, $t0, 1
	beq $t0, $zero, finishloop
	j loop
	
finishloop:
	mov.s $f12, $f2
	la $v0, 2
	syscall	