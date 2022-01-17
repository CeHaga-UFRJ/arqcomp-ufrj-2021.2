;---------------------------------------------------
; Programa: Escrever uma rotina para somar ou para multiplicar
; dois números de 8 bits em complemento a dois, cujos endereços
; são passados como parâmetros na pilha.
; Autor: Carlos Bravo, Markson Arguello, Pedro Ancelmo
; Data: 14/01/2022
;---------------------------------------------------
SUM EQU 0
VEZES EQU 1
END_BASE EQU 04h ; Parte alta do endereço das variáveis

ORG 400h
  OP: DS 1 ; Operacao a ser realizada
  ; 0 = Soma
  ; 1 = Multiplicação
  SP: DW 0 ; Stack Pointer da pilha
  END_A: DW 0 ; Ponteiro para primeiro operando
  END_B: DW 0 ; Ponteiro para segundo operando
  A: DS 1 ; Variável temporaria
  B: DS 1 ; Variável temporaria
  RESULT: DW 0 ; Endereco do resultado
  RESULT_ALTO: DW 0 ; Endereco da parte alta do resultado
  SINAL: DS 1 ; Variavel para salvar os sinais
  OVERFLOW: DS 1 ; Variavel para salvar se houve overflow ou nao
  NUM1: DB 127 ;
  NUM2: DB 127 ;

ORG 430h
  NUM3: DW 0 ; Resultado

ORG 0
INICIO:
  ; Salva endereço do primeiro operando na pilha
  LDA #END_BASE ; Parte alta
  PUSH

  LDA #NUM1 ; Parte baixa
  PUSH

  ; Salva endereço do segundo operando na pilha
  LDA #END_BASE ; Parte alta
  PUSH

  LDA #NUM2 ; Parte baixa
  PUSH

  ; Salva endereço do resultado na pilha
  LDA #END_BASE ; Parte alta
  PUSH

  LDA #NUM3 ; Parte baixa
  PUSH

  ; Coloca o número da operação no acumulador
  ; 0 = Soma
  ; 1 = Multiplicação
  LDA #0

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

  ; Guarda o conteudo do primeiro operando na variável temporária A
  LDA @END_A
  STA A

  ; Guarda o conteudo do segundo operando na variável temporária B
  LDA @END_B
  STA B

  ; Faz RESULT_ALTO ser RESULT+1
  ; RESULT_ALTO será os 8 bits mais significativos
  ; RESULT será os 8 bits menos significativos
  LDA RESULT
  ADD #1
  STA RESULT_ALTO

  LDA RESULT+1
  ADC #0
  STA RESULT_ALTO+1

  LDA OP  ; Carrega a operação no acumulador
  JZ SOMA ; Se for 0 faz uma soma

  ; Se chegou aqui é multiplicação
  LDA B ; Se A ou B for 0, e é multiplicacao, resultado é 0
  JZ EH_ZERO
  LDA A
  JZ EH_ZERO

MULT:
CONFERE_A: ; Confere sinal de A e verifica se é negativo
  LDA A
  AND #80h ; Se o último bit é 1 então o número é negativo
  STA SINAL ;Guardamos o sinal de A
  JZ CONFERE_B ; Se A é positivo (SINAL == 0) então não precisa fazer nada e pode conferir sinal de B

  ; Se chegou até aqui então A é negativo
  ; Transformamos A em positivo
  LDA A
  NOT
  ADD #1
  STA A ;Guardamos o A positivo

CONFERE_B:; Confere sinal de B e verifica se é negativo
  LDA B
  AND #80h ; Se o último bit é 1 então o número é negativo
  ; Subtraimos o sinal de B com o sinal de A
  SUB SINAL
  ; Se os sinais são iguais então SINAL será 0, caso contrário SINAL será 1
  STA SINAL

  ;Verificamos o sinal de B novamente
  LDA B
  AND #80h

  JZ LOOP_MULT ; Se B for positivo não precisamos fazer nada

  ; Se chegou aqui então B é negativo
  ; Transformamos B para positivo
  LDA B
  NOT
  ADD #1
  STA B

LOOP_MULT: ; Loop da multiplicação
  LDA B
  JZ FIM_MULT ; Se já adicionamos A ao resultado B vezes então vai para o final da multiplicação
  ; Se não
  ; Subtraimos 1 de B
  SUB #1
  STA B

  ; Adicionamos A ao resultado
  LDA A
  ADD @RESULT
  STA @RESULT

  ; Adicionamos o carry aos 8 bits mais significativos
  LDA @RESULT_ALTO
  ADC #0
  STA @RESULT_ALTO

  ; Verificamos se o bit mais significativo do número de 16 bits é 1
  AND #80h
  JZ LOOP_MULT ; Se for 0 então o resultado ainda é positivo e continuamos a multiplicar

  ; Se for 1 então houve overflow já que A e B são positivos e esse 1 significaria que resultado é negativo
  ; E a multiplicação de dois números positivos não pode ser negativo
  LDA #1
  STA OVERFLOW ; Guardamos 1 na variável OVERFLOW para indicar que houver overflow
  JMP LOOP_MULT ; Continuamos a multiplicar

FIM_MULT: ; Fim da multiplicação
  LDA SINAL ; Se o sinal é 0 então estamos multiplicando 2 números com sinais iguais e não precisamos fazer nada
  JZ RETORNO

  ; Se o sinal for 1 então precisamos trocar o sinal do resultado já que estamos multiplicando 1 positivo e 1 negativo

  ; Transformo a parte baixa do resultado para negativo
  LDA @RESULT
  NOT
  ADD #1
  STA @RESULT

  ; Transformo a parte alta do resultado para negativo
  LDA @RESULT_ALTO
  NOT
  ADC #0
  STA @RESULT_ALTO

  JMP RETORNO ; Vai para o final da rotina

EH_ZERO:
  LDA #0 ; Nao houve overflow, acumulador eh 0
  STA @RESULT ; Salva 0 nos 2 bytes do resultado
  STA @RESULT_ALTO
  STA OVERFLOW ; Salva 0 na variável OVERFLOW
  JMP RETORNO ; Vai para o final da rotina

SOMA:
  LDA A
  AND #80h ; Verifica se primeiro bit e 0
  STA SINAL ; Guarda sinal de A
  LDA B
  AND #80h
  SUB SINAL ;Subtrai sinal de A pelo sinal de B
  STA SINAL ; Guarda sinal, se os sinais forem iguais SINAL sera 0, caso contrário será 1

  LDA A ; Le A
  ADD B ; Soma B
  STA @RESULT ; Salva o byte baixo no primeiro endereco

  ;Guardamos 0 no OVERFLOW
  LDA #0
  STA OVERFLOW

  ADC #0 ; Verifica se houve carry
  JZ FIM_SOMA ; Se não houve carry vai para o fim da soma

  ; Caso contrário guarda 1 em OVERFLOW
  LDA #1
  STA OVERFLOW

FIM_SOMA:

  LDA SINAL ;Verifica SINAL
  JZ SOMA_IGUAIS ; Se for 0 os sinais dos operandos são iguais

  ; Se chegou aqui os sinais são diferentes
  LDA @RESULT
  AND #80h ; Verifica sinal do resultado
  JZ SOMA_POSITIVO ; Se sinal do resultado for 0 então o resultado é positivo

  JMP SOMA_NEGATIVO ; Caso contrário é negativo

SOMA_IGUAIS: ; Se resultado for positivo
  LDA A
  AND #80h ; Verifica sinal de A
  JZ SOMA_POSITIVO ; Se for positivo vai para SOMA_POSITIVO
  JMP SOMA_NEGATIVO ; Senão vai para SOMA_NEGATIVO

SOMA_POSITIVO: ; Se for resultado for positivo os 8 mais mais significativos serão todos 0
  LDA #0
  STA @RESULT_ALTO ; Coloca 0 nos 8 bits mais significativos
  JMP RETORNO

SOMA_NEGATIVO: ; Se for resultado for negativo os 8 mais mais significativos serão todos 1
  LDA #0FFh ; Carrega 11111111b
  STA @RESULT_ALTO ; Coloca 1 nos 8 bits mais significativos
  JMP RETORNO

RETORNO:
  LDA OVERFLOW ; Carrega o overflow no acumulador]
  ; Termina a rotina
  LDS SP
  RET
