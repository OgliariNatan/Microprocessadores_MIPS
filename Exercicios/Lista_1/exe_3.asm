#exercício 3
#subtrai endereço 0x00
#subtrai endereço 0x04
#guarda em 0x08
.data 0x10008000
var: .word 8,4
resu: .word 0

.text 
la $t0, var
lw $s0, 0($t0)
lw $s1, 4($t0)
sub $s2,$s0,$s1
la $t1, resu
sw $s2,0($t1) 