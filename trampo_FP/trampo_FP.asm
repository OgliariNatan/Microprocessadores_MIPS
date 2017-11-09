#######Author Natan Ogliari######
#################################
#No main: Solicitar 3 valeres de um vetor
#No multi: Multipliar por um vetor com
########################################

.data
pergunta: .asciiz "Entre com um valor \n"


.text
  main:
        la $a0, pergunta
        li $v0, 4 #Prepara para imprimir na tela
        syscall

        li $v0, 6 #Prepara para leitura
        syscall
        move   $t0, $v0    #  =

  mult:
  
  end:
