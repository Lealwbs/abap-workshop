CLASS zcl_isantos_exerc01 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF wa_table,
        userid    TYPE i,
        firstname TYPE string,
        lastname  TYPE string,
      END OF wa_table.

    DATA: it_table TYPE TABLE OF wa_table.

    METHODS:
      show_table,
      fillup_table
        IMPORTING userid      TYPE i
                  firstname   TYPE string
                  lastname    TYPE string
        RETURNING VALUE(num2) TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS zcl_isantos_exerc01 IMPLEMENTATION.

  METHOD show_table.
    cl_demo_output=>display( it_table ).
  ENDMETHOD.

  METHOD fillup_table.
    DATA: tmp_wa TYPE wa_table.
    CLEAR tmp_wa.
    tmp_wa-userid = userid.
    tmp_wa-firstname = firstname.
    tmp_wa-lastname = lastname.
    APPEND tmp_wa TO it_table.
  ENDMETHOD.

ENDCLASS.