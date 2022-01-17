;---------------------------------------------------
; Programa: Considere uma estrutura de dados organizada da seguinte maneira: cada elemento contém uma chave que é uma cadeia de caracteres com tamanho fixo igual a 8 caracteres, sem nulo, seguida de um apontador para o próximo elemento da estrutura.
; Autor: Carlos Bravo, Markson Arguello e Pedro Ancelmo
; Data: 14/01/2022
;---------------------------------------------------
END_BASE EQU 02h
TAM_STRING EQU 8

ORG 200h ; Elemento 1
INICIO_LISTA: DW STR1 ; Inicio da lista encadeada
STR1: STR "ABAAAAAA" ; Valor
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
PULA_LINHA: DB 0Ah ; Caracter '\n'
PTR: DW 0 ; Ponteiro para percorrer a lista
PTR_AUX: DW 0 ; Ponteiro auxiliar adentrar a lista
AUX: DB TAM_STRING ; Contador de tamanho da string
SP_ZERO: DW 0 ; Stack Pointer para rotina de comparacao de 0

ORG 500h ; Variaveis da rotina de insercao
END_RET_INS: DW 0 ; Endereco de retorno
PTR_ATUAL: DW 0 ; Ponteiro pro elemento atual
PTR_ANT: DW 0 ; Ponteiro pro elemento anterior
PTR_ELE: DW 0 ; Ponteiro para o elemento a ser adicionado
TEMP: DW 0 ; Ponteiro temporario para acessar byte alto

ORG 600h ; Variaveis da rotina de comparacao
SP_COMP: DW 0 ; Stack pointer
PTR1: DW 0 ; Ponteiro para str1
PTR2: DW 0 ; Ponteiro para str2
AUX_COMP: DB TAM_STRING ; Contador de tamanho da string de comparacao

ORG 0
INICIO:
  ; Passa o endereco de inicio da lista
  LDA #END_BASE
  PUSH
  LDA #INICIO_LISTA
  PUSH

  ; Passa o endereco do elemento a ser adicionado
  LDA #END_BASE
  PUSH
  LDA #STRING
  PUSH

  ; Chama rotina para inserir elemento
  JSR ROTINA_INSERCAO

  ; Como inicio_lista eh estatico, salva o valor em ptr para modificar
  LDA INICIO_LISTA
  STA PTR

  LDA INICIO_LISTA+1
  STA PTR+1

IMPRIME:
  ; Imprime o caracter de ptr
  LDA #2
  TRAP @PTR

  ; Move o ponteiro em 1
  LDA PTR
  ADD #1
  STA PTR
  LDA PTR+1
  ADC #0
  STA PTR+1

  ; aux--
  LDA AUX
  SUB #1
  STA AUX

  ; Enquanto aux>0, continua imprimindo
  JNZ IMPRIME

  ; ptr = @ptr
  ; ptr_aux recebe a parte baixa de @ptr
  LDA @PTR
  STA PTR_AUX
  PUSH ; Salva na pilha para conferir se eh 0

  ; temp recebe o valor de ptr+1
  LDA PTR
  ADD #1
  STA TEMP
  LDA PTR+1
  ADC #0
  STA TEMP+1

  ; Para assim poder salvar a parte alta de @ptr em ptr_aux
  LDA @TEMP
  STA PTR_AUX+1
  PUSH ; Salva na pilha para conferir se eh 0

  ; ptr = ptr_aux = @ptr
  LDA PTR_AUX
  STA PTR
  LDA PTR_AUX+1
  STA PTR+1

  ; Confere se ptr = 0
  JSR EH_ZERO
  ; Se sim, chegou ao fim da lista
  JZ FIM

CONTINUA:
  ; aux = tam_string
  LDA #TAM_STRING
  STA AUX

  ; Imprime o caracter '\n' no console
  LDA #2
  TRAP PULA_LINHA

  ; Volta a rotina de impressao
  JMP IMPRIME

FIM:
  HLT

; Insere um elemento string(TAM_STRING)+ponteiro em uma lista com o mesmo formato, mantendo a ordem alfabetica
; Ordem de insercao na pilha:
;  -> Endereco do inicio da lista
;  -> Endereco do elemento a ser adicionado
; Nao ha retorno, a lista sera modificada
ROTINA_INSERCAO:
  ; Salva o endereco de retorno
  ; Nao eh possivel usar o Stack Pointer pois a pilha sera sobreescrita
  POP
  STA END_RET_INS
  POP
  STA END_RET_INS+1

  ; Salva o endereco do elemento
  POP
  STA PTR_ELE
  POP
  STA PTR_ELE+1

  ; Salva o endereco do inicio da pilha
  POP
  STA PTR_ANT
  POP
  STA PTR_ANT+1

  ; ptr_atual = @ptr_ant
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

; Procura a posicao a ser inserido
PROCURA:
  ; Passa o endereco da string atual
  LDA #END_BASE
  PUSH
  LDA PTR_ATUAL
  PUSH

  ; Passa o endereco da string a ser adicionada
  LDA #END_BASE
  PUSH
  LDA PTR_ELE
  PUSH

  ; Compara as duas
  JSR ROTINA_COMP
  ; Se atual > elemento, entao chegamos no endereco seguinte a ser adicionado
  JP INSERE
  ; Se atual < elemento, continua percorrendo

  ; ptr_ant = ptr_atual+8
  LDA PTR_ATUAL
  ADD #TAM_STRING
  STA PTR_ANT
  LDA PTR_ATUAL+1
  ADC #0
  STA PTR_ANT+1

  ; ptr_atual = @ptr_ant
  LDA @PTR_ANT
  STA PTR_ATUAL
  PUSH ; Salva na pilha para conferir se eh 0

  LDA PTR_ANT
  ADD #1
  STA TEMP
  LDA PTR_ANT+1
  ADC #0
  STA TEMP+1
  LDA @TEMP
  STA PTR_ATUAL+1
  PUSH ; Salva na pilha para conferir se eh 0

  ; Se ptr = 0, chegou ao fim da lista
  JSR EH_ZERO
  JZ INSERE

  ; Senao continua procurando
  JMP PROCURA

INSERE:
  ; ptr_ant = ponteiro para o ponteiro do elemento anterior
  ; ptr_ele = ponteiro para o inicio do elemento a ser adicionado
  ; ptr_atual = ponteiro para o inicio do elemento que deve vir depois
  ; Para inserir, precisamos que elemento esteja entre ant e atual, para isso eh necessario
  ; @ptr_ele+tam_string = ptr_atual
  ; @ptr_ant = ptr_ele

  ; @ptr_ant = ptr_ele
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

  ; @ptr_ele+tam_string = ptr_atual
  LDA PTR_ELE
  ADD #TAM_STRING
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
  ; Volta com o endereco de retorno para poder retornar a funcao principal
  LDA END_RET_INS+1
  PUSH
  LDA END_RET_INS
  PUSH
  RET

; Compara duas strings de tamanho TAM_STRING e retorna a comparacao alfabetica
; Entrada pela pilha: (Ordem de insercao)
;  -> Primeira string
;  -> Segunda string
; Saida no acumulador:
;  -> 1, se str1 > str2
;  -> 0, se str1 = str2
;  -> -1, se str1 < str2
ROTINA_COMP:
  ; Salva o Stack Pointer de comparacao
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

  ; Salva o auxiliar com valor do tamanho da string
  LDA #TAM_STRING
  STA AUX_COMP

COMPARACAO:
  ; while(aux_comp-- > 0)
  LDA AUX_COMP
  JZ IGUAL
  SUB #1
  STA AUX_COMP

  ; Subtrai o ascii de cada letra
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

; Compara se dois numeros sao 0
; Pode ser usado para comparar se uma variavel 16-bit eh 0
EH_ZERO:
  ; Salva o Stack Pointer
  STS SP_ZERO
  POP
  POP

  ; Se algum nao for 0, retorna 1
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

















