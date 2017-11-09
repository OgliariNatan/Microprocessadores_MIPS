#Autor : Natan 
#Função Fatorial

.data 0x10008000
_z:	.space 1
_x:	.word 2		#Numero a ser fatorado
str:	.asciiz "INICIO do programa fatorial"
str1:	.asciiz "FIM do programa fatorial"

.text 
	li $v0, 4
	la $a0, str
	syscall
	
	la $t0,_x
	
	j exit

factorial:		#Realiza a função fatorial
	
	
	
	
	
exit:			#Printa o FIM do programa
	li $v0, 4
	la $a0, str1
	syscall