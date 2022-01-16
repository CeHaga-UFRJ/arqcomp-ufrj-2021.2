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
    NUM1: DS 4
    RESULT: DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

    END_NUM0: DW 0
    END_NUM1: DW 0
    END_NUM2: DW 0
    END_NUM3: DW 0

    PTR: DW RESULT
    END_RESULT: DW RESULT


    SP: DW 0
    I: DB 0
    J: DB 0

ORG 0

INIT:

  LDA #0
  STA NUM1

  LDA #0
  STA NUM1+1

  LDA #0
  STA NUM1+2

  LDA #0
  STA NUM1+3

  LDA #END_BASE
  PUSH

  LDA #NUM1
  PUSH

  JSR ROTINA
  HLT

ROTINA:
  STS SP
  POP
  POP

  POP
  STA END_NUM0

  POP
  STA END_NUM0+1


  LDA END_NUM0
  ADD #1
  STA END_NUM1

  LDA END_NUM0+1
  ADC #0
  STA END_NUM1+1

  LDA END_NUM1
  ADD #1
  STA END_NUM2

  LDA END_NUM1+1
  ADC #0
  STA END_NUM2+1

  LDA END_NUM2
  ADD #1
  STA END_NUM3

  LDA END_NUM2+1
  ADC #0
  STA END_NUM3+1


LOOP:
  ;
  LDA I
  SUB #32
  JZ PRINT ; se i = 32 printa o vetor

FOR_ADDITION: ;Loop para verificar se precisa adicionar 3
  ; acc = j - 10
  LDA J
  SUB #10
  JZ SHIFT

  ;J++
  LDA J
  ADD #1
  STA J

  ;ACC = V[J] - 5
  LDA @PTR
  SUB #5
  JN PROX

ADDITION: ;Adição de 3 na coluna que precisar
  ;V[J] += 3
  LDA @PTR
  ADD #3
  STA @PTR


PROX: ; Faz PTR apontar pro proximo elemento do vetor
  ;PTR++
  LDA PTR
  ADD #1
  STA PTR
  JMP FOR_ADDITION

SHIFT: ; Começo da parte de shift
  ;J++
  LDA #0
  STA J

  ;PTR = V
  LDA END_RESULT
  STA PTR

  ;LDA END_RESULT+1
  ;STA PTR+1

LOOP_SHIFT: ;Loop sobre os 9 primeiros elementos dando shift neles
  ; ACC = J - 9
  LDA J
  SUB #9
  JZ LAST

  ;J++
  LDA J
  ADD #1
  STA J

  ;Parte do shift
  ;V[J] <<= 1
  LDA @PTR
  SHL
  STA @PTR

  ;PTR++
  LDA PTR
  ADD #1
  STA PTR

  ;PTR
  LDA @PTR
  AND #8   ;1000
  JZ LOOP_SHIFT

  ;V[J] -= 8
  LDA @PTR
  SUB #8
  STA @PTR

  ;PTR++
  LDA PTR
  SUB #1
  STA PTR

  ;V[J]++
  LDA @PTR
  ADD #1
  STA @PTR

  ;PTR++
  LDA PTR
  ADD #1
  STA PTR

  JMP LOOP_SHIFT

LAST: ; Último elemento recebe o que estiver em NUM2+1
  ;V[J] <<= 1
  LDA @PTR
  SHL
  STA @PTR


  LDA @END_NUM3
  AND #128 ;1000 0000
  JZ ZERO

  ;V[J]++
  LDA @PTR
  ADD #1
  STA @PTR

ZERO: ; A partir daqui é shift nos numeros abaixo
  ;NUM2+1    NUM2       NUM1+1       NUM1
  ;1000 0001 0000 0001  0000 0001    1000 0000

  LDA @END_NUM3
  SHL
  STA @END_NUM3

  LDA @END_NUM2
  AND #128
  JZ SHIFT_NUM2

  LDA @END_NUM3
  ADD #1
  STA @END_NUM3

SHIFT_NUM2:
  LDA @END_NUM2
  SHL
  STA @END_NUM2

  LDA @END_NUM1
  AND #128
  JZ SHIFT_NUM1_ALTO

  LDA @END_NUM2
  ADD #1
  STA @END_NUM2

SHIFT_NUM1_ALTO:
  LDA @END_NUM1
  SHL
  STA @END_NUM1

  LDA @END_NUM0
  AND #128
  JZ INCR

  LDA @END_NUM1
  ADD #1
  STA @END_NUM1

INCR: ; Apenas arruma algumas variáveis
  LDA @END_NUM0
  SHL
  STA @END_NUM0

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
PRINT: ; A partir daqui é print no banner
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
