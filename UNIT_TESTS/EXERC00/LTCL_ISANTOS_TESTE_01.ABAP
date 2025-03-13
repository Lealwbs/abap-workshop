*"* use this source file for your ABAP unit test classes
CLASS ltcl_isantos_teste_01 DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      somar_2_mais_2 FOR TESTING.

ENDCLASS.


CLASS ltcl_isantos_teste_01 IMPLEMENTATION.

  METHOD somar_2_mais_2.

    DATA: obj TYPE REF TO zcl_isantos_teste_01.
    CREATE OBJECT obj.

    DATA: resultado type i.

    resultado = obj->somar( num1 = 2 num2 = 2 ).

    cl_abap_unit_assert=>assert_equals(
    exporting
    act = resultado
    exp = 4
    ).

  ENDMETHOD.

ENDCLASS.