*"* use this source file for your ABAP unit test classes
CLASS ltcl_ISANTOS_03_TEST_RELATORIO DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA: cut            TYPE REF TO zcl_isantos_03_test_relatorio,
          tipo_relatorio TYPE REF TO zif_isantos_03_tipo_relatorio.
    METHODS:
      setup,
      checa_conteudo_relatorio FOR TESTING,
      checa_conteudo_relatorio_novo FOR TESTING.
ENDCLASS.


CLASS ltcl_ISANTOS_03_TEST_RELATORIO IMPLEMENTATION.

  METHOD setup.

    tipo_relatorio ?= cl_abap_testdouble=>create( 'ZIF_ISANTOS_03_TIPO_RELATORIO' ).
    cut = NEW #(
    tipo_escolhido = tipo_relatorio ).
  ENDMETHOD.

  METHOD checa_conteudo_relatorio.
    DATA(resultado_relatorio) = cut->gerar_relatorio( modelo_novo = abap_false ).

    cl_abap_unit_assert=>assert_true(
      EXPORTING
        act = cut->relatorio_foi_gerado
    ).

    cl_abap_unit_assert=>assert_equals(
      EXPORTING
        act = resultado_relatorio
        exp = 'Meu relatorio de teste'
    ).
  ENDMETHOD.

  METHOD checa_conteudo_relatorio_novo.
    DATA(resultado_relatorio) = cut->gerar_relatorio( modelo_novo = abap_true ).

    cl_abap_unit_assert=>assert_true(
      EXPORTING
        act = cut->relatorio_foi_gerado
    ).

    cl_abap_unit_assert=>assert_equals(
      EXPORTING
        act = resultado_relatorio
        exp = 'Meu relatorio é top'
    ).
  ENDMETHOD.

ENDCLASS.