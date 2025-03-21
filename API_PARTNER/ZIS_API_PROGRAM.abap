*&---------------------------------------------------------------------*
*& Report zis_api_program
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_api_program.

CLASS lcl_main DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      run,
      write_response.

    CLASS-DATA:
      response TYPE /s4tax/s_search_partner_o.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_main IMPLEMENTATION.

  METHOD run.

    DATA: api_is TYPE REF TO zis_iapi_partner.

    DATA: partner_id TYPE string VALUE '2c2fff43-8cb7-4c3f-8060-f6f4f981e835'.

    TRY.
        api_is = zis_api_partner=>get_instance(  ).

        IF api_is IS NOT BOUND.
            WRITE: / 'ERROR: API_IS was not initialized'.
        ELSE.
            WRITE: / 'API_IS is Ok'.
        ENDIF.

        response = api_is->search_partner( EXPORTING partner_id = partner_id ).
        me->write_response(  ).

      CATCH /s4tax/cx_http /s4tax/cx_auth.
        WRITE: / 'ERROR: API was not called.'.
    ENDTRY.

  ENDMETHOD.

  METHOD write_response.

    IF response IS INITIAL.
      WRITE: / 'ERROR: Result is empty'.
      RETURN.
    ENDIF.

    WRITE: response-data-id-codigo,
           response-data-id-mensagem,
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

ENDCLASS.

START-OF-SELECTION.

  DATA: main TYPE REF TO lcl_main.

  CREATE OBJECT main.

  main->run( ).