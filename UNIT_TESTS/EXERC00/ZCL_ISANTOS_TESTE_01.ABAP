CLASS zcl_isantos_teste_01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS:
      somar
        IMPORTING num1             TYPE i
                  num2             TYPE i
        RETURNING VALUE(resultado) TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_isantos_teste_01 IMPLEMENTATION.
  METHOD somar.
    resultado = num1 + num2.
  ENDMETHOD.
ENDCLASS.


