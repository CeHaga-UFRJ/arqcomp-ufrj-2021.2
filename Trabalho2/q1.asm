;---------------------------------------------------
; Programa: Escrever uma rotina para somar ou para multiplicar
; dois números de 8 bits em complemento a dois, cujos endereços
; são passados como parâmetros na pilha.
; Autor: Carlos Bravo, Markson Arguello, Pedro Ancelmo
; Data: 14/01/2022
;---------------------------------------------------
SUM EQU 0
VEZES EQU 1
END_BASE EQU 04h

ORG 400h
  OP: DS 1 ; Operacao a ser realizada
  SP: DW 0 ; Stack Pointer da pilha
  END_A: DW 0 ; Primeiro operando
  END_B: DW 0 ; Segundo operando
  A: DS 1
  B: DS 1
  RESULT: DW 0 ; Endereco do resultado
  SINAL: DS 1 ; Variavel para salvar os sinais
  OVERFLOW: DS 1 ; Variavel para salvar se houve overflow ou nao

  NUM1: DS 1
  NUM2: DS 1

ORG 430h
  NUM3: DW 0

ORG 160h




ORG 0
INICIO:
  LDA #1
  STA NUM1

  LDA #END_BASE
  PUSH

  LDA #NUM1
  PUSH

  LDA #0FFh
  STA NUM2

  LDA #END_BASE
  PUSH

  LDA #NUM2
  PUSH


  LDA #END_BASE
  PUSH

  LDA #NUM3
  PUSH

  LDA #1

  JSR CALC
  HLT


CALC:
  STA OP ; Salva o operador do acumulador

  STS SP ; Salva o Stack Pointer
  POP ; E remove da pilha
  POP ; Sendo 16 bit

  POP ; Le o endereco do resultado
  STA RESULT
  POP
  STA RESULT+1

  POP ; Le o endereco do primeiro operando da pilha
  STA END_A
  POP
  STA END_A+1

  POP ; Le o endereco do segundo operando da pilha
  STA END_B
  POP
  STA END_B+1

  LDA @END_A
  STA A

  LDA @END_B
  STA B

  LDA OP
  JZ SOMA ; Se for 0 faz uma soma

  LDA B ; Se A ou B for 0, e eh multiplicacao, resultado eh 0
  JZ EH_ZERO
  LDA A
  JZ EH_ZERO

MULT:
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
  ADD @RESULT
  STA @RESULT

  LDA @RESULT+1
  ADC #0
  STA @RESULT+1

  AND #80h
  JZ LOOP_MULT

  LDA #1
  STA OVERFLOW
  JMP LOOP_MULT

FIM_MULT:
  LDA SINAL
  JZ RETORNO

  LDA @RESULT
  NOT
  ADD #1
  STA @RESULT

  LDA @RESULT+1
  NOT
  ADC #0
  STA @RESULT+1

  JMP RETORNO

EH_ZERO:
  LDA #0 ; Nao houve overflow, acumulador eh 0
  STA @RESULT ; Salva 0 nos 2 bytes do resultado
  STA @RESULT+1
  STA OVERFLOW
  JMP RETORNO

SOMA:
  LDA A
  AND #80h ; Verifica se primeiro bit e 0
  STA SINAL
  LDA B
  AND #80h
  SUB SINAL
  STA SINAL

  LDA A ; Le A
  ADD B ; Soma B
  STA @RESULT ; Salva o byte baixo no primeiro endereco

  LDA #0
  STA OVERFLOW
  ADC #0
  JZ FIM_SOMA
  LDA #1
  STA OVERFLOW
FIM_SOMA:

  LDA SINAL
  JZ SOMA_IGUAIS
  LDA @RESULT
  AND #80h
  JZ SOMA_POSITIVO
  JMP SOMA_NEGATIVO

SOMA_IGUAIS:
  LDA A
  AND #80h
  JZ SOMA_POSITIVO
  JMP SOMA_NEGATIVO

SOMA_POSITIVO:
  LDA #0
  STA @RESULT+1
  JMP RETORNO

SOMA_NEGATIVO:
  LDA #0FFh
  STA @RESULT+1
  JMP RETORNO

RETORNO:
  LDA OVERFLOW
  LDS SP
  RET
