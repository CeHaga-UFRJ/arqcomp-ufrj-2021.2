;---------------------------------------------------
; Programa: Rotina para comparacao de strings
; Autor: Carlos Bravo, Markson Arguello e Pedro Ancelmo
; Data: 10/01/2021
;---------------------------------------------------
ORG 200h
SP: DW 0 ; Stack pointer
PTR1: DW 0 ; Ponteiro para str1
PTR2: DW 0 ; Ponteiro para str2
STR1: STR "abcd" ; Primeira string
      DB 0
STR2: STR "abd" ; Segunda string
      DB 0
END_BASE EQU 02h ; Parte alta do endereco das strings

ORG 0
INICIO:
; Salva a primeira string na pilha
LDA #END_BASE ; Parte alta, 02h
PUSH
LDA #STR1 ; Parte baixa, seu endereco
PUSH

; Salva a segunda string na pilha
LDA #END_BASE ; Parte alta, 02h
PUSH
LDA #STR2 ; Parte baixa, seu endereco
PUSH

; Chama a rotina, mostra no visor o resultado e acaba o codigo
JSR ROTINA
OUT 0
HLT

; Compara duas strings e retorna a comparacao alfabetica
; Entrada pela pilha: (Ordem de insercao)
;  -> Primeira string
;  -> Segunda string
; Saida no acumulador:
;  -> 1, se str1 > str2
;  -> 0, se str1 = str2
;  -> -1, se str1 < str2
ROTINA:
  ; Salva o stack pointer
  STS SP
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

COMPARACAO:
  ; Se str1 chegou ao fim
  LDA @PTR1
  OR #0
  JZ STR1_NULL ; Precisa ver outras condicoes

  ; Se str1 nao chegou ao fim e str2 chegou ao fim
  LDA @PTR2
  OR #0
  JZ STR1_MAIOR ; str1 > str2

  ; Se nenhuma das duas acabou diminui o ascii de cada letra
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

; Se str1 chegou ao fim
STR1_NULL:
  LDA @PTR2
  OR #0
  JZ IGUAL ; Se str2 tambem, sao iguais
  JMP STR2_MAIOR ; Senao, str2 > str1

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
  LDS SP
  RET

END 0
