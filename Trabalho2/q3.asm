;---------------------------------------------------
; Programa: programa para calcular o produto interno de dois vetores
; com elementos de 8 bits em complemento a dois.
; Autor: Carlos Bravo, Markson Arguello e Pedro Ancelmo
; Data: 11/01/2022
;---------------------------------------------------

DISPLAY EQU 0
BANNER  EQU 2
CLEARBANNER EQU 3

ORG 400
    PRODINT: DB 0  ; Resultado

ORG 500
    TAM: DB 3 ; Tamanho dos vetores
    U: DB 37, 42, 66 ; Vetor U
    V: DB 10, 10, 10 ; Vetor V

    PTRU: DW U ;Ponteiro para U
    PTRV: DW V ; Ponteiro para V

    ; Índices
    I: DB 0
    J: DB 0

    ;Caracter a ser escrito no banner
    CARACTER: DB 0

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


PRINTAR: ; A PARTIR DAQUI SERVE PARA PRINTAR O RESULTADO

PRIMEIRO_NUMERO: ; O PRIMEIRO NÚMERO SÃO OS 4 PRIMEIROS BITS DO NÚMERO DE 16 BITS

              ; PEGO APENAS OS 4 BITS MAIS SIGNIFICATIVOS E GUARDO EM CARACTER
              LDA PRODINT+1
              SHR
              SHR
              SHR
              SHR
              STA CARACTER

              ; TESTO SE O NÚMERO É MENOR QUE AH OU 10 DECIMAL
              SUB #10
              JN  DEC0 ; CASO SEJA MENOR QUE 10 PULO PARA ONDE CONVERTE DE 0 A 9 PARA ASCII
              ; CASO SEJA MAIOR CONINUO PARA CONVERTER DE LETRA PARA ASCII

              LDA CARACTER ; CARREGO O CARACTER
              ADD #37H ; CONVERTO HEXADECIMAL MAIOR QUE 9 PARA ASCII
              OUT BANNER ; ESCREVO NO BANNER

              JMP SEGUNDO_NUMERO ; VOU PARA O PRÓXIMO NÚMERO

          DEC0: ; CONVERTE NÚMEROS DECIMAIS PARA ASCII
              LDA CARACTER
              ADD #30H
              OUT BANNER



SEGUNDO_NUMERO:
                LDA CARACTER
                SHL
                SHL
                SHL
                SHL
                STA CARACTER


                LDA PRODINT+1
                SUB CARACTER
                STA CARACTER

                SUB #10
                JN  DEC1 ;

                LDA CARACTER
                ADD #37H
                OUT BANNER
                JMP TERCEIRO_NUMERO

          DEC1:
               LDA CARACTER
               ADD #30H
               OUT BANNER





TERCEIRO_NUMERO:
    LDA PRODINT
    SHR
    SHR
    SHR
    SHR
    STA CARACTER

    SUB #10
    JN  DEC2

    LDA CARACTER
    ADD #37H
    OUT BANNER

    JMP QUARTO_NUMERO

DEC2:
    LDA CARACTER
    ADD #30H
    OUT BANNER





QUARTO_NUMERO:
      LDA CARACTER
      SHL
      SHL
      SHL
      SHL
      STA CARACTER


      LDA PRODINT
      SUB CARACTER
      STA CARACTER

      SUB #10
      JN  DEC3

      LDA CARACTER
      ADD #37H
      OUT BANNER

      JMP FIM

DEC3:
     LDA CARACTER
     ADD #30H
     OUT BANNER


FIM:    HLT

