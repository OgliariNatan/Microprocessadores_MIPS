# Natan Ogliari
# pseudocode 
#	e = a-3*(c+d+8)
# Register mapping 
#	f:$s0; g:$s1; h:$s2; i:$s3; j:$s4; k:$s5;
#	L0: 
#
.data 0x10008000
#seção 1: variaveis f,g,h,i,j armazenadas em memoria (inicialização)
_f:	.word 0
_g:	.word 4
_h:	.word 1
_i:	.word 4
_j:	.word 6

#seção 2: jump addres table
jat:
	.word LO
	.word L1
	.word L2
	.word L3
	.word default
	
.text
.globl main

main:
	#seção 3: registradores recebem valores iniciais (execto a variavel k)
	lw $s0,_f
	lw $s1,_g
	lw $s2,_h
	lw $s3,_i
	lw $s4,_j
	
	la $t4, jat	#carrega endereço de base jat
	
	li $s5, -1	#Variave de k (-1, 0, 1, 2, 3, 4) valores de retorno em $s0 (-1, 0, 1, 2, 3, 4)
	
	#seção 4: teste se k esta no intervalo [0,3], caso contrério default 
	
	sltiu $t1,$s5,4
	beq $t1,0,default
	
	#default: j exit
	
	#seção 5: calcula o endereço de jat [k]
	
	add $t1,$s5,$s5 #t1=2*k
	add $t1,$t1,$t1 #t1=4*k
	add $t1,$t1,$t4 #t1=end.base + 4*k
	lw $t0,0($t1)
	
	jr $t0 #REVER
	
	#seção 6: desvia para o endereço de jat[k]
	
	LO:	add $s0,$s3,$s4
		j exit
	L1:	add $s0,$s1,$s2
		add $s0,$s0,$s5 
		j exit
	L2:	sub $s0,$s1,$s2
		j exit
	L3:	sub $s0,$s1,$s2
		j exit
	default: sub $s0,$s3,$s4
		 add $s0,$s0,$s2
		 j exit
	#seção 7: codifica as alternativas de execução
	
	exit:
