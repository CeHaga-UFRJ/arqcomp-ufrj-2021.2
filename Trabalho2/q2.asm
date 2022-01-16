;---------------------------------------------------
; Programa: recebe na pilha o endereço de uma variável de 32 bits
; com sinal para ser convertida em um número decimal a ser impresso
; no banner
; Autor: Carlos Bravo, Markson Arguello e Pedro Ancelmo
; Data: 16/01/2022
;---------------------------------------------------

END_BASE EQU 05h
CLEARBANNER EQU 3
BANNER  EQU 2

ORG 500h
    RESULT: DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    NUM1: DW 0
    NUM2: DW 0

    PTR: DW RESULT
    END_RESULT: DW RESULT


    SP: DW 0
    I: DB 0
    J: DB 0

ORG 0

INIT:

  LDA #0FFh
  PUSH

  LDA #0FFh
  PUSH

  LDA #0FFh
  PUSH

  LDA #0FFh
  PUSH
  JSR ROTINA
  HLT

ROTINA:
  STS SP
  POP
  POP

  POP
  STA NUM1

  POP
  STA NUM1+1

  POP
  STA NUM2

  POP
  STA NUM2+1


LOOP:
  LDA I
  SUB #32
  JZ PRINT

FOR_ADDITION:
  LDA J
  SUB #10
  JZ SHIFT

  LDA J
  ADD #1
  STA J

  LDA @PTR
  SUB #5
  JN PROX

ADDITION:
  LDA @PTR
  ADD #3
  STA @PTR


PROX:
  LDA PTR
  ADD #1
  STA PTR
  JMP FOR_ADDITION

SHIFT:
  LDA #0
  STA J

  LDA END_RESULT
  STA PTR

  ;LDA END_RESULT+1
  ;STA PTR+1

LOOP_SHIFT:
  LDA J
  SUB #9
  JZ LAST

  LDA J
  ADD #1
  STA J

  LDA @PTR
  SHL
  STA @PTR

  LDA PTR
  ADD #1
  STA PTR

  LDA @PTR
  AND #8
  JZ LOOP_SHIFT

  LDA @PTR
  SUB #8
  STA @PTR

  LDA PTR
  SUB #1
  STA PTR

  LDA @PTR
  ADD #1
  STA @PTR

  LDA PTR
  ADD #1
  STA PTR

  JMP LOOP_SHIFT



LAST:
  LDA @PTR
  SHL
  STA @PTR

  LDA NUM2+1
  AND #128
  JZ ZERO

  LDA @PTR
  ADD #1
  STA @PTR

ZERO:
  LDA NUM2+1
  SHL
  STA NUM2+1

  LDA NUM2
  AND #128
  JZ SHIFT_NUM2

  LDA NUM2+1
  ADD #1
  STA NUM2+1

SHIFT_NUM2:
  LDA NUM2
  SHL
  STA NUM2

  LDA NUM1+1
  AND #128
  JZ SHIFT_NUM1_ALTO

  LDA NUM2
  ADD #1
  STA NUM2

SHIFT_NUM1_ALTO:
  LDA NUM1+1
  SHL
  STA NUM1+1

  LDA NUM1
  AND #128
  JZ INCR

  LDA NUM1+1
  ADD #1
  STA NUM1+1

INCR:
  LDA NUM1
  SHL
  STA NUM1

  LDA I
  ADD #1
  STA I

  LDA #0
  STA J

  LDA END_RESULT
  STA PTR

  ;LDA END_RESULT+1
  ;STA PTR+1

  JMP LOOP
PRINT:
  OUT CLEARBANNER
LOOP_PRINT:
  LDA J
  SUB #10
  JZ RETORNO

  LDA J
  ADD #1
  STA J

  LDA @PTR
  ADD #30H
  OUT BANNER

  LDA PTR
  ADD #1
  STA PTR
  JMP LOOP_PRINT

RETORNO:
  LDS SP
  RET
