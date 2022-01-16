;---------------------------------------------------
; Programa:
; Autor:
; Data:
;---------------------------------------------------
END_BASE EQU 02h

ORG 200h ; Elemento 1
INICIO_LISTA: DW STR1 ; Inicio da lista encadeada
STR1: STR "AAAAAAAA" ; Valor
DW STR2 ; Ponteiro pro proximo elemento

ORG 220h ; Elemento 2
STR2: STR "BBBBBBBB"
DW STR3

ORG 240h ; Elemento 3
STR3: STR "BCAAABBC"
DW 0

ORG 260h ; Elemento a ser adicionado
STRING: STR "ABCCCCCC"
DW 0 ; Com ponteiro nulo, a ser modificado

ORG 400h ; Variaveis da main
PULA_LINHA: DB 0Ah
PTR: DW 0
PTR_AUX: DW 0
AUX: DB 8
SP_ZERO: DW 0

ORG 500h ; Variaveis da rotina de insercao
SP_INS: DW 0 ; Stack pointer
PTR_ATUAL: DW 0 ; Ponteiro pro elemento atual
PTR_ANT: DW 0 ; Ponteiro pro elemento anterior
PTR_ELE: DW 0 ; Ponteiro para o elemento a ser adicionado
TEMP: DW 0

ORG 600h ; Variaveis da rotina de comparacao
SP_COMP: DW 0 ; Stack pointer
PTR1: DW 0 ; Ponteiro para str1
PTR2: DW 0 ; Ponteiro para str2
AUX_COMP: DB 8

ORG 0
INICIO:
  LDA #END_BASE
  PUSH
  LDA #INICIO_LISTA
  PUSH

  LDA #END_BASE
  PUSH
  LDA #STRING
  PUSH

  JSR ROTINA_INSERCAO

  LDA INICIO_LISTA
  STA PTR

  LDA INICIO_LISTA+1
  STA PTR+1

IMPRIME:
  LDA #2
  TRAP @PTR

  LDA PTR
  ADD #1
  STA PTR
  LDA PTR+1
  ADC #0
  STA PTR+1

  LDA AUX
  SUB #1
  STA AUX

  JNZ IMPRIME

  LDA @PTR
  STA PTR_AUX
  PUSH

  LDA PTR
  ADD #1
  STA TEMP
  LDA PTR+1
  ADC #0
  STA TEMP+1
  LDA @TEMP
  STA PTR_AUX+1
  PUSH

  LDA PTR_AUX
  STA PTR
  LDA PTR_AUX+1
  STA PTR+1

  JSR EH_ZERO
  JZ FIM

CONTINUA:
  LDA #8
  STA AUX

  LDA #2
  TRAP PULA_LINHA

  JMP IMPRIME

FIM:
  HLT


ROTINA_INSERCAO:
  ; Salva o Stack Pointer
  STS SP_INS
  POP
  POP

  POP
  STA PTR_ELE
  POP
  STA PTR_ELE+1

  POP
  STA PTR_ANT
  POP
  STA PTR_ANT+1

  LDA @PTR_ANT
  STA PTR_ATUAL

  LDA PTR_ANT
  ADD #1
  STA TEMP
  LDA PTR_ANT+1
  ADC #0
  STA TEMP+1
  LDA @TEMP
  STA PTR_ATUAL+1

PROCURA:
  LDA #END_BASE
  PUSH
  LDA PTR_ATUAL
  PUSH

  LDA #END_BASE
  PUSH
  LDA PTR_ELE
  PUSH

  JSR ROTINA_COMP
  JP INSERE

  LDA PTR_ATUAL
  ADD #8
  STA PTR_ANT
  LDA PTR_ATUAL+1
  ADC #0
  STA PTR_ANT+1

  LDA @PTR_ANT
  STA PTR_ATUAL
  PUSH

  LDA PTR_ANT
  ADD #1
  STA TEMP
  LDA PTR_ANT+1
  ADC #0
  STA TEMP+1
  LDA @TEMP
  STA PTR_ATUAL+1
  PUSH

  JSR EH_ZERO
  JZ INSERE

  JMP PROCURA

INSERE:
  LDA PTR_ELE
  STA @PTR_ANT

  LDA PTR_ANT
  ADD #1
  STA TEMP
  LDA PTR_ANT+1
  ADC #0
  STA TEMP+1
  LDA PTR_ELE+1
  STA @TEMP

  LDA PTR_ELE
  ADD #8
  STA PTR_ELE
  LDA PTR_ELE+1
  ADC #0
  STA PTR_ELE+1
   
  LDA PTR_ATUAL
  STA @PTR_ELE

  LDA PTR_ELE
  ADD #1
  STA TEMP
  LDA PTR_ELE+1
  ADC #0
  STA TEMP+1
  LDA PTR_ATUAL+1
  STA @TEMP

FIM_ROTINA:
  LDS SP_INS
  RET

ROTINA_COMP:
  ; Salva o Stack Pointer
  STS SP_COMP
  POP
  POP

  ; Remove e salva a segunda string da pilha (Foi adicionada depois, vem primeiro)
  POP
  STA PTR2
  POP
  STA PTR2+1

  ; Remove e salva a primeira string
  POP
  STA PTR1
  POP
  STA PTR1+1

  LDA #8
  STA AUX_COMP

COMPARACAO:
  LDA AUX_COMP
  JZ IGUAL
  SUB #1
  STA AUX_COMP

  ; Diminui o ascii de cada letra
  LDA @PTR1
  SUB @PTR2
  JN STR2_MAIOR ; Se negativo, str2 > str1
  JP STR1_MAIOR ; Se positivo, str1 < str2

  ; Se deu 0, eh mesma letra, continua para a proxima

  ; Anda 1 com o ponteiro da str1
  LDA PTR1
  ADD #1
  STA PTR1
  LDA PTR1+1
  ADC #0
  STA PTR1+1

  ; Anda 1 com o ponteiro da str2
  LDA PTR2
  ADD #1
  STA PTR2
  LDA PTR2
  ADC #0
  STA PTR2

  ; Repete
  JMP COMPARACAO

; Se str1 eh maior
STR1_MAIOR:
  LDA #1 ; Acumulador fica com 1
  JMP RETORNO

; Se str2 eh maior
STR2_MAIOR:
  LDA #0FFh ; Acumulador fica com -1
  JMP RETORNO

; Se str1 = str2
IGUAL:
  LDA #0 ; Acumulador fica com 0

RETORNO:
  ; Volta com o Stack Pointer e retorna pra chamada
  LDS SP_COMP
  RET

EH_ZERO:
  STS SP_ZERO
  POP
  POP

  POP
  JNZ RET_UM
  POP
  JNZ RET_UM

  LDA #0
  JMP RET_GERAL

RET_UM:
  LDA #1

RET_GERAL:
  LDS SP_ZERO
  RET

END 0

















