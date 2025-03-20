*&---------------------------------------------------------------------*
*& Report zis_teste_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_teste_01.

DATA: v_TEXT TYPE string VALUE 'Olá, Mundo'.

START-OF-SELECTION.
*
*  WRITE: / v_text.
*    DATA(obj1) = NEW zcl_isantos_teste_02( ).
*    DATA: resultado type i.
*    resultado = obj1->somar( num1 = 2 num2 = 2 ).
*    WRITE: resultado.


  DATA(obj1) = NEW zcl_isantos_exerc01( ).

  obj1->show_table( ).

  obj1->fillup_table( userid = 1   firstname = 'pedro'  lastname = 'pereira').
  obj1->fillup_table( userid = 023 firstname = 'maria'  lastname = 'mendes' ).
  obj1->fillup_table( userid = 999 firstname = 'carlos' lastname = 'cabrito').

  obj1->show_table( ).

END-OF-SELECTION.