*"* use this source file for your ABAP unit test classes
CLASS ltcl_zis_dao DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    TYPES: BEGIN OF s_table_t,
             mandt  TYPE mandt,
             vcount TYPE int1,
             id     TYPE char255,
           END OF s_table_t.

    CLASS-DATA:
      db_mock TYPE REF TO if_osql_test_environment,
      tt_data TYPE TABLE OF zis_table_t.

    DATA: cut TYPE REF TO zis_dao.

    CLASS-METHODS:
      class_setup,
      class_teardown.

    METHODS:
      setup, teardown,
      test_save FOR TESTING,
      test_get FOR TESTING.

ENDCLASS.

CLASS ltcl_zis_dao IMPLEMENTATION.

  METHOD class_setup.

    "DATA(db_mock) = cl_abap_testdouble=>create( 'zis_model' ).
    db_mock = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'ZIS_TABLE_T' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    db_mock->destroy(  ).
  ENDMETHOD.

  METHOD setup.
    cut = NEW #( ).

    tt_data = VALUE #(
    ( mandt = '400' vcount = 101 id = 'MSG_1' )
    ( mandt = '400' vcount = 102 id = 'MSG_2' )
    ( mandt = '400' vcount = 103 id = 'MSG_3' ) ).

    db_mock->insert_test_data( tt_data ).
  ENDMETHOD.

  METHOD teardown.
    db_mock->clear_doubles(  ).
  ENDMETHOD.

  METHOD test_save.

    DATA: object_to_save    TYPE REF TO zis_bo.

    CREATE OBJECT object_to_save
      EXPORTING
        iv_vcount = '150'
        iv_id     = 'MSG_50'.

    cut->zis_idao~save( obj = object_to_save ).

    DATA(result_obj) = cut->zis_idao~get( vcount = '150' ).

    cl_abap_unit_assert=>assert_equals( act = result_obj->get_vcount(  )
                                        exp = '150'
                                        msg = 'The vCount saved does not match with the expected.' ).

    cl_abap_unit_assert=>assert_equals( act = result_obj->get_id(  )
                                        exp = 'MSG_50'
                                        msg = 'The ID saved does not match with the expected.' ).

  ENDMETHOD.

  METHOD test_get.

    DATA: expected_obj TYPE REF TO zis_bo.

    CREATE OBJECT expected_obj
      EXPORTING
        iv_vcount = '102'
        iv_id     = 'MSG_2'.

    DATA(result_obj) = cut->zis_idao~get( vcount = '102' ).

    cl_abap_unit_assert=>assert_not_initial( act = result_obj ).

    cl_abap_unit_assert=>assert_equals( act = result_obj->struct-vcount
                                        exp = expected_obj->struct-vcount
                                        msg = 'O vcount retornado não confere.' ).

    cl_abap_unit_assert=>assert_equals( act = result_obj->struct-id
                                        exp = expected_obj->struct-id
                                        msg = 'O ID retornado não confere.' ).

  ENDMETHOD.

ENDCLASS.