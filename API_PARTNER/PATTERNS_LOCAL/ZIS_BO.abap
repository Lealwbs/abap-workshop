CLASS zis_bo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  INHERITING FROM zis_model.

  PUBLIC SECTION.

    METHODS:
      constructor IMPORTING iv_vcount TYPE zis_table_t-vcount
                            iv_id     TYPE zis_table_t-id.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zis_bo IMPLEMENTATION.

  METHOD constructor.

    super->constructor( ).
    me->set_vcount(  iv_vcount ).
    me->set_id( iv_id ).

  ENDMETHOD.

ENDCLASS.