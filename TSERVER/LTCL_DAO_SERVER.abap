*"* use this source file for your ABAP unit test classes
CLASS ltcl_dao_server DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CLASS-DATA: db_mock     TYPE REF TO if_osql_test_environment,
                test_data_t TYPE TABLE OF /s4tax/tserver,
                test_data   TYPE /s4tax/tserver.

    DATA: cut TYPE REF TO /s4tax/dao_server.

    CLASS-METHODS: class_setup, class_teardown.

    METHODS: setup, teardown,
      get_test FOR TESTING RAISING cx_static_check,
      save_test FOR TESTING RAISING cx_static_check,
      delete_test FOR TESTING RAISING cx_static_check,
      struct_to_objects_test FOR TESTING RAISING cx_static_check,
      objects_to_struct_test FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_dao_server IMPLEMENTATION.

  METHOD class_setup.
    db_mock = cl_osql_test_environment=>create(  i_dependency_list = VALUE #(  ( '/S4TAX/TSERVER' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    db_mock->destroy(  ).
  ENDMETHOD.

  METHOD setup.

    cut = NEW #( ).

    test_data = VALUE #( regio = 'SP'
                         model = '01'
                         active_server = 'MAIN'
                         authorizer = '35'
                         environment_type = '2'
                         contingency_date = '20250317185825' ).

    APPEND test_data TO test_data_t.
    db_mock->insert_test_data( test_data_t ).

  ENDMETHOD.

  METHOD teardown.
    db_mock->clear_doubles(  ).
    CLEAR test_data_t.
  ENDMETHOD.


  METHOD get_test.

    DATA: output_server TYPE REF TO /s4tax/server.
    CREATE OBJECT output_server.
    output_server = cut->/s4tax/idao_server~get( ).

    cl_abap_unit_assert=>assert_bound( output_server ).
    cl_abap_unit_assert=>assert_not_initial( output_server ).
    cl_abap_unit_assert=>assert_equals( exp = test_data-regio            act = output_server->get_regio( ) ).
    cl_abap_unit_assert=>assert_equals( exp = test_data-model            act = output_server->get_model( ) ).
    cl_abap_unit_assert=>assert_equals( exp = test_data-active_server    act = output_server->get_active_server( ) ).
    cl_abap_unit_assert=>assert_equals( exp = test_data-authorizer       act = output_server->get_authorizer( ) ).
    cl_abap_unit_assert=>assert_equals( exp = test_data-contingency_date act = output_server->get_contingency_date( ) ).
    cl_abap_unit_assert=>assert_equals( exp = test_data-environment_type act = output_server->get_environment_type( ) ).

  ENDMETHOD.


  METHOD save_test.

    DATA: expected_server TYPE REF TO /s4tax/server,
          output_server   TYPE REF TO /s4tax/server.

    CREATE: OBJECT expected_server, OBJECT output_server.

    expected_server->set_regio( iv_regio = 'MG' ).
    expected_server->set_model( iv_model = '02' ).
    expected_server->set_active_server( iv_active_server = 'MAIN' ).
    expected_server->set_authorizer( iv_authorizer = '54' ).
    expected_server->set_environment_type( iv_environment_type = '3' ).
    expected_server->set_contingency_date( iv_contingency_date = '20240922123202' ).

    cut->/s4tax/idao_server~save( server = expected_server ).

    output_server = cut->/s4tax/idao_server~get( ).

    cl_abap_unit_assert=>assert_equals( act = output_server->get_regio( )            exp = expected_server->get_regio( ) ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_model( )            exp = expected_server->get_model( ) ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_active_server( )    exp = expected_server->get_active_server( ) ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_authorizer( )       exp = expected_server->get_authorizer( ) ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_contingency_date( ) exp = expected_server->get_contingency_date( ) ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_environment_type( ) exp = expected_server->get_environment_type( ) ).

  ENDMETHOD.


  METHOD delete_test. "delete IMPORTING server_old TYPE /s4tax/active_server,
    "cl_abap_unit_assert=>fail( 'Implement your first test here' ).
  ENDMETHOD.

  METHOD struct_to_objects_test.

    "  struct_to_objects IMPORTING server_table  TYPE /s4tax/server_table_t
    " RETURNING VALUE(result) TYPE /s4tax/server_t,
    "cl_abap_unit_assert=>fail( 'Implement your first test here' ).
  ENDMETHOD.

  METHOD objects_to_struct_test.
    "cl_abap_unit_assert=>fail( 'Implement your first test here' ).

*    objects_to_struct IMPORTING server_list   TYPE /s4tax/server_t
*                      RETURNING VALUE(result) TYPE /s4tax/server_table_t.
  ENDMETHOD.

ENDCLASS.