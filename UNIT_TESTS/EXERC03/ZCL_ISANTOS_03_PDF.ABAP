CLASS zcl_isantos_03_pdf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES: zif_isantos_03_tipo_relatorio.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_isantos_03_pdf IMPLEMENTATION.

  METHOD zif_isantos_03_tipo_relatorio~imprimir.
    WRITE: 'PDF'.
  ENDMETHOD.

ENDCLASS.