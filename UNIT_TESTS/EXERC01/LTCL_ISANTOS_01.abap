*"* use this source file for your ABAP unit test classes
CLASS ltcl_isantos_exerc01 DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      check_itable FOR TESTING.
ENDCLASS.


CLASS ltcl_isantos_exerc01 IMPLEMENTATION.

  METHOD check_itable.

    DATA(obj) = NEW zcl_isantos_exerc01( ).
    obj->fillup_table( userid = 1   firstname = 'pedro'  lastname = 'pereira').
    obj->fillup_table( userid = 023 firstname = 'maria'  lastname = 'mendes' ).
    obj->fillup_table( userid = 999 firstname = 'carlos' lastname = 'cabrito').

    cl_abap_unit_assert=>assert_number_between(
      number = lines( obj->it_table )
      lower  = 2
      upper  = 100000000
      msg    = 'A tabela interna possui menos que 2 registros' ).

  ENDMETHOD.

ENDCLASS.

