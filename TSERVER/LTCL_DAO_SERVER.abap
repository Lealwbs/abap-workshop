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
    db_mock = cl_osql_test_environment=>create(  i_dependency_list = VALUE #( ( '/S4TAX/TSERVER' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    db_mock->destroy(  ).
  ENDMETHOD.

  METHOD setup.
    cut = NEW #( ).
    CLEAR: test_data_t, test_data.

    test_data = VALUE #( regio = 'SP'
                         model = '02'
                         active_server = 'MAIN'
                         authorizer = '22'
                         environment_type = '2'
                         contingency_date = '20220317185825' ).

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
    expected_server->set_model( iv_model = '03' ).
    expected_server->set_active_server( iv_active_server = 'MAIN' ).
    expected_server->set_authorizer( iv_authorizer = '33' ).
    expected_server->set_environment_type( iv_environment_type = '3' ).
    expected_server->set_contingency_date( iv_contingency_date = '20230922123202' ).

    cut->/s4tax/idao_server~save( server = expected_server ).

    output_server = cut->/s4tax/idao_server~get( ).

    cl_abap_unit_assert=>assert_equals( act = output_server->get_regio( )            exp = expected_server->get_regio( ) ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_model( )            exp = expected_server->get_model( ) ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_active_server( )    exp = expected_server->get_active_server( ) ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_authorizer( )       exp = expected_server->get_authorizer( ) ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_contingency_date( ) exp = expected_server->get_contingency_date( ) ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_environment_type( ) exp = expected_server->get_environment_type( ) ).

  ENDMETHOD.


  METHOD delete_test.

    DATA: output_server   TYPE REF TO /s4tax/server.

    CREATE OBJECT output_server.

    output_server = cut->/s4tax/idao_server~get( ).

    cl_abap_unit_assert=>assert_bound( output_server ).
    cl_abap_unit_assert=>assert_not_initial( output_server ).
    cl_abap_unit_assert=>assert_equals( act = output_server->get_active_server(  ) exp = 'MAIN' ).

    cut->/s4tax/idao_server~delete( server_old = 'MAIN' ).

    CLEAR output_server.
    output_server = cut->/s4tax/idao_server~get( ).

    cl_abap_unit_assert=>assert_not_bound( output_server ).
    cl_abap_unit_assert=>assert_initial( output_server ).

  ENDMETHOD.

  METHOD struct_to_objects_test.

    DATA: struct  TYPE /s4tax/server_table_t,
          objects TYPE /s4tax/server_t.

    DATA: server_struct1 TYPE /s4tax/tserver,
          server_struct2 TYPE /s4tax/tserver.

    server_struct1-regio = 'BA'.
    server_struct1-model = '04'.
    server_struct1-active_server = 'MAIN'.
    server_struct1-authorizer = '44'.
    server_struct1-contingency_date = '20240124055655'.
    server_struct1-environment_type = '4'.
    APPEND server_struct1 TO struct.

    server_struct2-regio = 'ES'.
    server_struct2-model = '05'.
    server_struct2-active_server = 'MAIN'.
    server_struct2-authorizer = '55'.
    server_struct2-contingency_date = '20251016081640'.
    server_struct2-environment_type = '5'.
    APPEND server_struct2 TO struct.

    objects = cut->/s4tax/idao_server~struct_to_objects( server_table = struct ).

    cl_abap_unit_assert=>assert_equals( act = objects[ 1 ]->get_regio( )            exp = server_struct1-regio ).
    cl_abap_unit_assert=>assert_equals( act = objects[ 1 ]->get_model( )            exp = server_struct1-model ).
    cl_abap_unit_assert=>assert_equals( act = objects[ 1 ]->get_active_server( )    exp = server_struct1-active_server ).
    cl_abap_unit_assert=>assert_equals( act = objects[ 1 ]->get_authorizer( )       exp = server_struct1-authorizer ).
    cl_abap_unit_assert=>assert_equals( act = objects[ 1 ]->get_contingency_date( ) exp = server_struct1-contingency_date ).
    cl_abap_unit_assert=>assert_equals( act = objects[ 1 ]->get_environment_type( ) exp = server_struct1-environment_type ).

    cl_abap_unit_assert=>assert_equals( act = objects[ 2 ]->get_regio( )            exp = server_struct2-regio ).
    cl_abap_unit_assert=>assert_equals( act = objects[ 2 ]->get_model( )            exp = server_struct2-model ).
    cl_abap_unit_assert=>assert_equals( act = objects[ 2 ]->get_active_server( )    exp = server_struct2-active_server ).
    cl_abap_unit_assert=>assert_equals( act = objects[ 2 ]->get_authorizer( )       exp = server_struct2-authorizer ).
    cl_abap_unit_assert=>assert_equals( act = objects[ 2 ]->get_contingency_date( ) exp = server_struct2-contingency_date ).
    cl_abap_unit_assert=>assert_equals( act = objects[ 2 ]->get_environment_type( ) exp = server_struct2-environment_type ).

  ENDMETHOD.

  METHOD objects_to_struct_test.

    DATA: struct  TYPE /s4tax/server_table_t,
          objects TYPE /s4tax/server_t.

    DATA: server_obj1 TYPE REF TO /s4tax/server,
          server_obj2 TYPE REF TO /s4tax/server.

    CREATE: OBJECT server_obj1, OBJECT server_obj2.

    server_obj1->set_regio( iv_regio = 'BA' ).
    server_obj1->set_model( iv_model = '04' ).
    server_obj1->set_active_server( iv_active_server = 'MAIN' ).
    server_obj1->set_authorizer( iv_authorizer = '44' ).
    server_obj1->set_contingency_date( iv_contingency_date = '20240124055655' ).
    server_obj1->set_environment_type( iv_environment_type = '4' ).
    APPEND server_obj1 TO objects.

    server_obj2->set_regio( iv_regio = 'ES' ).
    server_obj2->set_model( iv_model = '05' ).
    server_obj2->set_active_server( iv_active_server = 'MAIN' ).
    server_obj2->set_authorizer( iv_authorizer = '55' ).
    server_obj2->set_contingency_date( iv_contingency_date = '20251016081640' ).
    server_obj2->set_environment_type( iv_environment_type = '5' ).
    APPEND server_obj2 TO objects.

    struct = cut->/s4tax/idao_server~objects_to_struct( server_list = objects ).

    cl_abap_unit_assert=>assert_equals( act = struct[ 1 ]-regio            exp = server_obj1->get_regio(  ) ).
    cl_abap_unit_assert=>assert_equals( act = struct[ 1 ]-model            exp = server_obj1->get_model(  ) ).
    cl_abap_unit_assert=>assert_equals( act = struct[ 1 ]-active_server    exp = server_obj1->get_active_server(  ) ).
    cl_abap_unit_assert=>assert_equals( act = struct[ 1 ]-authorizer       exp = server_obj1->get_authorizer(  ) ).
    cl_abap_unit_assert=>assert_equals( act = struct[ 1 ]-contingency_date exp = server_obj1->get_contingency_date(  ) ).
    cl_abap_unit_assert=>assert_equals( act = struct[ 1 ]-environment_type exp = server_obj1->get_environment_type(  ) ).

    cl_abap_unit_assert=>assert_equals( act = struct[ 2 ]-regio            exp = server_obj2->get_regio(  ) ).
    cl_abap_unit_assert=>assert_equals( act = struct[ 2 ]-model            exp = server_obj2->get_model(  ) ).
    cl_abap_unit_assert=>assert_equals( act = struct[ 2 ]-active_server    exp = server_obj2->get_active_server(  ) ).
    cl_abap_unit_assert=>assert_equals( act = struct[ 2 ]-authorizer       exp = server_obj2->get_authorizer(  ) ).
    cl_abap_unit_assert=>assert_equals( act = struct[ 2 ]-contingency_date exp = server_obj2->get_contingency_date(  ) ).
    cl_abap_unit_assert=>assert_equals( act = struct[ 2 ]-environment_type exp = server_obj2->get_environment_type(  ) ).

  ENDMETHOD.

ENDCLASS.