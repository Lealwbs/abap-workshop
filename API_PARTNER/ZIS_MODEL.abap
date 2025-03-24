CLASS zis_model DEFINITION PUBLIC.

  PUBLIC SECTION.

    DATA: struct TYPE zis_table_t READ-ONLY.

    METHODS:
      get_vcount RETURNING VALUE(result) TYPE zis_table_t-vcount,
      get_id     RETURNING VALUE(result) TYPE zis_table_t-id,
      set_vcount IMPORTING new_vcount    TYPE zis_table_t-vcount,
      set_id     IMPORTING new_id        TYPE zis_table_t-id.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS zis_model IMPLEMENTATION.

  METHOD get_vcount.
    result = me->struct-vcount.
  ENDMETHOD.

  METHOD get_id.
    result = me->struct-id.
  ENDMETHOD.

  METHOD set_vcount.
    me->struct-vcount = new_vcount.
  ENDMETHOD.

  METHOD set_id.
    me->struct-id = new_id.
  ENDMETHOD.

ENDCLASS.