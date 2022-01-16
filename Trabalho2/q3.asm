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
                 SINAL: DS 1
                 A: DS 1
                 B: DS 1


                 ;String a ser imprimida no banner em caso de overflow



ORG 1000
                 PRODINT: DW 0  ; Resultado
                 RESULTADO:DW 0
                 FLAG_OVERFLOW: DS 1

ORG 0


INIT:
                 OUT CLEARBANNER ;Limpa o Banner


LOOP:
                 LDA I ; ACC = I
                 SUB TAM ; ACC = ACC - TAM  = I - TAM
                 JZ PRINTAR ; CASO I < TAM VAI PRA MULTIPLICACAO E CASO I == TAM PRINTA O RESULTADO

MULT:
  LDA #0
  STA PRODINT
  STA PRODINT+1

 LDA @PTRU
 STA A

 LDA @PTRV
 STA B

CONFERE_A:
  LDA A
  AND #80h
  STA SINAL
  JZ CONFERE_B
  LDA A
  NOT
  ADD #1
  STA A

CONFERE_B:
  LDA B
  AND #80h
  SUB SINAL
  STA SINAL

  LDA B
  AND #80h

  JZ LOOP_MULT
  LDA B
  NOT
  ADD #1
  STA B

LOOP_MULT:
  LDA B
  JZ FIM_MULT
  SUB #1
  STA B

  LDA A
  ADD PRODINT
  STA PRODINT

  LDA PRODINT+1
  ADC #0
  STA PRODINT+1

  AND #80h
  JZ LOOP_MULT

  JMP OVERFLOW

FIM_MULT:
  LDA SINAL
  JZ SOMA_RESULTADO

  LDA PRODINT
  NOT
  ADD #1
  STA PRODINT

  LDA PRODINT+1
  NOT
  ADC #0
  STA PRODINT+1

SOMA_RESULTADO:
  LDA PRODINT+1
  AND #80h ; Verifica se primeiro bit e 0
  STA SINAL
  LDA RESULTADO+1
  AND #80h
  SUB SINAL
  STA SINAL

  LDA PRODINT ; Le A
  ADD RESULTADO ; Soma B
  STA RESULTADO ; Salva o byte baixo no primeiro endereco

  LDA PRODINT+1
  ADC RESULTADO+1
  STA RESULTADO+1

  LDA SINAL
  JNZ INCR

  LDA PRODINT+1
  AND #80h
  STA SINAL

  LDA RESULTADO+1
  AND #80h
  SUB SINAL

  JNZ OVERFLOW


;SOMA_RESULTADO:
;  LDA PRODINT
;  ADD RESULTADO
;  STA RESULTADO
;
;  LDA PRODINT+1
;  ADC RESULTADO+1
;  STA RESULTADO+1
;
;  LDA #0
;  STA PRODINT
;  STA PRODINT+1
;
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
                 LDA RESULTADO+1
                 PUSH
                 JSR ROTINA_ALTA

                 LDA RESULTADO+1
                 PUSH
                 LDA CARACTER
                 PUSH
                 JSR ROTINA_BAIXA

                 LDA RESULTADO
                 PUSH
                 JSR ROTINA_ALTA

                 LDA RESULTADO
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
