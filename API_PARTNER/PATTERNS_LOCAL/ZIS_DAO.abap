CLASS zis_dao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES: zis_idao.
    CLASS-DATA: vcount   TYPE zis_table_t.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zis_dao IMPLEMENTATION.
  .
  METHOD zis_idao~save.

    IF obj IS BOUND.
      MODIFY zis_table_t FROM obj->struct.
    ENDIF.

  ENDMETHOD.

  METHOD zis_idao~get.

    DATA: document TYPE zis_table_t.

    IF vcount IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE *
    FROM zis_table_t
    INTO @document
    WHERE vcount = @vcount.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    CREATE OBJECT result
      EXPORTING
        iv_vcount = document-vcount
        iv_id     = document-id.

  ENDMETHOD.

ENDCLASS.