*&---------------------------------------------------------------------*
*& Report Z08_EXERC1_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc1_2.

DATA: v_counter_l1      TYPE i,
      v_counter_l2      TYPE i,
      v_sum_list        TYPE i,
      v_list_sum_itens  TYPE i,
      v_list_qtde_itens TYPE i,
      v_media           TYPE i,
      v_multiplicacao   TYPE i.

PARAMETERS: v_num1 TYPE i OBLIGATORY,
v_num2 TYPE i OBLIGATORY.

START-OF-SELECTION.

END-OF-SELECTION.

  IF v_num1 <= 0 OR v_num2 <= 0.
    WRITE:/ 'ERRO: Número Inválido, digite somente números maiores que zero'.
    STOP.
  ENDIF.

  IF v_num1 >= v_num2.
    WRITE:/ 'ERRO: Primeiro número deve ser menor que o segundo'.
    STOP.
  ENDIF.

  IF v_num2 - v_num1 < 5.
    WRITE:/ 'ERRO: A diferença entre o segundo número e o primeiro número deve ser maior ou igual à 5'.
    STOP.
  ENDIF.

  v_sum_list = 0.

* L1
  v_counter_l1 = v_num1.
  WHILE v_counter_l1 <= v_num2.
    WRITE: v_counter_l1.
    v_counter_l1 += 1.
  ENDWHILE.

  SKIP. ULINE.

* L2
  v_counter_l2 = v_num2.
  WHILE v_counter_l2 >= v_num1.
    WRITE: v_counter_l2.
    v_counter_l2 -= 1.
  ENDWHILE.

  SKIP. ULINE.

  v_list_qtde_itens = v_num2 - v_num1 + 1.
  v_media = ( v_num1 + v_num2 ) / 2.

* Progressão Aritimética
  v_sum_list = v_media * v_list_qtde_itens.

* 3º da lista 1 e 5º da lista 2
* Ou seja, v_num1+2 e v_num2-4.

  v_multiplicacao = ( v_num1 + 2 ) * ( v_num2 - 4 ).

  WRITE: / 'Soma:', v_sum_list.
  WRITE: / 'Média:', v_media.
  WRITE: / 'Multip:', v_multiplicacao.

  SKIP. ULINE.

* Desafio Lista Crescente de Pares
  v_counter_l1 = v_num1.
  WHILE v_counter_l1 <= v_num2.
    IF v_counter_l1 MOD 2 = 0.
      WRITE: v_counter_l1.
    ENDIF.
    v_counter_l1 += 1.
  ENDWHILE.