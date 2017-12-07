# IFSC - Florianópolis
# 29/06/2017
# Projeto: Filtros de imagem BMP 512x512
# Profesor: Pedro Giassi Junior
# Autor: Ian S. Dannapel

# Como usar:
# 1. Monte o código no "assembler" do Mars
# 2. lena.bmp deve estar na mesma pasta
# 3. Conecte o BITMAP Display 512x512 ao MIPS
# 4. Execute
# 5. Use as opções do Menu para aplicar os filtros
# Dica: Para vizualizar melhor o Contraste, passe um Blur antes

# Caso o programa fique lento, reinicar o MARS


.data 0x10010000
#memoria para impressão = 0x 10 0000

.data 0x10110000

imagem: .space 1048576 	# 1.048.576 = 0x 10 0000

.data 0x10210000
buff: .space 786486 	# 786.486 = 0x C 0036

filename: .asciiz "lena.bmp"

cinzaR: .float 0.3	#Blue
cinzaG: .float 0.59
cinzaB: .float 0.11	# Red

buffra: .space 4

corR: .asciiz "Red:"
corG: .asciiz "Green:"
corB: .asciiz "Blue:"
intensidade: .asciiz "intensidade: "
enter: .asciiz "\n"
cls: .asciiz "\n\n\n\n\n\n\n\n\n"
tab: .asciiz "\t"

menuu: .asciiz "\t\t\t\t\tMENU:\n[1] Flip Horizontal\t[2] Flip Vertical\t\t[3] Rotação RGB\n[4] Negativo\t\t[5] Preto & Branco\t\t[6] Histograma (imprmime na tela)\n[7] Blur\t\t[8] Contraste Automático\t[9] Reset\n[0] Sair\n"


.text

main:
##############################################
#abre arquivo
la $a0, filename	# endereço da string com o nome do arquivo
li $v0, 13		# parametro p chamada de abertura
li $a1, 0		# flags (0=read, 1=write)
li $a2, 0		# mode = desnecessário
syscall			# devolve o descritor (ponteiro) do arquivo em $v0

move $s6, $v0

move $a0, $v0		# mode o descritor para $a0
li $v0, 14		# parametro de chamada de leitura de arquivo
la $a1, buff		# endereço para armazenamento dos dados lidos
li $a2, 786486		# tamanho máx de caracteres
syscall			# devolve o número de caracteres lidos

#testa abertura arquivo
bgt $v0, 0, fpnull
break
fpnull:

move $s5, $v0		# s5 = numero de caracteres

# Close the file
li   $v0, 16       	# system call for close file
move $a0, $s6      	# file descriptor to close
syscall            	# close file

##############################################


# ajusta cor imagem (adiciona 0)
subi $s5, $s5, 54 	# numero de bytes arq - cabeçalho
div $s5, $s5, 3		# $s5 = numero de words

la $s0, buff		# s0 = &buffer
addi $s0, $s0, 54	# offset cabeçalho

la $s1, imagem		# s1 = &imagem

li $s4, 0		# i = 0

loop:
beq $s4, $s5, end_adj	#s5 = numero de words

lbu $s2, ($s0)		# carrega byte R
addi $s0, $s0, 1
sb $s2, ($s1)		# grava byte R
addi $s1, $s1, 1

lbu $s2, ($s0)		# carrega byte G
addi $s0, $s0, 1
sb $s2, ($s1)		# grava byte G
addi $s1, $s1, 1

lbu $s2, ($s0)		# carrega byte B
addi $s0, $s0, 1
sb $s2, ($s1)		# grava byte B
addi $s1, $s1, 1

sb $zero, ($s1)		# grava 00
addi $s1, $s1, 1

addi $s4, $s4, 1
b  loop
end_adj:
##############################################
#ajusta imagem last byte = first byte
move $s4, $zero		# i = 0

subi $s0, $s1, 4	# ponteiro da última word
la $s1, imagem		# ponteiro da primeira word

loop3:
bge $s4, $s5, inverte
lw $s2,($s0)
lw $s3,($s1)
sw $s2,($s1)
sw $s3,($s0)
addi $s1, $s1, 4
subi $s0, $s0, 4
addi $s4, $s4, 2
j loop3
inverte:

la $a0, imagem
jal flip_horizontal
b printi

menu:

la $a0, cls
li $v0, 4
syscall			# print cls

la $a0, menuu
syscall			# print Menu

li $v0, 5		# read INT
syscall

beq $v0, 0, sair

beq $v0, 9, main

la $a0, imagem		# s1 = imagem

bne $v0, 1, not_fliph
jal flip_horizontal
b printi
not_fliph:

bne $v0, 2, not_flipv
jal flip_vertical
b printi
not_flipv:

bne $v0, 3, not_rot
jal rotacaoRGB
b printi
not_rot:

bne $v0, 4, not_neg
jal negativo
b printi
not_neg:

bne $v0, 5, not_cin
jal cinza
b printi
not_cin:

bne $v0, 6, not_histo
li $a1, 1		# imprmir histograma
jal histograma
b printi
not_histo:

bne $v0, 7, not_blur
jal media3_3
b printi
not_blur:

bne $v0, 8, not_cont
jal contraste
b printi
not_cont:

printi:
la $s1, imagem		# s1 = imagem
li $s3, 0x10010000	# s3 = bitmapdisp
move $s4, $zero		# i = 0

loop2:
bge $s4, $s5, end_print
lw $s2, ($s1)
sw $s2, ($s3)
addi $s1, $s1, 4
addi $s3, $s3, 4
addi $s4, $s4, 1
b loop2
end_print:
b menu


sair:
li $v0, 10
syscall
##############################################
##############################################
##############################################
flip_horizontal:
# a0 = endereço da imagem
# a1 = n words


move $t5, $0		# j = 0

loop_coluna:
bge $t5, 512, end_colunas

move $t0, $a0		# x = 0, y = 0
mulo $t6, $t5, 2048	# ajusta coluna
add $t0, $t0, $t6
addi $t1, $t0, 2044	# ultimo endereço da coluna

move $t4, $0		# i = 0
loop_linha:
bge $t4, 256, end_linha
lw $t2, ($t0)		# swap
lw $t3, ($t1)
sw $t3, ($t0)
sw $t2, ($t1)

addi $t0, $t0, 4
subi $t1, $t1, 4

addiu $t4, $t4, 1	# i ++
j loop_linha
end_linha:


addi $t5, $t5, 1	# j++
j loop_coluna
end_colunas:

jr $ra
##############################################
flip_vertical:
# a0 = endereço da imagem

move $t5, $0		# j = 0

flip_vert:
bge $t5, 256, end_flip_vert

move $t0, $a0		# x0, y0
addi $t1, $t0, 1046528	# x0, y min;

mulo $t6, $t5, 2048	# ajusta linha
add $t0, $t0, $t6	# t0 = linha (j)

sub $t1, $t1, $t6	# t1 = -linha (j)+512


move $t4, $0		# i = 0
swap:
bge $t4, 512, end_swap
lw $t2, ($t0)		# swap
lw $t3, ($t1)
sw $t3, ($t0)
sw $t2, ($t1)

addi $t0, $t0, 4
addi $t1, $t1, 4

addiu $t4, $t4, 1	# i ++
j swap
end_swap:


addi $t5, $t5, 1	# j++
j flip_vert
end_flip_vert:

jr $ra
##############################################

# 0x 00 RR GG BB => 0x 00 BB RR GG

# $a0 =  endereço imagem

rotacaoRGB:

move $t4, $a0
move $t3, $0		# i=0

go_rot:
bge $t3, 262144,end_rot

lbu $t0, 0($t4)		# t2 = BB
lbu $t1, 1($t4)		# t2 = GG
lbu $t2, 2($t4)		# t2 = RR

sb $t0, 2($t4)
sb $t1, 0($t4)
sb $t2, 1($t4)


addi $t4, $t4, 4
addi $t3, $t3, 1	# i++

j go_rot
end_rot:


jr $ra

##############################################
# $a0 endereço imagem
negativo:

move $t4, $a0

move $t3, $0		# i=0

go_neg:
bge $t3, 262144,end_neg

lbu $t0, 0($t4)		# t2 = RR
lbu $t1, 1($t4)		# t2 = GG
lbu $t2, 2($t4)		# t2 = BB

neg $t0, $t0
addi $t0, $t0, 255

neg $t1, $t1
addi $t1, $t1, 255

neg $t2, $t2
addi $t2, $t2, 255

sb $t0, 0($t4)
sb $t1, 1($t4)
sb $t2, 2($t4)


addi $t4, $t4, 4
addi $t3, $t3, 1	# i++

j go_neg
end_neg:


jr $ra
##############################################
# 0x 00 RR GG BB

# $a0 endereço imagem
cinza:

move $t4, $a0

move $t3, $0		# i=0

go_cinza:
bge $t3, 262144,end_cin

lbu $t0, 0($t4)		# t2 = RR
mtc1 $t0, $f0
cvt.s.w $f0, $f0
l.s $f1, cinzaB
mul.s $f0, $f1, $f0

lbu $t1, 1($t4)		# t2 = GG
mtc1 $t1, $f1
cvt.s.w $f1, $f1
l.s $f2, cinzaG
mul.s $f1, $f1, $f2

lbu $t2, 2($t4)		# t2 = BB
mtc1 $t2, $f2
cvt.s.w $f2, $f2
l.s $f3, cinzaR
mul.s $f2, $f2, $f3

add.s $f1, $f2, $f1
add.s $f0, $f0, $f1

cvt.w.s $f0, $f0
mfc1 $t0, $f0

sb $t0, 0($t4)
sb $t0, 1($t4)
sb $t0, 2($t4)

addi $t4, $t4, 4
addi $t3, $t3, 1	# i++

j go_cinza
end_cin:

jr $ra
##############################################
histograma:
# $a0 endereço imagem
# $a1 = 0 não imprmir, = 1 imprimir
# $v0 retorna ponteiro das 256*3 cores
# pseudo code:
# pilha:
# (0..255)*4 = ocorrencias azul
# 256..511 = ocorrencias verde
# 512..767 = ocorrencias vermelho

#zera pilha para cima:

subi $sp, $sp, 4
move $t9, $sp		# salva pilha

li $t0, 0		# i = 0

go_zera:
bge $t0, 800, end_zera	# zera pilha (3x255)

sw $0, ($sp)
subi $sp, $sp, 4

addi $t0, $t0, 1
j go_zera
end_zera:
move $sp, $t9		# pilha[0] = Blue_0


move $t1, $a0
li $t0, 0		# i = 0
go_histB:
bge $t0, 262144, end_histB

lbu $t2, 0($t1)		# load blue
mulo $t2, $t2, 4
sub $sp, $sp, $t2	# offset igual ao numero da cor
lw $t3, ($sp)
addi $t3, $t3, 1	# adiciona 1 ocorrencia
sw $t3, ($sp)
add $sp, $sp, $t2	# restora pilha

addi $t1, $t1, 4	# avança ponteiro

addi $t0, $t0, 1
j go_histB
end_histB:

move $t1, $a0
li $t0, 0		# i = 0
subi $sp, $sp, 1024	# offset verde 256*4
go_histG:
bge $t0, 262144, end_histG

lbu $t2, 1($t1)		# load blue
mulo $t2, $t2, 4
sub $sp, $sp, $t2	# offset igual ao numero da cor
lw $t3, ($sp)
addi $t3, $t3, 1	# adiciona 1 ocorrencia
sw $t3, ($sp)
add $sp, $sp, $t2	# restora pilha

addi $t1, $t1, 4	# avança ponteiro

addi $t0, $t0, 1
j go_histG
end_histG:

move $t1, $a0
li $t0, 0		# i = 0
subi $sp, $sp, 1024	# offset vermelho
go_histR:
bge $t0, 262144, end_histR

lbu $t2, 2($t1)		# load red
mulo $t2, $t2, 4
sub $sp, $sp, $t2	# offset igual ao numero da cor
lw $t3, ($sp)
addi $t3, $t3, 1	# adiciona 1 ocorrencia
sw $t3, ($sp)
add $sp, $sp, $t2	# restora pilha

addi $t1, $t1, 4	# avança ponteiro

addi $t0, $t0, 1
j go_histR
end_histR:

#print histograma:
beq $a1, 0, nao_imp

li $v0, 4

la $a0, intensidade	# print intensidade:
syscall

la $a0, enter		# print enter:
syscall

la $a0, corB		# print Blue:
syscall

la $a0, tab
syscall

la $a0, corG		# print Green:
syscall

la $a0, tab
syscall

la $a0, corR		# print Red:
syscall

la $a0, enter		# print enter:
syscall

li $t0, 0		# i = 0

move $sp, $t9		# pilha[0] = Blue_0

go_print_histo:
bge $t0, 256, end_print_histo

li $v0, 1
move $a0, $t0		# print valor intensidade
syscall

li $v0, 4
la $a0, enter		# print enter:
syscall

lw $a0, 0($sp)		# pop ocorrencias Blue
li $v0, 1
syscall

li $v0, 4
la $a0, tab		# print tab:
syscall

lw $a0, -1024($sp)	# pop ocorrencias Green
li $v0, 1
syscall

li $v0, 4
la $a0, tab		# print tab:
syscall

lw $a0, -2048($sp)	# pop ocorrencias Red
li $v0, 1
syscall

li $v0, 4
la $a0, enter		# print enter:
syscall

subi $sp, $sp, 4	# avança $sp

addi $t0, $t0, 1
j go_print_histo
end_print_histo:

nao_imp:

move $sp, $t9		# restora pilha
addi $sp, $sp, 4

move $v0, $t9

jr $ra
##############################################
media3_3:
#
#  	1 2 3	=> 	1 2 3
#	4 x 6	=>	4 m 6
#	7 8 9	=>	7 8 9
#
# $a0 endereço imagem x=0 y=0
subi $sp, $sp, 8
move $t6, $ra

move $t4, $0		# i = 0

move $t8, $sp
subi $t8, $t8, 4	# salva $sp

go_C:
bge $t4, 510, end_C

move $t5, $0		# j = 0

move $t3, $a0
addi $t3, $t3, 2052	# x= -1; y= -1

#ajusta linha
mulo $t7, $t4, 2048
add $t3, $t3, $t7	# x = -1; y = -j-1

go_L:
bge $t5, 510, end_L

move $a1, $t3
jal med_viz		# $t0, $t1, $t2

subi $sp, $sp, 4
sw $v0, ($sp)		# push novo pixel

addi $t3, $t3, 4	# pixel ++
addi $t5, $t5, 1	# j++

j go_L
end_L:

addi $t4, $t4, 1	# i++

j go_C
end_C:

move $sp, $t8		# restora pilha

# novos pixels em ordem a partir do x=-1 e y=-1 (510x510) em ($sp)
# refazendo a imagem...

move $t4, $0		# i = 0

go_C2:
bge $t4, 510, end_C2

move $t5, $0		# j = 0

move $t3, $a0
addi $t3, $t3, 2052	# x= -1; y= -1

#ajusta linha
mulo $t7, $t4, 2048
add $t3, $t3, $t7	# x = -1; y = -j-1

go_L2:
bge $t5, 510, end_L2

lw $t9, ($sp)		# pop novo pixel
sw $t9, ($t3)		# salva novo pixel

addi $t3, $t3, 4	# pixel ++
subi $sp, $sp, 4	# pilha --
addi $t5, $t5, 1	# j++

j go_L2
end_L2:

addi $t4, $t4, 1	# i++

j go_C2
end_C2:

move $sp, $t8		# restora pilha
addi $sp, $sp, 4

move $ra, $t6		# restore $ra

jr $ra
##############################################
med_viz:

# $a1 endereço pixel
# $v0 média vizinhos


move $t2, $0		# soma = 0
move $t0, $0		# soma = 0

lbu $t1, -2052($a1)	# pixel 1 B		+1 =R   +2=G
add $t2, $t2, $t1

lbu $t1, -2048($a1)	#pixel 2 B
add $t2, $t2, $t1

lbu $t1, -2044($a1)	#pixel 3 B
add $t2, $t2, $t1

lbu $t1, -4($a1)	#pixel 4 B
add $t2, $t2, $t1

lbu $t1, 4($a1)		#pixel 6 B
add $t2, $t2, $t1

lbu $t1, 2044($a1)	#pixel 7 B
add $t2, $t2, $t1

lbu $t1, 2048($a1)	#pixel 8 B
add $t2, $t2, $t1

lbu $t1, 2052($a1)	#pixel 9 B
add $t2, $t2, $t1

div $t0, $t2, 8
	####
move $t2, $0

lbu $t1, -2051($a1)	# pixel 1 GREEN
add $t2, $t2, $t1

lbu $t1, -2047($a1)	#pixel 2 R
add $t2, $t2, $t1

lbu $t1, -2043($a1)	#pixel 3 R
add $t2, $t2, $t1

lbu $t1, -3($a1)	#pixel 4 R
add $t2, $t2, $t1

lbu $t1, 5($a1)		#pixel 6 R
add $t2, $t2, $t1

lbu $t1, 2045($a1)	#pixel 7 R
add $t2, $t2, $t1

lbu $t1, 2049($a1)	#pixel 8 R
add $t2, $t2, $t1

lbu $t1, 2053($a1)	#pixel 9 R
add $t2, $t2, $t1

div $t2, $t2, 8
sll $t2, $t2, 8
or $t0, $t2, $t0

	####
move $t2, $0
lbu $t1, -2050($a1)	# pixel 1 RED
add $t2, $t2, $t1

lbu $t1, -2046($a1)	#pixel 2 G
add $t2, $t2, $t1

lbu $t1, -2042($a1)	#pixel 3 G
add $t2, $t2, $t1

lbu $t1, -2($a1)	#pixel 4 G
add $t2, $t2, $t1

lbu $t1, 6($a1)		#pixel 6 G
add $t2, $t2, $t1

lbu $t1, 2046($a1)	#pixel 7 G
add $t2, $t2, $t1

lbu $t1, 2050($a1)	#pixel 8 G
add $t2, $t2, $t1

lbu $t1, 2054($a1)	#pixel 9 G
add $t2, $t2, $t1

div $t2, $t2, 8
sll $t2, $t2, 16
or $t0, $t2, $t0

move $v0, $t0

jr $ra

##############################################
contraste:
#$a0 endereço imagem
#Inew(x,y) = [I(x,y) - Ilow] * [255 / (Ihigh - Ilow)]


sw $ra, buffra

li $a1, 0		# para histograma não imprimir
jal histograma		# procurar maior e menor intensidade de cada cor

# azul:

move $t1, $v0		# ponteiro no azul 0 (decrementar para avançar)

#busca azul

li $t0, 0		# i =0

li $t3, 255		# maior intensidade
li $t4, 0		# menor intensidade

go_maiorB:
bge $t0, 256, busca_maiorB

lw $t2, ($t1)		# carrega ocorrencias Blue

ble $t2, 0, maiorB
move $t3, $t0		# se tem ocorrencia em t0, então t0 é a maior intensidade
maiorB:

subi $t1, $t1, 4	# azul --
addi $t0, $t0, 1	# i++

j go_maiorB
busca_maiorB:

go_menorB:
blt $t0, 0, busca_menorB

lw $t2, ($t1)		# carrega ocorrencias Blue

ble $t2, 0, menorB
move $t4, $t0		# se tem ocorrencia em t0, então t0 é a menor intensidade
menorB:

addi $t1, $t1, 4	# azul ++
subi $t0, $t0, 1	# j--

j go_menorB
busca_menorB:

#reconstroi azul
li $t0, 0		# i = 0

sub $t3, $t3, $t4	# (Ihigh - Ilow)
##
mtc1 $t3, $f1
cvt.s.w $f1, $f1
##
li $t5, 255
##
mtc1 $t5, $f0
cvt.s.w $f0, $f0
##
#div $t3, $t5, $t3 	# [255 / (Ihigh - Ilow)]
div.s $f0,$f0,$f1

move $t1, $a0

go_goB1:
bge $t0, 262144, rec_azul

lbu $t2, 0($t1)		# carrega azul
sub $t2, $t2, $t4	# [I(x,y) - Ilow]
##
mtc1 $t2, $f2
cvt.s.w $f2, $f2

#mulou $t2, $t2, $t3	# Inew(x,y) = [I(x,y) - Ilow] * [255 / (Ihigh - Ilow)]
mul.s $f2, $f2, $f0
cvt.w.s $f2, $f2
mfc1 $t2, $f2

##
sb $t2, 0($t1)		# salva nova intensidade

addi $t1, $t1, 4	# azul ++
addi $t0, $t0, 1	# i++

j go_goB1
rec_azul:


# verde

move $t1, $v0		# ponteiro no azul 0
subi $t1, $t1, 1024	# ponteiro no verde 0


# busca maior verde

li $t0, 0		# i =0

li $t3, 255		# maior intensidade
li $t4, 0		# menor intensidade

go_maiorG:
bge $t0, 256, busca_maiorG

lw $t2, ($t1)		# carrega ocorrencias Green

ble $t2, 0, maiorG
move $t3, $t0		# se tem ocorrencia em t0, então t0 é a maior intensidade
maiorG:

subi $t1, $t1, 4	# Green --
addi $t0, $t0, 1	# i++

j go_maiorG
busca_maiorG:

go_menorG:
blt $t0, 0, busca_menorG

lw $t2, ($t1)		# carrega ocorrencias Green

ble $t2, 0, menorG
move $t4, $t0		# se tem ocorrencia em t0, então t0 é a menor intensidade
menorG:

addi $t1, $t1, 4	# Green ++
subi $t0, $t0, 1	# j--

j go_menorG
busca_menorG:




#reconstroi verde
li $t0, 0		# i = 0

sub $t3, $t3, $t4	# (Ihigh - Ilow)
##
mtc1 $t3, $f1
cvt.s.w $f1, $f1
##
li $t5, 255
##
mtc1 $t5, $f0
cvt.s.w $f0, $f0
##
#div $t3, $t5, $t3 	# [255 / (Ihigh - Ilow)]
div.s $f0,$f0,$f1

move $t1, $a0

go_goG1:
bge $t0, 262144, rec_verde

lbu $t2, 1($t1)		# carrega verde
sub $t2, $t2, $t4	# [I(x,y) - Ilow]

##
mtc1 $t2, $f2
cvt.s.w $f2, $f2
#mulou $t2, $t2, $t3	# Inew(x,y) = [I(x,y) - Ilow] * [255 / (Ihigh - Ilow)]
mul.s $f2, $f2, $f0
cvt.w.s $f2, $f2
mfc1 $t2, $f2
##
sb $t2, 1($t1)		# salva nova intensidade

addi $t1, $t1, 4	# Green ++
addi $t0, $t0, 1	# i++

j go_goG1
rec_verde:



#vermelho

move $t1, $v0		# ponteiro no azul 0
subi $t1, $t1, 2048	# ponteiro no vermelho 0


# busca maior vermelho

li $t0, 0		# i =0

li $t3, 255		# maior intensidade
li $t4, 0		# menor intensidade

go_maiorV:
bge $t0, 256, busca_maiorV

lw $t2, ($t1)		# carrega ocorrencias red

ble $t2, 0, maiorV
move $t3, $t0		# se tem ocorrencia em t0, então t0 é a maior intensidade
maiorV:

subi $t1, $t1, 4	# red --
addi $t0, $t0, 1	# i++

j go_maiorV
busca_maiorV:

go_menorV:
blt $t0, 0, busca_menorV

lw $t2, ($t1)		# carrega ocorrencias RED

ble $t2, 0, menorV
move $t4, $t0		# se tem ocorrencia em t0, então t0 é a menor intensidade
menorV:

addi $t1, $t1, 4	# RED ++
subi $t0, $t0, 1	# j--

j go_menorV
busca_menorV:




#reconstroi vermelho
li $t0, 0		# i = 0

sub $t3, $t3, $t4	# (Ihigh - Ilow)
##
mtc1 $t3, $f1
cvt.s.w $f1, $f1
##
li $t5, 255
##
mtc1 $t5, $f0
cvt.s.w $f0, $f0
##
#div $t3, $t5, $t3 	# [255 / (Ihigh - Ilow)]
div.s $f0,$f0,$f1

move $t1, $a0

go_goV1:
bge $t0, 262144, rec_vermelho

lbu $t2, 2($t1)		# carrega R
sub $t2, $t2, $t4	# [I(x,y) - Ilow]
##
mtc1 $t2, $f2
cvt.s.w $f2, $f2
#mulou $t2, $t2, $t3	# Inew(x,y) = [I(x,y) - Ilow] * [255 / (Ihigh - Ilow)]
mul.s $f2, $f2, $f0
cvt.w.s $f2, $f2
mfc1 $t2, $f2
##
sb $t2, 2($t1)		# salva nova intensidade

addi $t1, $t1, 4	# verlho ++
addi $t0, $t0, 1	# i++

j go_goV1
rec_vermelho:

lw $ra, buffra

jr $ra
