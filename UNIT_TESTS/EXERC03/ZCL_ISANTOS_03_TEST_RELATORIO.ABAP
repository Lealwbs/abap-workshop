CLASS zcl_isantos_03_test_relatorio DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: relatorio_foi_gerado TYPE abap_bool READ-ONLY.

    METHODS:
      constructor
        IMPORTING tipo_escolhido TYPE REF TO zif_isantos_03_tipo_relatorio,
      gerar_relatorio
        IMPORTING modelo_novo   TYPE abap_bool
        RETURNING VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: tipo_do_relatorio TYPE REF TO zif_isantos_03_tipo_relatorio.

ENDCLASS.

CLASS zcl_isantos_03_test_relatorio IMPLEMENTATION.

  METHOD constructor.
    me->tipo_do_relatorio    = tipo_escolhido.
    me->relatorio_foi_gerado = abap_false.
  ENDMETHOD.

  METHOD gerar_relatorio.

    DATA: conteudo TYPE string.

    IF modelo_novo EQ abap_true.
      conteudo = 'Meu relatorio é top'.
    ELSE.
      conteudo = 'Meu relatorio de teste'.
    ENDIF.

    tipo_do_relatorio->imprimir( conteudo ).
    me->relatorio_foi_gerado = abap_true.
    result = conteudo.

  ENDMETHOD.

ENDCLASS.