*&---------------------------------------------------------------------*
*& Report Z08_EXERC10_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc10_2.

DATA: tp_scarr_carrid TYPE scarr-carrid.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: v_carrid FOR tp_scarr_carrid.
SELECTION-SCREEN END OF BLOCK b_input.

TYPES: BEGIN OF tp_l_alv,
         vtp_carrid   TYPE scarr-carrid,
         vtp_carrname TYPE scarr-carrname,
         vtp_connid   TYPE sflight-connid,
         vtp_fldate   TYPE sflight-fldate,
         vtp_price    TYPE sflight-price,
         vtp_currency TYPE sflight-currency,
         vtp_seatsmax TYPE sflight-seatsmax,
       END OF tp_l_alv.

DATA: it_alv TYPE TABLE OF tp_l_alv,
      wa_alv TYPE tp_l_alv.

TYPES: BEGIN OF tp_color,
         row TYPE lvc_s_scol,
       END OF tp_color.

DATA: it_color TYPE TABLE OF tp_color,
      wa_color TYPE tp_color.

START-OF-SELECTION.


  SELECT scarr~carrid,
         scarr~carrname,
         sflight~connid,
         sflight~fldate,
         sflight~price,
         sflight~currency,
         sflight~seatsmax
  FROM scarr
  INNER JOIN sflight
          ON scarr~carrid = sflight~carrid
  INTO TABLE @it_alv
  WHERE scarr~carrid IN @v_carrid.

  SORT it_alv BY vtp_carrid vtp_price.

  LOOP AT it_alv INTO wa_alv.
    CLEAR wa_color.
    IF wa_alv-vtp_seatsmax >= 300.
       wa_color-row-fname = 'VTP_SEATSMAX'.
       wa_color-row-color-col = cl_gui_resources=>list_col_positive. " Verde
       wa_color-row-color-int = 1.
    ENDIF.
    APPEND wa_color TO it_color.
  ENDLOOP.

  " Declara variáveis para o ALV elaborado
  DATA: lo_table           TYPE REF TO cl_salv_table,
        lo_columns         TYPE REF TO cl_salv_columns_table,
        lo_display         TYPE REF TO cl_salv_display_settings,
        lo_functions       TYPE REF TO cl_salv_functions_list,
        lo_layout_settings TYPE REF TO cl_salv_layout,
        ls_layout_key      TYPE salv_s_layout_key.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_table
                              CHANGING  t_table      = it_alv   ).

      lo_columns = lo_table->get_columns( ).

      lo_display = lo_table->get_display_settings( ).
      lo_display->set_striped_pattern( cl_salv_display_settings=>true ).

      lo_functions = lo_table->get_functions( ).
      lo_functions->set_all( ).

      lo_layout_settings = lo_table->get_layout( ).
      ls_layout_key-report = sy-repid.
      lo_layout_settings->set_key( ls_layout_key ).
      lo_layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ). " Permite salvar o layout

      lo_table->display( ).

    CATCH cx_salv_msg INTO DATA(lx_salv_error).
      WRITE: / 'Erro:', lx_salv_error->get_text( ).
  ENDTRY.