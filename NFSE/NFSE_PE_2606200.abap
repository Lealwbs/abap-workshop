CLASS /s4tax/nfse_pe2606200 DEFINITION
  PUBLIC
  INHERITING FROM /s4tax/nfse_default
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS tax_address TYPE string VALUE 'PE 2606200'.

    METHODS: get_rps_identificacao REDEFINITION,
      /s4tax/infse_data~get_reasons_cancellation REDEFINITION.


  PROTECTED SECTION.
    METHODS: sum_nfse_tax_values REDEFINITION.

  PRIVATE SECTION.
ENDCLASS.



CLASS /s4tax/nfse_pe2606200 IMPLEMENTATION.

  METHOD get_rps_identificacao.
    DATA: date TYPE REF TO /s4tax/date.

    result = super->get_rps_identificacao( ).
    result-regime_especial_tributacao = reg_espec_trib_letter_to_numb( result-regime_especial_tributacao ).

    result-tipo_rps = '1'.

    IF result-serie IS INITIAL.
      result-serie = 'NF'.
    ENDIF.

    CREATE OBJECT date EXPORTING date = doc->struct-docdat.
    IF date IS BOUND.
      result-competencia = date->to_iso_format( ).
    ENDIF.
  ENDMETHOD.


  METHOD sum_nfse_tax_values.
    result = super->sum_nfse_tax_values( tax_values = tax_values ).
    result = get_rate_in_decimals( tax_values_sum = result ).
  ENDMETHOD.

  METHOD /s4tax/infse_data~get_reasons_cancellation.
    result-motivo = 'Servico nao prestado'.
    result-code = '2'.
  ENDMETHOD.
ENDCLASS.