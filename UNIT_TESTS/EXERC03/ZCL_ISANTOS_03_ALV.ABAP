CLASS zcl_isantos_03_alv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES: zif_isantos_03_tipo_relatorio.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_isantos_03_alv IMPLEMENTATION.

  METHOD zif_isantos_03_tipo_relatorio~imprimir.
    WRITE: 'ALV'.
  ENDMETHOD.

ENDCLASS.