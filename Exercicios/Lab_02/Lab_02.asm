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
_i:	.word 1
_i:	.word 4
_J:	.word 6

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
	lw $s0, _f
	lw $s1, _g
	lw $s2, _h
	lw $s3, _i
	lw $s4, _j
	
	la $t4, jat #carrega endereço de base jat
	
	#seção 4: teste se k esta no intervalo [0,3], caso contrério default 
	
	#seção 5: calcula o ebdereço de jat [k]
	
	#seção 6: desvia para o endereço de jat[k]