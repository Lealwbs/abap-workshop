"* use this source file for your ABAP unit test classes

CLASS ltcl_isantos_calculadora DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    TYPES: BEGIN OF tp_testes,
             num1 TYPE i,
             num2 TYPE i,
             expt TYPE i,
           END OF tp_testes.

    DATA: testes TYPE STANDARD TABLE OF tp_testes,
          result TYPE i.

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

    CLEAR testes.
    APPEND VALUE #( num1 =  10 num2 =  2 expt =  5 ) TO testes.
    APPEND VALUE #( num1 =  64 num2 =  8 expt =  8 ) TO testes.
    APPEND VALUE #( num1 = -12 num2 =  6 expt = -2 ) TO testes.
    APPEND VALUE #( num1 =  25 num2 = -5 expt = -5 ) TO testes.
    APPEND VALUE #( num1 = 111 num2 = 37 expt =  3 ) TO testes.

    LOOP AT testes ASSIGNING FIELD-SYMBOL(<teste>).

      result = sut->dividir(
        num1 = <teste>-num1
        num2 = <teste>-num2 ).

      cl_abap_unit_assert=>assert_equals(
        msg = |EXPECTED { <teste>-expt } # GIVEN { result } FOR { <teste>-num1 } / { <teste>-num2 }.|
        act = result
        exp = <teste>-expt ).

    ENDLOOP.

  ENDMETHOD.

  METHOD verificar_divisao_por_zero.

    CLEAR testes.
    APPEND VALUE #( num1 = 10 num2 =  0 ) TO testes.
    APPEND VALUE #( num1 = -5 num2 =  0 ) TO testes.
    APPEND VALUE #( num1 =  1 num2 =  0 ) TO testes.

    LOOP AT testes ASSIGNING FIELD-SYMBOL(<teste>).

      TRY.
          result = sut->dividir(
            num1 = <teste>-num1
            num2 = <teste>-num2 ).

          cl_abap_unit_assert=>fail( |EXPECTED DIVIDE_BY_ZERO_EXCEPTION FOR { <teste>-num1 } / { <teste>-num2 }| ).

        CATCH cx_root INTO DATA(exception).

      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.