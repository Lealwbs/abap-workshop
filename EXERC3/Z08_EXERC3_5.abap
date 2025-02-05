*&---------------------------------------------------------------------*
*& Report Z08_EXERC3_5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc3_5.

* Fazer um programa para calcular a “taxa de embarque variável” por companhia aérea;

DATA: tp_sy_datum TYPE sy-datum.

SELECTION-SCREEN BEGIN OF BLOCK b_parameters WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: v_date FOR tp_sy_datum OBLIGATORY.
  PARAMETERS: v_rvalue TYPE s_price OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b_parameters.

AT SELECTION-SCREEN.

  IF v_rvalue = 0.
    MESSAGE e018(z08). "Digite um valor positivo.
  ENDIF.

START-OF-SELECTION.

  TYPES: BEGIN OF tp_l_rateio_scarr,
           vtp_carrid        TYPE scarr-carrid,
           vtp_peso          TYPE i,
           vtp_valor_rateado TYPE s_price,
         END OF tp_l_rateio_scarr.

  DATA: it_rateio_scarr TYPE TABLE OF tp_l_rateio_scarr,
        v_peso_total    TYPE i,
        v_peso_local    TYPE i,
        v_peso_tmp      TYPE i.

  SORT it_rateio_scarr BY vtp_carrid ASCENDING.

  SELECT carrid
    FROM scarr
    INTO TABLE @it_rateio_scarr.

  LOOP AT it_rateio_scarr ASSIGNING FIELD-SYMBOL(<carr_line1>).

    CLEAR: v_peso_local.
    CLEAR: v_peso_tmp.

    SELECT COUNT( * )
    FROM sbook
    INTO @v_peso_tmp
    WHERE carrid = @<carr_line1>-vtp_carrid
      AND fldate IN @v_date
      AND fldate LIKE '____12__'
      AND fldate LIKE '____01__'
      AND fldate LIKE '____07__'.

    v_peso_local = 2 * v_peso_tmp.
    CLEAR: v_peso_tmp.

    SELECT COUNT( * )
    FROM sbook
    INTO @v_peso_tmp
    WHERE carrid = @<carr_line1>-vtp_carrid
      AND fldate IN @v_date
      AND fldate NOT LIKE '____12__'
      AND fldate NOT LIKE '____01__'
      AND fldate NOT LIKE '____07__'.

    v_peso_local += v_peso_tmp.

    <carr_line1>-vtp_peso = v_peso_local.
    v_peso_total +=  v_peso_local.

  ENDLOOP.

  LOOP AT it_rateio_scarr ASSIGNING FIELD-SYMBOL(<carr_line2>).
    <carr_line2>-vtp_valor_rateado =  v_rvalue * <carr_line2>-vtp_peso / v_peso_total.
    WRITE: / <carr_line2>-vtp_carrid,
             ' | Peso: ', <carr_line2>-vtp_peso,
             ' | Valor Rateado: ', |{ <carr_line2>-vtp_valor_rateado }|.
  ENDLOOP.
  ULINE.

END-OF-SELECTION.

*  cl_demo_output=>display( it_rateio_scarr ).