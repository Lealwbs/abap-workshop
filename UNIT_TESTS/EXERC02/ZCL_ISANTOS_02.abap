CLASS zcl_isantos_ex02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS:
      dividir
        IMPORTING num1             TYPE i
                  num2             TYPE i
        RETURNING VALUE(resultado) TYPE i.

ENDCLASS.

CLASS zcl_isantos_ex02 IMPLEMENTATION.

  METHOD dividir.

    resultado = num1 / num2.

  ENDMETHOD.

ENDCLASS.

