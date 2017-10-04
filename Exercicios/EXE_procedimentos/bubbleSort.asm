#Autor Natan 
#Ordenação BubbleSort

.data 0x10008000 
vetOrdenado:	.word 1, 76, 4, 9 
countI:		.word 0
countJ:		.word 0
aux:		.word 0
str:		.asciiz "FIM"
.text
	la $t0, vetOrdenado # inicialização do vetor
	li $t4, 4 # qtd = 4 ( 4 elementos do vetor)
	lw $t1, countI # i = 0
	lw $t3, aux # aux = 0
	jal bubbleSort # chamada da função
	
	#INICIO: printa "FIM"
	li $v0, 4
	la $a0, str
	syscall
	#FIM: printa "FIM"
	j end
		
bubbleSort:
	sub $t5, $t4, 1 # k = qtd - 1
	addi $s0, $t0, 0
		
loop1:  
	bge $t1, $t4, endloop1  # i >= qtd
	lw $t2, countJ # j = 0
loop2:  
	bge $t2, $t5, endloop2  # j >= k
if:	
	lw $s0, 0($t0) # seleciona vetor
	lw $s1, 4($t0) # seleciona vetor
	beqz $s1, endif # $s1 (2 num vetor) = 0
	ble $s0, $s1, endif # 1 num vetor <= 2 num vetor
	move $t3, $s0 # move 1 num vetor para aux
	move $s0, $s1 # move 2 num vetor para 1 num vetor
	move $s1, $t3 # move 1 num para aux
	sw  $s0, 0($t0)
	sw  $s1, 4($t0)
	add $t0, $t0, 4
	j if
endif:
	add $t0, $t0, 4 # acessar o segundo elemento do vetor
	add $t2, $t2, 1 #j++
	j loop2
endloop2:
	move $t0, $s0 
	sub $t5, $t5, 1 #k--
	add $t1, $t1, 1 # i++
	j loop1 
endloop1:
	jr $ra
end:

	
	
