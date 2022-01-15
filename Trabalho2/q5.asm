;---------------------------------------------------
; Programa:
; Autor:
; Data:
;---------------------------------------------------
END_BASE EQU 02h

ORG 200h ; Elemento 1
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
PTR: DW STR1
PTR_ALTO: DW 0
AUX: DB 8

ORG 500h ; Variaveis da rotina de insercao
SP_INS: DW 0 ; Stack pointer
PTR_ATUAL: DW 0 ; Ponteiro pro elemento atual
PTR_ANT: DW 0 ; Ponteiro pro elemento anterior
PTR_ELE: DW 0 ; Ponteiro para o elemento a ser adicionado

ORG 600h ; Variaveis da rotina de comparacao
SP_COMP: DW 0 ; Stack pointer
PTR1: DW 0 ; Ponteiro para str1
PTR2: DW 0 ; Ponteiro para str2
AUX_COMP: DB 8

ORG 0
INICIO:
  LDA #END_BASE
  PUSH
  LDA #STR1
  PUSH

  LDA #END_BASE
  PUSH
  LDA #STRING
  PUSH

  JSR ROTINA_INSERCAO

IMPRIME:
  LDA #2
  TRAP @PTR

  LDS PTR
  POP
  STS PTR

  LDA AUX
  SUB #1
  STA AUX

  JNZ IMPRIME

  LDA @PTR
  JZ PTR_ZERO

CONTINUA:
  LDS @PTR
  STS PTR

  LDA #8
  STA AUX

  LDA #2
  TRAP PULA_LINHA

  JMP IMPRIME

FIM:
  HLT

PTR_ZERO:
  LDS PTR
  POP
  STS PTR_ALTO
  LDA @PTR_ALTO
  JZ FIM
  JMP CONTINUA

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
  STA PTR_ATUAL
  POP
  STA PTR_ATUAL+1

  LDS PTR_ATUAL
  STS PTR_ANT

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

  LDS PTR_ATUAL
  POP
  POP
  POP
  POP
  POP
  POP
  POP
  POP
  STS PTR_ANT
  LDS @PTR_ANT
  STS PTR_ATUAL

  JMP PROCURA

INSERE:

  HLT

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
  LDS PTR1
  POP
  STS PTR1

  ; Anda 1 com o ponteiro da str2
  LDS PTR2
  POP
  STS PTR2

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

END 0

















