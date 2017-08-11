#exercício 2
#soma endereço 0x00
#soma endereço 0x04
#soma endereço 0x08
#guarda em 0x0C
.data 0x10008000 #define o endereço base
var: .word 5,5,5 #define um vetor com dois numeros
result: .word 0 #define um vetor para armazenar o resultado

.text #inicia o programa
la $t0, var
lw $s0, 0($t0)
lw $s1, 4($t0)
lw $s2, 8($t0)
add $s3, $s1,$s0
add $s3, $s3,$s2
la $t1, result
sw $s3,0($t1)
