;---------------------------------------------------
; Programa:
; Autor:
; Data:
;---------------------------------------------------
END_ALTO EQU 02h
END_BAIXO EQU 0
END_BASE EQU 04h

ORG 200h
STR1: STR "AAAAAAAA"
DW STR2
ORG 250h
STR2: STR "BBBBBBBB"
DW STR3
STR3: STR "BCAAABBC"
DW 0

ORG 400h
STRING: STR "ABCCCCCC"
PULA_LINHA: DB 0Ah
PTR: DW STR1
AUX: DB 8

ORG 0
INICIO:
  LDA #END_BASE
  PUSH
  LDA #STRING
  PUSH

  ;JSR INSERE

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
  JZ FIM

  LDS @PTR
  STS PTR

  LDA #8
  STA AUX

  LDA #2
  TRAP PULA_LINHA

  JMP IMPRIME

FIM:
  HLT

END 0

















