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
    NUM1: DS 4 ; Variável de 32 bits
    RESULT: DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; Vetor de dígitos em decimal

    ; Dado o endereço da variável de 32 bits END_NUM0 apontará para os primeiro 8 bits, END_NUM1 para os próximos 8 bits e assim por diante
    END_NUM0: DW 0
    END_NUM1: DW 0
    END_NUM2: DW 0
    END_NUM3: DW 0

    PTR: DW RESULT ; Ponteiro para vetor de dígitos
    END_RESULT: DW RESULT ; Ponteiro para vetor de dígitos


    SP: DW 0 ; Stack Pointer
    ; Iteradores
    I: DB 0
    J: DB 0

ORG 0

INIT:

  LDA #0 ; Carrega os 8 bits menos significativos do número de 32 bits no acumulador
  STA NUM1 ; Salva os primeiros 8 bits na variável

  LDA #0  ;  Carrega os próximos 8 bits
  STA NUM1+1

  LDA #0 ;  Carrega os próximos 8 bits
  STA NUM1+2

  LDA #0 ;  Carrega os 8 bits mais significtivos do número de 32 bits no acumulador
  STA NUM1+3 ; Salva os últimos 8 bits na variável

  LDA #END_BASE ; Carrega os 8 bits mais significativos do endereço da variável de 32 bits
  PUSH ; Coloca na pilha

  LDA #NUM1 ; Carrega os 8 bits menos significativos do endereço da variável de 32 bits
  PUSH ; Coloca na pilha

  JSR ROTINA
  HLT

ROTINA:
  ; Salva o stack pointer
  STS SP
  POP
  POP

  ; Salva começo do endereço
  POP
  STA END_NUM0

  ; Salva final do endereço
  POP
  STA END_NUM0+1

  ; Como recebemos o endereço dos 8 bits menos significativos precisamos de outros ponteiros para apontar para os outros bits

  LDA END_NUM0 ; Carrego o endereço dos 8 bits menos significativos
  ADD #1 ; Adiciono 1 indo para o próximo endereço
  STA END_NUM1 ; Salvo no próximo ponteiro

  ; Adiciono a segunda parte do endereço com carry em END_NUM1+1
  LDA END_NUM0+1
  ADC #0
  STA END_NUM1+1

  ; Repito o processo para cada parte da variável de 32 bits
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

  ; No final desse processo teremos cada ponteiro apontando para cada parte da variável de 32 bits
  ;END_NUM3    END_NUM2     END_NUM1      END_NUM0
  ;0000 0000   0000 0000    0000 0000     0000 0000


LOOP:
  LDA I
  SUB #32
  JZ PRINT ; se i = 32 printa o vetor
  ; Senão continua o algoritmo

FOR_ADDITION: ;Loop para verificar se precisa adicionar 3
  ; acc = j - 10
  LDA J
  SUB #10
  JZ SHIFT ; Se já passou pelos 10 dígitos então vai para a parte do shift

  ;J++
  LDA J
  ADD #1
  STA J

  ;ACC = RESULT[J] - 5
  LDA @PTR
  SUB #5
  JN PROX ; Se RESULT[J] <= 5 então não vai dar negativo e pode ir para a próxima iteração

ADDITION: ;Adição de 3 na coluna que precisar
  ;RESULT[J] += 3
  LDA @PTR
  ADD #3
  STA @PTR


PROX: ; Faz PTR apontar pro proximo elemento do vetor
  ;PTR++
  LDA PTR
  ADD #1
  STA PTR
  JMP FOR_ADDITION ; Volta pro loop de adição

SHIFT: ; Começo da parte de shift
  ;J++
  LDA #0
  STA J

  ;PTR = RESULT[0]
  LDA END_RESULT
  STA PTR ; Volta PTR para o início do vetor

  LDA END_RESULT+1
  ADC #0
  STA PTR+1

LOOP_SHIFT: ;Loop sobre os 9 primeiros elementos dando shift neles
  ; ACC = J - 9
  LDA J
  SUB #9
  JZ LAST ; Se já passou pelos 9 primeiros vai para o último

  ;J++
  LDA J
  ADD #1
  STA J

  ;Parte do shift
  ;RESULT[J] <<= 1
  LDA @PTR
  SHL
  STA @PTR

  ;Agora nos vamos para o próximo elemento e vemos se quando dermos shift nele virá um bit 1 ou um bit 0 para o elemento atual

  ;PTR vai apontar para o próximo elemento
  ;PTR++
  LDA PTR
  ADD #1
  STA PTR

  ; Verifica se irá um bit 1 para a coluna anterior
  LDA @PTR
  AND #8   ;1000
  JZ LOOP_SHIFT ; Se for 0 não precisamos fazer nada e vamos para o loop

  ; Se for 1 então precisamos voltar para o elemento anterior e somar 1

  ; Tiramos esse bit 1 mais significativo do elemento já que ele irá pra a coluna anterior
  ;RESULT[J+1] -= 8
  LDA @PTR
  SUB #8
  STA @PTR

  ;Voltamos para o elemento anterior
  ;PTR--
  LDA PTR
  SUB #1
  STA PTR

  ; Faz o elemento atual ganhar um bit 1
  ;RESULT[J]++
  LDA @PTR
  ADD #1
  STA @PTR

  ;Vamos para a próxima coluna
  ;PTR++
  LDA PTR
  ADD #1
  STA PTR

  JMP LOOP_SHIFT ; Volto pro loop


LAST: ; A última coluna vai receber o bit mais significativo do número de 32 bits

  ; shift no último digito
  ;RESULT[9] <<= 1
  LDA @PTR
  SHL
  STA @PTR

  ; Verifico se irá um bit 1 ou bit 0 para o último dígito
  LDA @END_NUM3
  AND #128 ;1000 0000
  JZ ZERO ; Se for 0 não faz nada com o último digito

  ; Se for 1 adiciona esse bit ao último dígito
  ;RESULT[9]++
  LDA @PTR
  ADD #1
  STA @PTR

ZERO: ; A partir daqui é shift nos numeros abaixo
  ;END_NUM3   END_NUM2    END_NUM1    END_NUM0
  ;0000 0000  0000 0000   0000 0000   0000 0000

  ; shift em  @END_NUM3
  LDA @END_NUM3
  SHL
  STA @END_NUM3

  ; Verifica se irá um bit 0 out bit 1 de @END_NUM2 para @END_NUM3
  LDA @END_NUM2
  AND #128 ; 1000 0000
  JZ SHIFT_NUM2 ; se for 0 não faz nada com @END_NUM3

  ; Se for um bit 1 coloca esse bit em @END_NUM3
  ; @END_NUM3++
  LDA @END_NUM3
  ADD #1
  STA @END_NUM3

SHIFT_NUM2:
  ; shift em  @END_NUM2
  LDA @END_NUM2
  SHL
  STA @END_NUM2

  ; Verifica se irá um bit 0 out bit 1 de @END_NUM1 para @END_NUM2
  LDA @END_NUM1
  AND #128 ; 1000 0000
  JZ SHIFT_NUM1_ALTO ; se for 0 não faz nada com @END_NUM2

  ; Se for um bit 1 coloca esse bit em @END_NUM2
  ; @END_NUM2++
  LDA @END_NUM2
  ADD #1
  STA @END_NUM2

SHIFT_NUM1_ALTO:
  ; shift em  @END_NUM1
  LDA @END_NUM1
  SHL
  STA @END_NUM1

  ; Verifica se irá um bit 0 out bit 1 de @END_NUM0 para @END_NUM1
  LDA @END_NUM0
  AND #128 ; 1000 0000
  JZ INCR ; se for 0 não faz nada com @END_NUM1

  ; Se for um bit 1 coloca esse bit em @END_NUM1
  ; @END_NUM1++
  LDA @END_NUM1
  ADD #1
  STA @END_NUM1

INCR: ; Apenas arruma algumas variáveis
  ; Shift em @END_NUM0
  LDA @END_NUM0
  SHL
  STA @END_NUM0

  ; I++
  LDA I
  ADD #1
  STA I

  ; J = 0
  LDA #0
  STA J

  ;PTR = RESULT[0]
  LDA END_RESULT
  STA PTR ; Volta PTR para o início do vetor

  LDA END_RESULT+1
  ADC #0
  STA PTR+1


  JMP LOOP ; Volta pro loop inicial

PRINT: ; A partir daqui é print no banner
  OUT CLEARBANNER ; Limpa o banner
LOOP_PRINT:
  ; Verifica se já printou os 10 digitos
  LDA J
  SUB #10
  JZ RETORNO ; Se já, então vai pro final da rotina

  ; J++
  LDA J
  ADD #1
  STA J

  ; Transforma o dígito em ASCII
  LDA @PTR
  ADD #30H
  OUT BANNER ; Printa no banner

  ; Aponta para próximo dígito
  LDA PTR
  ADD #1
  STA PTR

  ; Volta pro loop de printar
  JMP LOOP_PRINT

RETORNO:
 ; Volta com o Stack Pointer e retorna pra chamada
  LDS SP
  RET
