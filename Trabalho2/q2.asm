;---------------------------------------------------
; Programa:
; Autor:
; Data:
;---------------------------------------------------

ORG 200
I:      DB 8
A:      DB 3
NOVOB:  DB 0
CARRYUNIDADE:  DB 0
CARRYDEZENA:   DB 0
MILHAO: DB 0
MILHAR: DB 0
CENTENA:DB 0
DEZENA: DB 0
UNIDADE:DB 0

ORG 0

BTD:
;PROCEDIMENTO
    LDA A
    SHL
    STA A
    LDA #0
    ADC #0
    STA CARRYUNIDADE
    LDA UNIDADE
    SHL
    STA UNIDADE
    LDA #0
    ADC #0
    STA CARRYDEZENA
    LDA UNIDADE
    OR CARRYUNIDADE
    STA UNIDADE

    SUB #5
    JN UNIDADEPOS
    ;CASO A UNIDADE SEJA 5 OU MAIOR
    LDA UNIDADE
    ADD #3
    STA UNIDADE
UNIDADEPOS:
    LDA DEZENA
    SHL
    OR CARRYDEZENA
    STA DEZENA
    LDA #0
    STA CARRYUNIDADE
    ;SHL
    ;LDA I
    ;OUT 0
    LDA I
    SUB #1
    STA I
    JZ FIM
    JMP BTD
FIM:
    LDA UNIDADE
    OUT 0
    LDA DEZENA
    OUT 0
    OUT 2
    HLT






