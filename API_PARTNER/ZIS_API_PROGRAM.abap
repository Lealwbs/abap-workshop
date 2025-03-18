*&---------------------------------------------------------------------*
*& Report zis_api_program
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_api_program.

CLASS lcl_main DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS: run.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_main IMPLEMENTATION.

  METHOD run.

    DATA: api_is TYPE REF TO zis_iapi_partner.

*   DATA: partner_id TYPE string VALUE '172c4ad5-8924-44e1-a726-7b484d20e7f2',
    DATA: partner_id TYPE string VALUE '8126317f-f046-45fe-b40f-a25cf73e2ace',
          result     TYPE /s4tax/s_search_partner_o.

    TRY.
        api_is = zis_api_partner=>get_instance(  ).
      CATCH /s4tax/cx_http /s4tax/cx_auth.
        " Handle Exception
    ENDTRY.

    api_is->search_partner(
      EXPORTING
        partner_id = partner_id
      RECEIVING
        result     = result
    ).

    WRITE: result-data-name.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  DATA: main TYPE REF TO lcl_main.

  CREATE OBJECT main.

  main->run( ).