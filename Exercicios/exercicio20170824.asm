# Natan Ogliari
# pseudocode 
#	e = a-3*(c+d+8)
# Register mapping 
#	A:t0; c:t1; d:t2; e:t3

.data 0x10008000

	a:	.word 6	#variavel 
	c:	.word 6	#Variavel
	d:	.word 9 #Variavel 
	e:	.word 4 #Variavel
.text 
	lw $t0,a	#Carrega o registrador a
	lw $t1,c	#carrega o registrador c
	lw $t2,d	#carrega o registrador d
	lw $t3,e	#carrega o registrador e
	
	addi $t2,$t1,8	#soma c com 8
	add $t2,$t2,$t1	#soma (c+d+8)
	li $t4,3
	mul $t3,$t4,$t3
	sub