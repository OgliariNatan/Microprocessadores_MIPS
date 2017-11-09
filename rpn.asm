#Calculadora no modo RPN
#Author: Natan Ogliari
.data 0x10008000
	quebra_linha: .asciiz "\n"
	nova_tela: .asciiz "############## Entre com o valor ou operação (@ para sair): "
	pilha_vazia_msg: .asciiz "Termos insuficientes!\n"
	fim: .asciiz "Fim\n"
	buffer_entrada_teclado: .space 32 #Reserva 32 bytes para a entrada de teclado
									  #32 bytes são 8 words


	pilha_rpn: #.word 10, 9, 8, 7, 6, 5, 4, 3, 2, 1

.text

	#la $a0,pilha_rpn
	jal rpn

	li $v0, 4				#Imprime a divisão para uma nova tela
	la $a0, fim
	syscall

	li $v0, 10
	syscall

	rpn:
		#Argumentos:

		#Variaveis de controle:
		#t0=numero de termos na pilha rpn
		#t1=endereço do proximo termo a ser armazenado na pilha
		#t2=temporario
		#t3=temporario
		#t4=temporario
		#t5=temporario
		#t6=temporario
		#t7=inicio da pilha	dos termos armazenados


		add $t0, $zero, $zero 	#zera o numero de termos na pilha
		add $sp, $sp, -4		#coloca em t1 o endreço do proximo termo a ser armazenado
		add $t1, $sp, $zero 	#salva o endereço do stack pointer em t1
		sw $ra, 0($t1)			#salva o endereço de retorno na pilha
		add $t0, $t0, 1			#incremente o número de termos da pilha
		add $sp, $sp, -4
		add $t1, $sp, $zero		#Atualiza o valor de t1 com o end do prox termo a ser armazenado
		add $t7, $t1, $zero
		#sw $zero, 0($t1)	#Deixa o último endereço gravado com zero pra nao ter perigo


		###CONSIDERAÇÕES
		#	Se o endereço final e inicial da impresao dos 10 termos for igual é pq não há termo para imprimir
		#	O protocolo de impressão é pegar o valor correspondente ao final da pilha e ir imprimindo
		#		até encontrar um numero zero.
		#	Logicamente, para que a impressao funcione é crucial que não hajam zeros armazenados.
		#	Considerar trocar a ordem das funções para que não haja uma impressão a vazio logo no
		#		início do programa.

		#Funciona
		imprime_pilha:	#imprimirá os termos na pilha localizados de t7 até t1
						#t6=endereço iterativo da pilha (usado só nesse label)
			add $t6, $t7, $zero	#coloca em t6 o end final da pilha p decrementar durante a impressao
			add $t5, $t0, $zero #coloca em t5 o numero de termos da pilha para decrementar a medida que imprimir
			beq $t0, 1, entrada_teclado #caso nao haja termos, vai p entrada teclado
			#o primeiro termo da pilha é o return adress

			loop_imprime_pilha:
					#Caso todos os termos tenham sido impressos, vai para a entrada

				li $v0, 1				#imprime 1 termo
				lw $a0, 0($t6)
				syscall

				li $v0, 4				#quebra a linha
				la $a0, quebra_linha
				syscall

				prox_impressao:
					add $t6, $t6, -4	#decrementa o endereço
					add $t5, $t5, -1	#decrementa o número de termos
					beq $t5, 1, entrada_teclado
				#fim prox_impressao
				j loop_imprime_pilha
			#fim loop_imprime_pilha
		#fim imprime_pilha

		#Implementar e testar
		entrada_teclado:
			#t6 = endereço inicial da str de entrada (usado só nesse label)
			#t5 = resultado da leitura de um byte (usado só nesse label)
			#t4 = numero convertido iterado (usado só nesse label)

			li $v0, 4				#Imprime a divisão para uma nova tela
			la $a0, nova_tela
			syscall

			la $a0,buffer_entrada_teclado
			li $a1,32
			li $v0,8 #cada caractere é 1 byte
			syscall

			#Bloco de decodificação
				#Verificar se é número ou operador
				add $t6, $a0, $zero		#Copia para t6 o endereço da str de entrada
				lbu $t5, 0($t6)			#Grava em t5 o primeiro byte

				blt $t5, 48, sinal_deco
				bgt $t5, 57, sinal_deco

				#Ação para número
					#Incrementa a pilha_rpn com o novo termo
					# Converter a string para decimal...

					add $t4, $zero, $zero
					conv_str_int:
						sub $t5, $t5, 48		#transforma o byte lido em int
						mul $t4,$t4, 10
						add $t4, $t4, $t5		#Soma o valor da iteração
						add $t6, $t6, 1
						lbu $t5, 0($t6)			#Grava em t5 o proximo byte
						beq $t5, $zero, empilha_ndec #Caso tenha chego o fim da str, empilha
						blt $t5, 48, empilha_ndec
						bgt $t5, 57, empilha_ndec
						j conv_str_int
					#fim conv_str_int


					empilha_ndec:
						sw $t4, 0($t1)
						add $t0, $t0, 1
						add $sp, $sp, -4
						add $t1, $sp, $zero
						j imprime_pilha
					#fim empilha_ndec
				#Fim ação número

				#Ação para operador
					sinal_deco:
						#Opera e decrementa a pilha_rpn
						add $t2, $t1, $zero #Copia o endereço do ultimo termo da pilha
						lw $t6, 4($t2)		#Segundo termo (termo n)

						beq $t5, 33, sinal_fatorial
						beq $t5, 64, fim_rpn
						blt $t0, 3, pilha_vazia

						lw $t3, 8($t2)		#Primeiro termo (termo n-1)

						beq $t5, 42, sinal_multiplicacao
						beq $t5, 43, sinal_adicao
						beq $t5, 45, sinal_subtracao
						beq $t5, 47, sinal_divisao
						beq $t5, 94, sinal_potencia


						sinal_multiplicacao:
							mul $t4, $t3, $t6
							j empilha_op
						#fim sinal_multiplicacao
						sinal_adicao:
							add $t4, $t3, $t6
							j empilha_op
						#fim sinal_adicao
						sinal_subtracao:
							sub $t4, $t3, $t6
							j empilha_op
						#fim sinal_subtracao
						sinal_divisao:
							div $t4, $t3, $t6
							j empilha_op
						#fim sinal_divisao
						sinal_potencia:
							li $t2, 1
							add $t4, $t3, $zero
							sinal_potencia_loop:
								mul $t4, $t4, $t3
								add $t2, $t2, 1
								beq $t2, $t6, empilha_op
								j sinal_potencia_loop
							#fim sinal_potencia_loop
							j empilha_op
						#fim sinal_potencia
						sinal_fatorial:
							add $a0, $t6, $zero
							jal sinal_fatorial_rec
							add $t4, $v0, $zero
							add $sp, $sp, 8
							add $t1, $sp, $zero
							j empilha_fac
							sinal_fatorial_rec:
								addiu $sp, $sp, -8
								sw $a0, 0($sp)
								sw $ra, 4($sp)
								bge $a0, 1, else
									li $v0, 1
									lw $a0, 0($sp)
									lw $ra, 4($sp)
									addiu $sp, $sp, 8
									jr $ra
								else:
									addiu $a0, $a0, -1
									jal sinal_fatorial_rec
									addiu $sp, $sp, 8
									lw $a0, 0($sp)
									lw $ra, 4($sp)
									mul $v0,$v0,$a0
									jr $ra
							#fim sinal_fatorial_rec
						#fim sinal_fatorial
						empilha_op:
							add $sp, $sp, 4		#Desaloca uma word da pilha por conta da operação
							add $t0, $t0, -1	#Decrementa o valor de termos e atualzia t0
							add $t1, $sp, $zero #Atualiza o endereço do próximo número
							sw $t4, 4($t1)		#Salva o resultado da operação em 4($t1) pois t1 refere-se ao proximo termo
						j imprime_pilha
						#fim empilha_op

						empilha_fac:
							sw $t4, 4($t1)		#Como não é necessário desalocar a pilha, a operação se resume a isso
							j imprime_pilha
						#fim empilha_fac

						j imprime_pilha
					#fim sinal_deco
				#Fim ação operador

				#Controle de erros
					pilha_vazia:
						li $v0, 4				#Imprime a msg de erro pilha vazia
						la $a0, pilha_vazia_msg
						syscall

						j entrada_teclado
					#fim pilha_vazia
				#fim controle de errros
			#fim bloco de decodificação
			j imprime_pilha

	fim_rpn:	#label para quando o usuário opta por encerrar a calculadora
		mul $t3, $t0, 4		#Multiplica esse número por 4 para obter os termos em bytes
		add $t3, $t3, -4
		add $sp, $sp, $t3	#Adiciona ao sp esse número
		add $t1, $sp, $zero #Atualiza o t1
		lw $ra, 4($t1)		#Recupera ra especificamente em 4(t1) pois a posição zero é destinada para o proximo termo
		add $sp, $sp, 8		#Zera a pilha
		jr $ra
