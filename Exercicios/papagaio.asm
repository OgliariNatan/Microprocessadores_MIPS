#exercício do papagaio
.data 0x10008000
texto: .asciiz "Diga alguma coisa! \n" #mensagem printada na tela.
n:	.asciiz "\n"
aux: .space 50

.text 
	
	main: 
		li $v0,4	 #preparo para imprimir na tela
		la $a0,texto	 #Carrega a string no registrador 
		syscall 
		
		li $v0,8	 #prepara para ler uma sting
		la $a0, aux	 #carrega o endereço do espaço auxiliar para gravar a leitura
		li $a1,50	 #limita o tamanho da string		
		syscall 
		
		#li $v0,4
		#la $a0,n
		#syscall
		
		li $v0,4	 # prepara para imprimir na tela
		la $a0,aux
		syscall		 #Escreve o repetido 
		
		j main		#Volta para o main 
		
		
