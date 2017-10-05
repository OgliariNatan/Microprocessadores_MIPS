#autor: Natan 
#Mencopy

.data 0x10008000 
src: 1,2,3,4,5,6,7,8,9,10
dst:
countBytes:	.word 10
.text
	la $t0, src 		#inicializando o vetor
	la $t1, dst		# inicializando o vetor
	lw $t2, countBytes 	# countBytes = $t0
	jal memcpy 		# chamad d função
	j end

memcpy:
while:	
	beqz  $t2, endwhile 	# countBytes == 0
	lw $s0, 0($t0) 		# pega o primeiro valor
	sw $s0, 0($t1) 		# coloca o primeiro valor do vetor no segundo vetor
	add $t0, $t0, 4		# pula para a segunda posiçao do primeiro vetor
	add $t1, $t1, 4 	# pula para a segunda posição do segundo vetor
	sub $t2, $t2, 1 	# countBytes --
	j while
endwhile:
	jr $ra
end:
