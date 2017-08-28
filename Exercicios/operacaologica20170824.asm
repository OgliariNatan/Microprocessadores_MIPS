# Natan Ogliari
# pseudocode 
#	d=(a<c) || ((a+c) == 10)
#register mappings:
#	a:t0, c:t1, d:t4
.data 0x10008000

	a:	.word 5	#variavel 
	c:	.word 6	#Variavel
	d:	.word 	#Variavel	
.text 
	lw $t0,a	#Carrega o registrador a
	lw $t1,c	#carrega o registrador c
	lw $t4,d	#carrega o registrador c
	add $t2,$t0,$t1	#soma a+b
	seq $t2,$t2,10	#compara se a+c é igual a 10
	slt $t3,$t0,$t1	#compara a<c
	or  $t4,$t3,$t2



