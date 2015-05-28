.data
str1: .asciiz "bbb"
str2: .asciiz "bbbb"


.text

.globl main
main:
    la $a0, str1
    la $a1, str2
    loop:
        lb $t1, 0($a0)
        lb $t4, 0($a1)
        bgt $t1, $t4, first
        bgt $t4, $t1, second
        beqz $t4, equals
        add $a0, $a0, 1
        add $a1, $a1, 1
        j loop

first:
    li $v0, 1
    b endloop

equals:
    li $v0, 0
    b endloop

second:
    li $v0, -1
    b endloop

endloop:
    la $a0, ($v0)
    la $v0, 1
    syscall
