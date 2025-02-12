*&---------------------------------------------------------------------*
*& Report Z08_EXERC10_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z08_exerc10_1.

DATA: tp_scustom_id TYPE scustom-id.

SELECTION-SCREEN BEGIN OF BLOCK b_input WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: v_custom FOR tp_scustom_id.
SELECTION-SCREEN END OF BLOCK b_input.

TYPES: BEGIN OF tp_l_alv,
         vtp_name       TYPE scustom-name,
         vtp_connid     TYPE sbook-connid,
         vtp_bookid     TYPE sbook-bookid,
         vtp_fldate     TYPE sbook-fldate,
         vtp_luggweight TYPE p LENGTH 15 DECIMALS 2, "sbook-luggweight dá estouro de campo
       END OF tp_l_alv.

DATA: it_alv  TYPE TABLE OF tp_l_alv,
      v_l_alv TYPE tp_l_alv,
      v_total TYPE p DECIMALS 2.

START-OF-SELECTION.

  SELECT scustom~name,
         sbook~connid,
         sbook~bookid,
         sbook~fldate,
         sbook~luggweight
  FROM scustom
  INNER JOIN sbook
          ON scustom~id = sbook~customID
  INTO TABLE @it_alv
  WHERE scustom~id IN @v_custom.
  DATA(v_id_operation) = sy-subrc.

  IF v_id_operation <> 0.
    WRITE: / 'Não foi possível executar a operação.'.
  ELSE.

*&---------------------------------------------------------------------*
*& PRIMEIRA FORMA
*&---------------------------------------------------------------------*
    v_total = 0.
    LOOP AT it_alv ASSIGNING FIELD-SYMBOL(<line>).
      v_total = v_total + <line>-vtp_luggweight.
    ENDLOOP.
    WRITE: / |Peso total da bagagem: { v_total }|.

*&---------------------------------------------------------------------*
*& SEGUNDA FORMA
*&---------------------------------------------------------------------*
    DATA: lt_result          TYPE TABLE OF stravelag,
          lo_table           TYPE REF TO   cl_salv_table,
          lo_columns         TYPE REF TO   cl_salv_columns_table,
          lo_column          TYPE REF TO   cl_salv_column,
          lo_display         TYPE REF TO   cl_salv_display_settings,
          lo_functions       TYPE REF TO   cl_salv_functions_list,
          lo_layout_settings TYPE REF TO   cl_salv_layout,
          ls_layout_key      TYPE          salv_s_layout_key.

    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = lo_table
                                CHANGING  t_table      = it_alv ).

        lo_columns = lo_table->get_columns( ).
        lo_columns->set_optimize( ).

        lo_functions = lo_table->get_functions( ).
        lo_functions->set_all( ).

        lo_display = lo_table->get_display_settings( ).

        ls_layout_key-report = sy-repid.

        lo_layout_settings = lo_table->get_layout( ).
        lo_layout_settings->set_key( ls_layout_key ).
        lo_layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).

        lo_column = lo_columns->get_column( 'VTP_LUGGWEIGHT' ).
        lo_column->set_long_text( |Peso da Bagagem| ).

        lo_table->display( ).

        lo_columns->get_column( 'VTP_LUGGWEIGHT' )->set_short_text( 'test1' ).

      CATCH cx_salv_msg        INTO DATA(lx_salv_error).
      CATCH cx_salv_existing   INTO DATA(lx_salv_existing).
      CATCH cx_salv_not_found  INTO DATA(lx_salv_notfound).
      CATCH cx_salv_data_error INTO DATA(lx_salv_dataerror).

    ENDTRY.

   ENDIF.