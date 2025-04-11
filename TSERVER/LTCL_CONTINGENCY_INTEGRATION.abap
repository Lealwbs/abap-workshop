CLASS ltcl_contingency_integration DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CLASS-DATA: db_mock TYPE REF TO if_osql_test_environment.

    DATA: cut                TYPE REF TO /s4tax/contingency_integration,
          branch_info        TYPE j_1bnfe_branch_info,

          server_check_nfe_t TYPE /s4tax/contingency_integration=>tt_nfe_server_check,
          server_check_dfe_t TYPE /s4tax/contingency_integration=>tt_dfe_server_check,

          mock_dao_document  TYPE REF TO /s4tax/dao_document,
          mock_dao_dfe_cfg   TYPE REF TO /s4tax/dao_dfe_cfg,
          mock_dfe_cfg       TYPE REF TO /s4tax/document_config,
          mock_dfe_cfg_t     TYPE /s4tax/document_config_t.

    CLASS-METHODS: class_setup, class_teardown.
    METHODS: setup, teardown.

    METHODS:
      test_timestamp_cfg FOR TESTING,
      test_initialize_dao FOR TESTING,
      test_contingency_read FOR TESTING,
      test_read_dfe_cfg_list FOR TESTING,
      test_load_branch_information FOR TESTING,

      setup_run_for_tests, "Executa os métodos de inicialização e montagem para os testes funcionarem.

      test_nfe_active_server FOR TESTING,
      test_nfe_server_check FOR TESTING,
      test_nfe_integration FOR TESTING,

      test_dfe_active_server FOR TESTING,
      test_dfe_server_check FOR TESTING,
      test_dfe_integration FOR TESTING,

      test_main FOR TESTING.

ENDCLASS.


CLASS ltcl_contingency_integration IMPLEMENTATION.

  METHOD class_setup.
    db_mock = cl_osql_test_environment=>create(  i_dependency_list = VALUE #( ( '/S4TAX/TSERVER' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    db_mock->destroy(  ).
  ENDMETHOD.

  METHOD setup_run_for_tests.
    cut->initialize_dao( ).
    cut->read_dfe_cfg_list( ).
*    cut->load_branch_information( branch_info ).
*    cut->contingency_read( branch_info ).
*    cut->timestamp_cfg( ).
  ENDMETHOD.

  METHOD setup.

*    me->setup_run_for_tests( ).

    cut->initialize_dao( ).
    cut->read_dfe_cfg_list( ).

    cut = NEW /s4tax/contingency_integration( ).
    branch_info = VALUE #( bukrs = 'TEST_BUKRS'
                           branch = 'TEST_BRANCH'
                           model = '55'
                           regio = 'TEST_REGIO' ).


    DATA: tmp_cust3 TYPE j_1bnfe_cust3.
    tmp_cust3 = VALUE #( mandt      = '400'
                         bukrs      = '1234'
                         branch     = '5678'
                         model      = '90'
                         validfrom  = '12345678'
                         autoserver = 'X' ).
    cut->cust3 = tmp_cust3.

    DATA: tmp_branch TYPE REF TO /s4tax/branch,
          tmp_struct_branch TYPE j_1bbranch.

    tmp_struct_branch-bukrs = '4321'.
    tmp_struct_branch-branch = '8765'.
    tmp_struct_branch-bupla_type = '22'.

    CREATE OBJECT tmp_branch EXPORTING iw_struct = tmp_struct_branch.
    cut->branch = tmp_branch.

    "TODO: RESOLVER MOCKAGEM DO dao_branch"

    CREATE OBJECT mock_dao_document.
    CREATE OBJECT mock_dao_dfe_cfg.
    CREATE OBJECT mock_dfe_cfg.

    mock_dfe_cfg->set_status_update_time( '105523' ).
    INSERT mock_dfe_cfg INTO TABLE mock_dfe_cfg_t.

    cut->contingency_read( branch_info ).
    cut->timestamp_cfg( ).
  ENDMETHOD.

  METHOD teardown.
    CLEAR: cut, branch_info, mock_dao_document, mock_dao_dfe_cfg, mock_dfe_cfg_t.
  ENDMETHOD.

  METHOD test_initialize_dao.
    cut->dao_document = mock_dao_document.
    cut->initialize_dao( ).
    cl_abap_unit_assert=>assert_bound( cut->dao_document ).
    cl_abap_unit_assert=>assert_bound( cut->dao_dfe_cfg ).
  ENDMETHOD.

  METHOD test_read_dfe_cfg_list.
*    cut->initialize_dao( ).

    cut->dao_dfe_cfg = mock_dao_dfe_cfg.
    cut->dfe_cfg_list = mock_dfe_cfg_t.
    cut->read_dfe_cfg_list( ).
    cl_abap_unit_assert=>assert_bound( cut->dfe_cfg ).
  ENDMETHOD.

  METHOD test_load_branch_information.
*    cut->initialize_dao( ).
*    cut->read_dfe_cfg_list( ).

    cut->dao_document = mock_dao_document.
    cut->load_branch_information( branch_info ).
    cl_abap_unit_assert=>assert_bound( cut->branch ).
    cl_abap_unit_assert=>assert_bound( cut->branch_address ).
  ENDMETHOD.

  METHOD test_contingency_read.
*    cut->initialize_dao( ).
*    cut->read_dfe_cfg_list( ).
*    cut->load_branch_information( branch_info ).

    cut->branch_address = NEW /s4tax/address( ).
    cut->contingency_read( branch_info ).
    cl_abap_unit_assert=>assert_not_initial( cut->ls_set_cont ).
  ENDMETHOD.

  METHOD test_timestamp_cfg.
*    cut->initialize_dao( ).
*    cut->read_dfe_cfg_list( ).
*    cut->load_branch_information( branch_info ).
*    cut->contingency_read( branch_info ).

    cut->timestamp_cfg( ).
    cl_abap_unit_assert=>assert_not_initial( cut->timestamp_now ).
    cl_abap_unit_assert=>assert_not_initial( cut->timestamp_server ).
  ENDMETHOD.

  METHOD test_nfe_server_check.
*    me->setup_run_for_tests( ).

    cl_abap_unit_assert=>assert_initial( cut->server_check_nfe-tpamb ).

    cut->nfe_server_check( branch_info ).

    cl_abap_unit_assert=>assert_not_initial( cut->server_check_nfe-tpamb ).
  ENDMETHOD.

  METHOD test_nfe_active_server.
*    me->setup_run_for_tests( ).

    cl_abap_unit_assert=>assert_initial( server_check_nfe_t ).

    cut->server = NEW /s4tax/server( ).
    cut->server->set_active_server( 'SVC' ).
    cut->nfe_active_server( CHANGING server_check_nfe_t = server_check_nfe_t ).

    cl_abap_unit_assert=>assert_not_initial( server_check_nfe_t ).
  ENDMETHOD.

  METHOD test_nfe_integration.
*    me->setup_run_for_tests( ).

    cl_abap_unit_assert=>assert_initial( cut->contingency_date ).

    cut->nfe_integration( branch_info ).

    cl_abap_unit_assert=>assert_not_initial( cut->contingency_date ).
  ENDMETHOD.

  METHOD test_dfe_server_check.
*    me->setup_run_for_tests( ).

    cl_abap_unit_assert=>assert_initial( cut->server_check_dfe-tpamb ).

    branch_info-model = '57'.
    cut->dfe_server_check( branch_info ).

    cl_abap_unit_assert=>assert_not_initial( cut->server_check_dfe-tpamb ).
  ENDMETHOD.

  METHOD test_dfe_active_server.
*    me->setup_run_for_tests( ).

    cl_abap_unit_assert=>assert_initial( server_check_dfe_t ).

    cut->server = NEW /s4tax/server( ).
    cut->server->set_active_server( 'SVC' ).
    cut->dfe_active_server( CHANGING server_check_dfe_t = server_check_dfe_t ).

    cl_abap_unit_assert=>assert_not_initial( server_check_dfe_t ).
  ENDMETHOD.

  METHOD test_dfe_integration.
*    me->setup_run_for_tests( ).

    cl_abap_unit_assert=>assert_initial( cut->contingency_date ).

    branch_info-model = '57'.
    cut->dfe_integration( branch_info ).

    cl_abap_unit_assert=>assert_not_initial( cut->contingency_date ).
  ENDMETHOD.

  METHOD test_main.
    cut->main( EXPORTING is_branch_info     = branch_info
               IMPORTING server_check_nfe_t = server_check_nfe_t ).
    cl_abap_unit_assert=>assert_not_initial( server_check_nfe_t ).

    branch_info-model = '57'.
    cut->main( EXPORTING is_branch_info     = branch_info
               IMPORTING server_check_dfe_t = server_check_dfe_t ).
    cl_abap_unit_assert=>assert_not_initial( server_check_dfe_t ).
  ENDMETHOD.

ENDCLASS.