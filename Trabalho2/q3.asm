;---------------------------------------------------
; Programa: programa para calcular o produto interno de dois vetores
; com elementos de 8 bits em complemento a dois.
; Autor: Carlos Bravo, Markson Arguello e Pedro Ancelmo
; Data: 11/01/2022
;---------------------------------------------------

DISPLAY EQU 0
BANNER  EQU 2
CLEARBANNER EQU 3



ORG 1100
                 SP: DW 0 ; Stack Pointer
                 TAM: DB 20 ; Tamanho dos vetores

                 U: DB 0FFh, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0FFh, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1; Vetor U
                 V: DB 0FFh, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0FFh, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1; Vetor V

                 ;Exemplo Overflow
                 ;U: DB 127, 127, 127, 127, 127, 127 ; Vetor U
                 ;V: DB 100, 100, 100, 100, 100, 100; Vetor V

                 PTRU: DW U ;Ponteiro para U
                 PTRV: DW V ; Ponteiro para V

                 ; Índices
                 I: DB 0
                 J: DB 0

                 ;Caracter a ser escrito no banner
                 CARACTER: DB 0

                 SINAL: DS 1 ; Guarda sinal do resultado
                 A: DS 1 ; Variável auxiliar
                 B: DS 1 ; Variável auxiliar


                 ;String a ser imprimida no banner em caso de overflow



ORG 1000
                 PRODINT: DW 0  ; Resultado parcial
                 RESULTADO:DW 0 ; Resultado total
                 FLAG_OVERFLOW: DS 1 ; Indica se houve overflow

ORG 0


INIT:
                 OUT CLEARBANNER ;Limpa o Banner


LOOP:
                 LDA I ; ACC = I
                 SUB TAM ; ACC = ACC - TAM  = I - TAM
                 JZ PRINTAR ; CASO I < TAM VAI PRA MULTIPLICACAO E CASO I == TAM PRINTA O RESULTADO

MULT: ; Começa multiplicação
  ; Reseta o PRODINT
  LDA #0 ;
  STA PRODINT
  STA PRODINT+1

  ; Salva primeiro operando
  LDA @PTRU
  STA A

  ; Salva segundo operando
  LDA @PTRV
  STA B

CONFERE_A: ; Confere sinal de A e verifica se é negativo
  LDA A
  AND #80h ; Se o último bit é 1 então o número é negativo
  STA SINAL ;Guardamos o sinal de A
  JZ CONFERE_B ; Se A é positivo (SINAL == 0) então não precisa fazer nada e pode conferir sinal de B

  ; Se chegou até aqui então A é negativo
  ; Transformamos A em positivo
  LDA A
  NOT
  ADD #1
  STA A

CONFERE_B: ; Confere sinal de B e verifica se é negativo
  LDA B
  AND #80h ; Se o último bit é 1 então o número é negativo
  ; Subtraimos o sinal de B com o sinal de A
  SUB SINAL
  ; Se os sinais são iguais então SINAL será 0, caso contrário SINAL será 1
  STA SINAL

  ;Verificamos o sinal de B novamente
  LDA B
  AND #80h

  JZ LOOP_MULT ; Se B for positivo não precisamos fazer nada

  ; Se chegou aqui então B é negativo
  ; Transformamos B para positivo
  LDA B
  NOT
  ADD #1
  STA B

LOOP_MULT: ; Loop da multiplicação
  LDA B
  JZ FIM_MULT ; Se já adicionamos A ao resultado B vezes então vai para o final da multiplicação
  ; Se não
  ; Subtraimos 1 de B
  SUB #1
  STA B

  ; Adicionamos A ao PRODINT
  LDA A
  ADD PRODINT
  STA PRODINT

  ; Adicionamos o carry aos 8 bits mais significativos
  LDA PRODINT+1
  ADC #0
  STA PRODINT+1

  ; Verificamos se o bit mais significativo do número de 16 bits é 1
  AND #80h
  JZ LOOP_MULT ; Se for 0 então o resultado ainda é positivo e continuamos a multiplicar

  ; Se for 1 então houve overflow já que A e B são positivos e esse 1 significaria que resultado é negativo
  ; E a multiplicação de dois números positivos não pode ser negativo
  JMP OVERFLOW

FIM_MULT: ; Fim da multiplicação
  LDA SINAL  ; Se o sinal é 0 então estamos multiplicando 2 números com sinais iguais e não precisamos fazer nada
  JZ SOMA_RESULTADO

  ; Se o sinal for 1 então precisamos trocar o sinal do resultado já que estamos multiplicando 1 positivo e 1 negativo

  ; Transformo a parte baixa do PRODINT para negativo
  LDA PRODINT
  NOT
  ADD #1
  STA PRODINT

  ; Transformo a parte alta do PRODINT para negativo
  LDA PRODINT+1
  NOT
  ADC #0
  STA PRODINT+1

SOMA_RESULTADO: ; Soma PRODINT ao RESULTADO

  LDA PRODINT+1
  AND #80h
  STA SINAL ; Salva sinal de PRODINT+1

  LDA RESULTADO+1
  AND #80h
  SUB SINAL ; Subtrai sinal de PRODINT+1 do sinal de RESULTADO+1
  STA SINAL ; Salva o valor, se 0 então sinais são iguais senão são diferentes

  LDA PRODINT ; Le PRODINT
  ADD RESULTADO ; Soma RESULTADO
  STA RESULTADO ; Salva o byte baixo

  LDA PRODINT+1 ; Le PRODINT+1
  ADC RESULTADO+1 ; Soma RESULTADO+1 com o carry
  STA RESULTADO+1 ; Salva o byte alto

  ; Verifica sinal
  LDA SINAL
  JNZ INCR ; Se diferente de 0 então vai para incremento

  ; Se for 0 então os sinais são iguais
  ; Então a soma pode dar overflow

  ; Salva sinal de PRODINT+1
  LDA PRODINT+1
  AND #80h
  STA SINAL

  ; Subtrai sinal de RESULTADO+1 de PRODINT+1
  LDA RESULTADO+1
  AND #80h
  SUB SINAL

  ; Se o resultado dessa subtração é 0 então então não houve overflow
  ; já que o sinal do resultado é o mesmo da soma

  ; Caso o resultado dessa subtração seja diferente de 0 então
  ; na soma PRODINT+1 com RESULTADO+1 houve overflow  pois
  ; PRODINT+1 e RESULTADO+1
  JNZ OVERFLOW

INCR:
                ; I++
                LDA I
                ADD #1
                STA I

                ; J = 0
                LDA #0
                STA J

                ; PTRU++
                LDA PTRU
                ADD #1
                STA PTRU

                LDA PTRU+1
                ADC #0
                STA PTRU+1

                ;PTRV++
                LDA PTRV
                ADD #1
                STA PTRV

                LDA PTRV+1
                ADC #0
                STA PTRV+1

                ; VOLTO PARA O COMEÇO DO LOOP
                JMP LOOP


PRINTAR:         ; A PARTIR DAQUI SERVE PARA PRINTAR O RESULTADO

                 ;Printa 4 bits mais altos de RESULTADO+1
                 LDA RESULTADO+1
                 PUSH
                 JSR ROTINA_ALTA

                 ;Printa 4 bits mais baixos de RESULTADO+1
                 LDA RESULTADO+1
                 PUSH
                 LDA CARACTER
                 PUSH
                 JSR ROTINA_BAIXA

                 ;Printa 4 bits mais altos de RESULTADO
                 LDA RESULTADO
                 PUSH
                 JSR ROTINA_ALTA

                 ;Printa 4 bits mais baixos de RESULTADO
                 LDA RESULTADO
                 PUSH
                 LDA CARACTER
                 PUSH
                 JSR ROTINA_BAIXA

                 JMP FIM


ROTINA_ALTA: ; Rotina para pintar a parte alta de uma variável de 8 bits
                 STS SP ; Salva Stack pointer
                 POP
                 POP

                 POP ; Pega número de 8 bits
                 ; 4 shifts para direita
                 SHR
                 SHR
                 SHR
                 SHR
                 STA CARACTER ; Guardo os bits que seram o caracter

                 ; TESTO SE O NÚMERO É MENOR QUE 0Ah OU 10 DECIMAL
                 SUB #10
                 JN  DEC ; CASO SEJA MENOR QUE 10 PULO PARA ONDE CONVERTE DE 0 A 9 PARA ASCII
                 ; CASO SEJA MAIOR CONINUO PARA CONVERTER DE LETRA PARA ASCII

                 LDA CARACTER ; CARREGO O CARACTER
                 ADD #37H ; CONVERTO HEXADECIMAL MAIOR QUE 9 PARA ASCII
                 OUT BANNER ; ESCREVO NO BANNER

                 LDS SP
                 RET
ROTINA_BAIXA: ; Rotina para pintar a parte alta de uma variável de 8 bits
                STS SP ; Salva Stack pointer
                POP
                POP

                ;O código a seguir serve para excluir os 4 bits mais significativos de uma variável
                POP ; Pego o número de 4 bits printado anteriormente
                SHL
                SHL
                SHL
                SHL
                ; Dou 4 shifts pra esquerda usando os 8 bits
                STA CARACTER ; Salvo em caracter


                POP ; Pego o número com 8 bits
                SUB CARACTER ; Excluo os 4 bits mais significativos
                STA CARACTER ; Guardo na variável o caracter

                ; TESTO SE O NÚMERO É MENOR QUE 0Ah OU 10 DECIMAL
                SUB #10
                JN  DEC ; CASO SEJA MENOR QUE 10 PULO PARA ONDE CONVERTE DE 0 A 9 PARA ASCII
                 ; CASO SEJA MAIOR CONINUO PARA CONVERTER DE LETRA PARA ASCII

                LDA CARACTER
                ADD #37H
                OUT BANNER

                LDS SP
                RET ; Fim da rotina


DEC: ; CONVERTE NÚMEROS DECIMAIS PARA ASCII
                 LDA CARACTER
                 ADD #30H
                 OUT BANNER

                 LDS SP
                 RET ; Fim da rotina




OVERFLOW:
             ADC #0
             LDA @PTRS ; Le um caracter
             OR #0 ; Se for NULL
             JZ FIM ; Termina
             OUT BANNER ;Senão escreve no banner

             ;PTRS++
             LDA PTRS
             ADD #1
             STA PTRS

             JMP OVERFLOW

FIM:         HLT

OVER:        STR    "Overflow"
             DB     0                    ; Termina com NULL
PTRS:        DW     OVER
