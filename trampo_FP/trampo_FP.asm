 #######Author Natan Ogliari######
#################################

########################################

.data
buff: .space 800000
filename: .asciiz "lena.bmp"
imagem: .space 1048576 	# 1.048.576 = 0x 10 0000

.text
#abre arquivo
la $a0, filename	# endereço da string com o nome do arquivo
li $v0, 13		# parametro p chamada de abertura
li $a1, 0		# flags (0=read, 1=write)
li $a2, 0		# mode = desnecessário
syscall			# devolve o descritor (ponteiro) do arquivo em $v0

move $a0, $v0		# mode o descritor para $a0
li $v0, 14		# parametro de chamada de leitura de arquivo
la $a1, buff		# endereço para armazenamento dos dados lidos
li $a2, 800000		# tamanho máx de caracteres
syscall			# devolve o número de caracteres lidos

bgt $v0, 0, fpnull
break
fpnull:

move $t0, $v0
la $t1, buff		# carrega endereço do buffer novamente
add $t0, $t0, $t1	# aponta para o endereço do ultimo caracter lido + 1
sb $zero, 0($t0)	# grava 0 (zero - caracter nulo)

move $a0, $t1
li $v0, 4
syscall			# imprime caracteres lidos na

# Close the file
li   $v0, 16       	# system call for close file
move $a0, $s6      	# file descriptor to close
syscall            	# close file

la $s0, buff		# s0 = &buffer
addi $s0, $s0, 54	# offset cabeçalho

# ajusta cor imagem (adiciona 0)
subi $s5, $s5, 54 	# numero de bytes arq - cabeçalho
div $s5, $s5, 3		# $s5 = numero de words

la $s1, imagem		# s1 = &imagem

#li $s4, 0		# i = 0
