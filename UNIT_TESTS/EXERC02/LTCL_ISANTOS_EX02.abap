"* use this source file for your ABAP unit test classes

CLASS ltcl_isantos_calculadora DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CLASS-METHODS: class_setup, class_teardown.
    CLASS-DATA: sut TYPE REF TO zcl_isantos_ex02.

    METHODS:
      verificar_divisao_comum FOR TESTING,
      verificar_divisao_por_zero FOR TESTING.

ENDCLASS.


CLASS ltcl_isantos_calculadora IMPLEMENTATION.

  METHOD class_setup.    CREATE OBJECT sut. ENDMETHOD.
  METHOD class_teardown. FREE: sut.         ENDMETHOD.

  METHOD verificar_divisao_comum.

    DATA: mensagem TYPE string.
    DATA: resultado TYPE i.

    resultado = sut->dividir( num1 = 2 num2 = 0 ).

    cl_abap_unit_assert=>assert_equals(
      msg = mensagem
      act = resultado
      exp = 2
    ).

  ENDMETHOD.

  METHOD verificar_divisao_por_zero.
*    TRY.
*        sut->dividir(
*          EXPORTING
*            num1 = 5
*            num2 = 0
*        ).
*        cl_abap_unit_assert=>fail( 'Deveria levantar uma exceção em uma divisão por zero' ).
*      CATCH cx_root INTO DATA(exception).
*
      ENDMETHOD.


ENDCLASS.



* Deve existir pelo menos 2 cenários:
* Divisão entre quaisquer dois número inteiros
* Divisão entre um número inteiro qualquer e zero!
* Obs: Utilizar os métodos especiais (setup, teardown), se necessário!