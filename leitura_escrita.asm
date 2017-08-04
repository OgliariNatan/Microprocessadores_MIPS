.text
.globl main
main:
	add $s0, $zero, $gp # copia o valor de $gp no registradro $s0
	lbu $t0, 0($s0) # lê o byte da posição de memória [$s0+0] e copia o byte menos significativo de $t0
	lbu $t1, 1($s0)
	lbu $t2, 2($s0)
	lbu $t3, 3($s0)
	lbu $t4, 4($s0)
	lbu $t5, 5($s0)
	lbu $t6, 6($s0)
	lbu $t7, 7($s0)     #lê o byte da posição de memória [$s0+7] e copia o byte menos significativo de $t7
	lw  $t8, 0($s0)    # lê a word da posição de memória [$s0+0] e copia em $t8