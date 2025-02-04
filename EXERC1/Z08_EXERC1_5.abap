*&---------------------------------------------------------------------*
*& Report Z08_EXERC1_5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc1_5.

DATA: v_dt_hoje      TYPE sy-datum,
      v_ano_ini      TYPE i,
      v_dia_temp(2)  TYPE c,
      v_mes_temp(10) TYPE c,
      v_ano_temp(4)  TYPE c,
      v_dias_no_mes  TYPE i,
      v_data_temp    TYPE sy-datum.

SELECTION-SCREEN BEGIN OF BLOCK datas WITH FRAME TITLE TEXT-001.
  PARAMETERS: v_dt_ini TYPE sy-datum OBLIGATORY,
              v_dt_fim TYPE sy-datum.
SELECTION-SCREEN END OF BLOCK datas.

SELECTION-SCREEN BEGIN OF BLOCK radios WITH FRAME TITLE TEXT-002.
  PARAMETERS:
    v_radio1 RADIOBUTTON GROUP rdgp DEFAULT 'X',
    v_radio2 RADIOBUTTON GROUP rdgp,
    v_radio3 RADIOBUTTON GROUP rdgp,
    v_check1 AS CHECKBOX,
    v_check2 AS CHECKBOX,
    v_check3 AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK radios.

INITIALIZATION.
  v_dt_hoje = sy-datum.
  v_dt_ini = v_dt_hoje - 366.

AT SELECTION-SCREEN.

  IF v_dt_fim > v_dt_hoje.
    MESSAGE e004(z08) WITH v_dt_fim v_dt_hoje.
  ENDIF.

  IF v_dt_fim <= v_dt_ini AND v_dt_fim <> '00000000'.
    MESSAGE e005(z08) WITH v_dt_fim v_dt_ini.
  ENDIF.

  IF v_check1 = ' ' AND v_check2 = ' '.
    MESSAGE e006(z08).
  ENDIF.

START-OF-SELECTION.

FORM retornar_data
  USING lv_data_input     TYPE sy-datum
        lv_type_out       TYPE i

  CHANGING lv_dia_output  TYPE c
           lv_mes_output  TYPE c
           lv_ano_output  TYPE c.

  lv_ano_output = lv_data_input+0(4).
  lv_dia_output = lv_data_input+6(2).

  CASE lv_data_input+4(2).
    WHEN '01'. lv_mes_output = 'janeiro'.
    WHEN '02'. lv_mes_output = 'feveiro'.
    WHEN '03'. lv_mes_output = 'março'.
    WHEN '04'. lv_mes_output = 'abril'.
    WHEN '05'. lv_mes_output = 'maio'.
    WHEN '06'. lv_mes_output = 'junho'.
    WHEN '07'. lv_mes_output = 'julho'.
    WHEN '08'. lv_mes_output = 'agosto'.
    WHEN '09'. lv_mes_output = 'setembro'.
    WHEN '10'. lv_mes_output = 'outubro'.
    WHEN '11'. lv_mes_output = 'novembro'.
    WHEN '12'. lv_mes_output = 'dezembro'.
  ENDCASE.

  IF lv_type_out = 1.
    lv_mes_output = to_upper( lv_mes_output+0(3) ).
  ENDIF.

  IF lv_type_out = 3.
    lv_mes_output = lv_mes_output+0(3).
  ENDIF.

ENDFORM.

END-OF-SELECTION.

  IF v_check1 = 'X'.

    IF v_radio1 = 'X'. " 01/JAN/2017
      PERFORM retornar_data USING v_dt_ini 1 CHANGING v_dia_temp v_mes_temp v_ano_temp.
*      WRITE: / 'Início:', v_dia_temp, '/', v_mes_temp, '/', v_ano_temp.
      WRITE: / |Início: { v_dia_temp }/{ v_mes_temp }/{ v_ano_temp }.|.
      IF v_dt_fim <> '00000000'.
        PERFORM retornar_data USING v_dt_fim 1 CHANGING v_dia_temp v_mes_temp v_ano_temp.
*        WRITE: / 'Término:', v_dia_temp, '/', v_mes_temp, '/', v_ano_temp.
        WRITE: / |Término: { v_dia_temp }/{ v_mes_temp }/{ v_ano_temp }.|.
      ENDIF.

    ELSEIF v_radio2 = 'X'. " 01 de Janeiro de 2017
      PERFORM retornar_data USING v_dt_ini 2 CHANGING v_dia_temp v_mes_temp v_ano_temp.
*      WRITE: / 'Início:', v_dia_temp, 'de', v_mes_temp, 'de', v_ano_temp.
      WRITE: / |Início: { v_dia_temp } de { v_mes_temp } de { v_ano_temp }.|.
      IF v_dt_fim <> '00000000'.
        PERFORM retornar_data USING v_dt_fim 2 CHANGING v_dia_temp v_mes_temp v_ano_temp.
*        WRITE: / 'Término:', v_dia_temp, 'de', v_mes_temp, 'de', v_ano_temp.
        WRITE: / |Término: { v_dia_temp } de { v_mes_temp } de { v_ano_temp }.|.
      ENDIF.

    ELSEIF v_radio3 = 'X'. " 01-jan-2017
      PERFORM retornar_data USING v_dt_ini 3 CHANGING v_dia_temp v_mes_temp v_ano_temp.
      WRITE: / |Início: { v_dia_temp }-{ v_mes_temp }-{ v_ano_temp }.|.
      IF v_dt_fim <> '00000000'.
        PERFORM retornar_data USING v_dt_fim 3 CHANGING v_dia_temp v_mes_temp v_ano_temp.
        WRITE: / |Término: { v_dia_temp }-{ v_mes_temp }-{ v_ano_temp }.|.
      ENDIF.
    ENDIF.

  ENDIF.

  v_ano_ini = v_dt_ini+0(4).

  IF v_check2 = 'X'.

    v_data_temp = v_dt_ini.
    v_data_temp+6(2) = '01'.

    DO 12 TIMES.

      v_data_temp+4(2) = sy-index.

      CASE v_data_temp+4(2).
        WHEN '1'. v_dias_no_mes = 31.
        WHEN '2'.
          IF v_ano_ini MOD 4 = 0 AND v_ano_ini MOD 100 <> 0.
            v_dias_no_mes = 29.
          ELSE.
            v_dias_no_mes = 28.
          ENDIF.
        WHEN '3'. v_dias_no_mes = 31.
        WHEN '4'. v_dias_no_mes = 30.
        WHEN '5'. v_dias_no_mes = 31.
        WHEN '6'. v_dias_no_mes = 30.
        WHEN '7'. v_dias_no_mes = 31.
        WHEN '8'. v_dias_no_mes = 31.
        WHEN '9'. v_dias_no_mes = 30.
        WHEN '10'. v_dias_no_mes = 31.
        WHEN '11'. v_dias_no_mes = 30.
        WHEN '12'. v_dias_no_mes = 31.
      ENDCASE.

      PERFORM retornar_data USING v_data_temp 2 CHANGING v_dia_temp v_mes_temp v_ano_temp.

      DO v_dias_no_mes TIMES.
        WRITE: / |{ sy-index } de { v_mes_temp } de { v_ano_temp }.|.
*        WRITE: / sy-index, 'de' , v_mes_temp, 'de', v_ano_temp.
      ENDDO.

      IF sy-index <> '12'.
        WRITE: /.
      ENDIF.

    ENDDO.
  ENDIF.

  IF v_check3 = 'X'.
    IF v_ano_ini MOD 4 = 0 AND v_ano_ini MOD 100 <> 0.
      WRITE: /, / |{ v_dt_ini+0(4) } é ano bissexto.|.
    ENDIF.
  ENDIF.