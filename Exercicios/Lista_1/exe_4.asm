#exercício 4
# ler o conteudo de 0x00
#se for + salva em 0x04
#se for - salva em 0x08
.data 0x10008000
valor: .word -10
resu: .word 0,0

.text
la $t0, valor
sw $s0,0($t0)
# bge compara com zero
bge  