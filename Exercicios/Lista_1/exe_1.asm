#exercício 1
#soma endereço 0x00
#soma endereço 0x04
#guarda em 0x08

.data 0x10008000 #define o endereço base
variaveis: .word 5,6 #define um vetor com dois numeros
result: .word 0 #define um vetor para armazenar o resultado

.text #inicio o programa
la $t0, variaveis  #carrega o endereço base no registrador $t0 
lw $s0, 0($t0) # carrega o valor do registrador $t0, e armazena em $s0
lw $s1, 4($t0) # carrega o valor do registrador 4($t0), e armazena em $s1
add $s3,$s1,$s0 #soma o valores e armazena em $s3
la $t1,result #carrega o endereço de result no registrador $t2
sw $s3,0($t1) #armazena o valor da soma em $s3
#Resultado em GP#