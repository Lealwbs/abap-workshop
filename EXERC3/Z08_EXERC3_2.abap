*&---------------------------------------------------------------------*
*& Report Z08_EXERC3_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc3_2.

*&---------------------------------------------------------------------*
*& Registros com o valor de SEATSOCC > a 60% do valor de SEATSMAX;
*&---------------------------------------------------------------------*
*& MANDT   CARRID  CONNID  FLDATE      PRICE   SEATSMAX  SEATSOCC %    *
*& 400     AA      0064    17.08.2024  422,94  330       318      0.96 *
*& 400     AA      0064    18.09.2024  422,94  330       321      0.97 *
*& 400     AA      0064    20.10.2024  422,94  330       319      0.96 *
*&---------------------------------------------------------------------*
*& Registros com o valor de SEATSOCC <= a 60% do valor de SEATSMAX;
*&---------------------------------------------------------------------*
*& MANDT   CARRID  CONNID  FLDATE      PRICE   SEATSMAX  SEATSOCC %    *
*& 400     AA      0064    03.07.2025  422,94  330       101      0.30 *
*& 400     AA      0064    04.08.2025  422,94  330       79       0.24 *
*& 400     AA      0064    05.09.2025  422,94  330       12       0.03 *
*&---------------------------------------------------------------------*
*& Os 3 valores do segundo quadro aumentaram o preço em 15%
*&---------------------------------------------------------------------*

DATA: tp_sflight_carrid TYPE sflight-carrid,
      tp_sflight_fldate TYPE sflight-fldate,
      v_data_tmp1       TYPE sy-datum,
      v_data_tmp2       TYPE sy-datum.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: v_cid  FOR tp_sflight_carrid OBLIGATORY,
                  v_fldt FOR tp_sflight_fldate OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b_input.

INITIALIZATION.
  v_data_tmp1 = sy-datum.
  v_data_tmp1+6(2) = '01'.
  v_data_tmp2 = v_data_tmp1.
  v_data_tmp2+4(2) = v_data_tmp2+4(2) + 1.
  v_data_tmp2 = v_data_tmp2 - 1.

  v_fldt-sign   = 'I'.  " Inclusão
  v_fldt-option = 'BT'. " Between
  v_fldt-low    = v_data_tmp1.  " Data inicio do mês
  v_fldt-high   = v_data_tmp2.  " Data final do mês
  APPEND v_fldt TO v_fldt[].

START-OF-SELECTION.

  DATA: it_copy_sflight  TYPE TABLE OF sflight,
        it_valid_sflight TYPE TABLE OF sflight.

  SELECT *
    FROM sflight
    INTO TABLE @it_copy_sflight
    WHERE carrid IN @v_cid
      AND fldate IN @v_fldt.

  WRITE: / 'Voos Encontrados'.
  ULINE.
  PERFORM f_print_table USING it_copy_sflight.
  ULINE.

  LOOP AT it_copy_sflight ASSIGNING FIELD-SYMBOL(<it_line>).
    IF ( <it_line>-seatsmax * '0.6' ) > <it_line>-seatsocc.
      <it_line>-price =  <it_line>-price * '1.15'.
      APPEND <it_line> TO it_valid_sflight.
    ENDIF.
  ENDLOOP.


  WRITE: / 'Voos que tiveram o preço alterado:'.
  ULINE.
  PERFORM f_print_table USING it_valid_sflight.

  MODIFY sflight FROM TABLE it_valid_sflight.

END-OF-SELECTION.

  TYPES: t_tp_sflight TYPE TABLE OF sflight.
FORM f_print_table USING f_table TYPE t_tp_sflight.
  FIELD-SYMBOLS: <f_line> LIKE LINE OF f_table.
  LOOP AT f_table ASSIGNING <f_line>.
    WRITE: / <f_line>-carrid,
    <f_line>-connid,
    <f_line>-fldate,
    <f_line>-price,
    <f_line>-seatsmax,
    <f_line>-seatsocc.
  ENDLOOP.
ENDFORM.