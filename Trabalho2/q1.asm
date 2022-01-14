;---------------------------------------------------
; Programa:
; Autor:
; Data:
;---------------------------------------------------

ORG 200h
  OP: DS 1 ; Operacao a ser realizada
  SP: DW 0 ; Stack Pointer da pilha
  END_A: DW 0 ; Primeiro operando
  END_B: DW 0 ; Segundo operando
  A: DS 1
  B: DS 1
  RESULT: DW 0 ; Endereco do resultado
  SINAL: DS 1 ; Variavel para salvar os sinais
  OVERFLOW: DS 1 ; Variavel para salvar se houve overflow ou nao

ORG 0
CALC:
  STA OP ; Salva o operador do acumulador

  STS SP ; Salva o Stack Pointer
  POP ; E remove da pilha
  POP ; Sendo 16 bit

  POP ; Le o endereco do resultado
  STA RESULT
  POP
  STA RESULT+1

  POP ; Le o primeiro operando da pilha
  STA END_A
  POP
  STA END_A+1

  POP ; Le o segundo operando da pilha
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
  NOT A
  ADD #1
  STA A

CONFERE_B:
  LDA B
  AND #80h
  SUB SINAL
  STA SINAL
  JZ LOOP_MULT
  NOT B
  ADD #1
  STA B

LOOP_MULT:
  LDA B
  JZ FIM_MULT
  SUB #1
  STA B

  LDA A
  ADD C
  STA C

  LDA C+1
  ADC #0
  STA C+1

  AND #80h
  JZ LOOP_MULT

  LDA #1
  STA OVERFLOW
  JMP LOOP_MULT

FIM_MULT:
  LDA SINAL
  JZ RETORNO

  NOT C
  ADD #1
  STA C

  NOT C+1
  ADC #0
  STA C+1

  JMP RETORNO

EH_ZERO:
  LDA #0 ; Nao houve overflow, acumulador eh 0
  STA @RESULT ; Salva 0 nos 2 bytes do resultado
  STA @RESULT+1
  STA OVERFLOW
  JMP RETORNO

SOMA:
  LDA A
  AND #80h
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
  LDA #FF
  STA @RESULT+1
  JMP RETORNO

RETORNO:
  LDA OVERFLOW
  LDS SP
  RET
