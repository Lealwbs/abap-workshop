*&---------------------------------------------------------------------*
*& Report Z08_EXERC1_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT z08_exerc1_1.

START-OF-SELECTION.

  DATA: v_soma      TYPE i,
        v_diferenca TYPE i,
        v_produto   TYPE i,
        v_quociente TYPE i.

  PARAMETERS: v_num1 TYPE i OBLIGATORY,
              v_num2 TYPE i OBLIGATORY.

END-OF-SELECTION.

  WRITE: /'Número 1:', v_num1,
         /'Número 2:', v_num2.

  v_soma = v_num1 + v_num2.
  v_diferenca = v_num1 - v_num2.
  v_produto = v_num1 * v_num2.

  WRITE: /'Soma:', v_soma,
         /'Diferença:', v_diferenca ,
         /'Produto:', v_produto.

  TRY.
      v_quociente = v_num1 / v_num2.
      WRITE: /'Divisão:', v_quociente.
    CATCH cx_sy_zerodivide.
      WRITE: /'Divisão:', 'INEXISTENTE'.
  ENDTRY.