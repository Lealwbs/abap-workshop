*&---------------------------------------------------------------------*
*& Report zis_api_program
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_api_program.

CLASS lcl_main DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.

    DATA: string_utils TYPE REF TO /s4tax/string_utils.

    METHODS:
      run,
      write_response      IMPORTING response        TYPE /s4tax/s_search_partner_o,

      process_bad_request IMPORTING errors          TYPE /s4tax/s_default_error
                          RETURNING VALUE(msg_erro) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_main IMPLEMENTATION.

  METHOD run.

    DATA: api_is       TYPE REF TO zis_iapi_partner,
          api_response TYPE /s4tax/s_search_partner_o.

      DATA: partner_id TYPE string VALUE '8c8ff9e0-3811-48a1-bb86-6d6a53d6b0f3'.
"     DATA: partner_id TYPE string VALUE '00000'.

    TRY.
        api_is = zis_api_partner=>get_instance(  ).

        IF api_is IS NOT BOUND.  "BOUND = Está preenchido, NOT BOUND = Não está preenchido.
          WRITE: / 'ERROR: API_IS was not initialized'.
        ENDIF.

        api_response = api_is->search_partner( EXPORTING partner_id = partner_id ).

      CATCH /s4tax/cx_http /s4tax/cx_auth.
        WRITE: / 'ERROR: API was not called'.
    ENDTRY.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " SAVE RESPONSE
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    DATA: obj_dao    TYPE REF TO zis_dao,
          obj_bo     TYPE REF TO zis_bo,
          error_table TYPE /s4tax/s_default_error,
          body       TYPE zis_table_t-id,
          msg_error  TYPE string.

    IF api_response IS INITIAL.
      api_is->change_response_for_error( CHANGING response_data = error_table ).
      body = process_bad_request( error_table ).
      WRITE: / 'ERROR: ', body.
    ELSE.
      body =  api_response-data-id.
      write_response( api_response ).
    ENDIF.

    DATA: last_id TYPE int1.

*    CLEAR zis_table_t "Limpar a tabela toda vez que tiver cheia

    SELECT COUNT(*)
    INTO last_id
    FROM zis_table_t.

    CREATE OBJECT obj_dao.
    CREATE OBJECT obj_bo
      EXPORTING
        iv_vcount = last_id + 1
        iv_id     = body.

    obj_dao->zis_idao~save( obj = obj_bo ).

  ENDMETHOD.

  METHOD write_response.

    IF response IS INITIAL.
      WRITE: / 'ERROR: Result is empty'.
      RETURN.
    ENDIF.

    WRITE: response-data-id,
           response-data-name,
           response-data-fantasy_name,
           response-data-birth_date,
           response-data-partner_type,
           response-data-created_at,
           response-data-updated_at.
*    addresses    : /s4tax/s_addresses;
*    fiscal_ids   : /s4tax/s_fiscal_ids;
*    contacts     : /s4tax/s_contacts;

  ENDMETHOD.

  METHOD process_bad_request.

    DATA: msg   TYPE string.
    CREATE OBJECT string_utils.

    IF errors IS INITIAL.
      RETURN.
    ENDIF.

    msg = me->string_utils->concatenate( msg1 = 'Error '
                                         msg2 = errors-code
                                         msg3 = errors-message ).
    msg_erro = msg.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  DATA: main TYPE REF TO lcl_main.
  CREATE OBJECT main.
  main->run( ).