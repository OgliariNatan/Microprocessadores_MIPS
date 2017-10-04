.data 0x10008000 
string:	.asciiz	"Digite um valor para calcular a raiz:"	
str:	.asciiz "A raiz é: "		
.text
			
	li $v0, 4			#printa string
	la $a0, string			# "   "   "
syscall
	li $v0, 5			#pede valor ao usuario e armazena em v0
syscall
	move $t0,$v0 

	jal funcraiz			#chamada da funcao raiz
	move $a0, $v0

	li $v0, 1
syscall
	j endfuncraiz
	
funcraiz:
	li $t1, 0			#res recebe 0
	li $t2, 1			# armazena 1 em $t1
	sll $t3, $t2,30

while1:
	ble $t3, $t0, saida1
	srl $t3, $t3, 2
	j while1
saida1:
	
while2:
	beq $t3, $zero, saida2
	add $t4, $t3, $t1	# bit + res
	bge $t0, $t4, verdadeif
	srl $t1, $t1, 1
	j fimif
verdadeif:
	sub $t0, $t0, $t4
	srl $t6, $t1,1
	add $t1, $t6, $t3		
	fimif:
	srl $t3, $t3, 2
	j while2
saida2:
	move $v0, $t1
	jr $ra
	
endfuncraiz:
