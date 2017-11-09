.data
pergunta: 		.asciiz "\n\n Entre com o valor desejadoa ser elevado ao quadrado:  "
Resp1:		.asciiz "\nResposta em FP: "
Resp2:		.asciiz "\nResposta em Int: "
overflow_FP:	.asciiz "\n\n Overflow FP Babe!"
overflow_INT:	.asciiz "\n\n Overflow Inteiro (32 bits)!"

.text

la $a0, pergunta
li $v0, 4
syscall

li $v0, 6
syscall

mov.d $f12, $f0		#copia conteudo para $f12
mul.s $f12, $f12, $f0	# multiplica por ele mesmo

la $a0, Resp1
li $v0, 4
syscall

li $v0, 2			# imprime resultado FP single precision
syscall

la $a0, Resp2
li $v0, 4
syscall

cvt.w.s $f0, $f12 	#converte de single precision para word
mfc1 $a0, $f0 		# traz para ergistrador $a0
li $v0, 1			# imprime resultado PONTO FIXO
syscall

mfc1 $t0, $f12		#joga em $v0
srl $t0, $t0, 23		
addi $t1, $zero, 255
and $t0, $t0, $t1
bne $t0, $t1, end

la $a0, overflow_FP
li $v0, 4
syscall	

end: 
	nop	