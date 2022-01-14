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
                 SP: DW 0
                 TAM: DB 6 ; Tamanho dos vetores

                 ;U: DB 2, 4, 5, 3 ; Vetor U
                 ;V: DB 3, 2, 2, 2; Vetor V

                 ;Exemplo Overflow
                 U: DB 127, 127, 127, 127, 127, 127 ; Vetor U
                 V: DB 100, 100, 100, 100, 100, 100; Vetor V

                 PTRU: DW U ;Ponteiro para U
                 PTRV: DW V ; Ponteiro para V

                 ; Índices
                 I: DB 0
                 J: DB 0

                 ;Caracter a ser escrito no banner
                 CARACTER: DB 0

                 ;String a ser imprimida no banner em caso de overflow



ORG 1000
                 PRODINT: DB 0  ; Resultado

ORG 0


INIT:
                 OUT CLEARBANNER ;Limpa o Banner

LOOP:
                 LDA I ; ACC = I
                 SUB TAM ; ACC = ACC - TAM  = I - TAM
                 JZ PRINTAR ; CASO I < TAM VAI PRA MULTIPLICACAO E CASO I == TAM PRINTA O RESULTADO

MULTIPLICACAO:
                LDA J ; ACC = J
                SUB @PTRV ; J - @PTRV
                JZ INCR ; CASO I < @PTRV CONTINUA SOMANDO, CASO I == @PTRV SAI DA MULTIPLICACAO

                ;J++
                LDA J
                ADD #1
                STA J

                ; PRODINT += @PTRU
                LDA PRODINT
                ADD @PTRU
                STA PRODINT

                ; ADICIONO CASO TENHA DADO OVERFLOW EM 8 BITS
                LDA PRODINT+1
                ADC #0
                JC OVERFLOW ; IMPRIMO OVERFLOW NO BANNER
                STA PRODINT+1



                ; VOLTO PARA O COMEÇO
                JMP MULTIPLICACAO

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

                ;PTRV++
                LDA PTRV
                ADD #1
                STA PTRV

                ; VOLTO PARA O COMEÇO DO LOOP
                JMP LOOP


PRINTAR:         ; A PARTIR DAQUI SERVE PARA PRINTAR O RESULTADO
                 LDA PRODINT+1
                 PUSH
                 JSR ROTINA_ALTA

                 LDA PRODINT+1
                 PUSH
                 LDA CARACTER
                 PUSH
                 JSR ROTINA_BAIXA

                 LDA PRODINT
                 PUSH
                 JSR ROTINA_ALTA

                 LDA PRODINT
                 PUSH
                 LDA CARACTER
                 PUSH
                 JSR ROTINA_BAIXA

                 JMP FIM


ROTINA_ALTA:     STS SP
                 POP
                 POP

                 POP
                 SHR
                 SHR
                 SHR
                 SHR
                 STA CARACTER

                 ; TESTO SE O NÚMERO É MENOR QUE AH OU 10 DECIMAL
                 SUB #10
                 JN  DEC ; CASO SEJA MENOR QUE 10 PULO PARA ONDE CONVERTE DE 0 A 9 PARA ASCII
                 ; CASO SEJA MAIOR CONINUO PARA CONVERTER DE LETRA PARA ASCII

                 LDA CARACTER ; CARREGO O CARACTER
                 ADD #37H ; CONVERTO HEXADECIMAL MAIOR QUE 9 PARA ASCII
                 OUT BANNER ; ESCREVO NO BANNER

                 LDS SP
                 RET
ROTINA_BAIXA:
                STS SP
                POP
                POP

                POP
                SHL
                SHL
                SHL
                SHL
                STA CARACTER


                POP
                SUB CARACTER
                STA CARACTER

                SUB #10
                JN  DEC

                LDA CARACTER
                ADD #37H
                OUT BANNER

                LDS SP
                RET


DEC: ; CONVERTE NÚMEROS DECIMAIS PARA ASCII
                 LDA CARACTER
                 ADD #30H
                 OUT BANNER

                 LDS SP
                 RET




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

