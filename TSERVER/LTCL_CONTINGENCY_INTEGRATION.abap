CLASS ltcl_contingency_integration DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CLASS-DATA: db_mock TYPE REF TO if_osql_test_environment.

    DATA: test_double         TYPE REF TO /s4tax/contingency_integration,
          mock_branch_info    TYPE j_1bnfe_branch_info,
          mock_cust3          TYPE j_1bnfe_cust3,
          mock_branch         TYPE REF TO /s4tax/branch,
          mock_branch_address TYPE REF TO /s4tax/address,
          branch_info         TYPE j_1bnfe_branch_info.

    DATA: cut                TYPE REF TO /s4tax/contingency_integration,

          server_check_nfe_t TYPE /s4tax/contingency_integration=>tt_nfe_server_check,
          server_check_dfe_t TYPE /s4tax/contingency_integration=>tt_dfe_server_check.


    CLASS-METHODS: class_setup, class_teardown.
    METHODS: setup, teardown.

    METHODS:
      test_load_branch_information FOR TESTING,
      test_contingency_read FOR TESTING,
      test_nfe_server_check FOR TESTING,
      test_dfe_server_check FOR TESTING,
      test_initialize_dao_and_server FOR TESTING,
      test_read_dfe_cfg_list FOR TESTING,
      test_timestamp_cfg FOR TESTING,
      test_nfe_active_server FOR TESTING,
      test_dfe_active_server FOR TESTING,
      test_nfe_integration FOR TESTING,
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

  METHOD setup.

    test_double ?= cl_abap_testdouble=>create( '/S4TAX/CONTINGENCY_INTEGRATION' ).
    cut = NEW #( cs_branch_info = mock_branch_info ).

    mock_branch_info = VALUE j_1bnfe_branch_info(  bukrs      = '1000'
                                                   branch     = '0001'
                                                   model      = '55'
                                                   regio      = 'MG'
                                                   rfcdest    = 'SAPCLNT100'
                                                   xnfeactive = 'X' ).
**
**    mock_cust32 = VALUE #( mandt      = '400'
**                          bukrs      = '1234'
**                          branch     = '5678'
**                          model      = '90'
**                          validfrom  = '12345678'
**                          autoserver = 'X' ).
*
**    mock_branch = NEW /s4tax/branch(
**      iw_struct = VALUE j_1bbranch( mandt = '400'
**                                    bukrs      = 'BR01'
**                                    branch     = '1000'
**                                    bupla_type = '01'
**                                    name       = 'Filial São Paulo' ) ).
*
*
*    "mock_branch_address = mock_branch->get_address( ).
*
*
*
*
*    cut->cust3 = mock_cust3.
*

*    cut->initialize_dao_and_server( ).
*    cut->read_dfe_cfg_list( ).
**    cut->load_branch_information( branch_info ).
**    cut->contingency_read( branch_info ).
**    cut->timestamp_cfg( ).


*    DATA: tmp_branch        TYPE REF TO /s4tax/branch,
*          tmp_struct_branch TYPE j_1bbranch.
*
*    tmp_struct_branch-bukrs = '4321'.
*    tmp_struct_branch-branch = '8765'.
*    tmp_struct_branch-bupla_type = '22'.

*    CREATE OBJECT tmp_branch EXPORTING iw_struct = tmp_struct_branch.
*    cut->branch = tmp_branch.

    "TODO: RESOLVER MOCKAGEM DO dao_branch"
*
*    mock_dfe_cfg->set_status_update_time( '105523' ).
*    INSERT mock_dfe_cfg INTO TABLE mock_dfe_cfg_t.

  ENDMETHOD.

  METHOD teardown.
    CLEAR: cut, branch_info, mock_branch_info, mock_cust3.
  ENDMETHOD.

  METHOD test_load_branch_information.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).

*    mock_cust3 = VALUE #( mandt      = '400'
*                          bukrs      = '1234'
*                          branch     = '5678'
*                          model      = '90'
*                          validfrom  = '12345678'
*                          autoserver = 'X' ).
*
*    cut->cust3 = mock_cust3.
*
*    mock_branch = NEW /s4tax/branch(
*      iw_struct = VALUE j_1bbranch( mandt = '400'
*                                    bukrs      = 'BR01'
*                                    branch     = '1000'
*                                    bupla_type = '01'
*                                    name       = 'Filial São Paulo' ) ).
*
*
*
*
*  DATA(mock_dao_branch) = cl_abap_testdouble=>create( '/S4TAX/IDAO_BRANCH' ).
*
*  cl_abap_testdouble=>configure_call( mock_dao_branch )->ignore_all_parameters( )->returning( mock_branch ).
*  mock_dao_brach->get( ).
*
*  cut->dao_branch = mock_dao_branch.
*
*
*    cut->load_branch_information( branch_info ).
**    cut->branch = mock_branch.
**    cut->branch_address = mock_branch_address.
*
*    cl_abap_unit_assert=>assert_bound( act = cut->branch
*                                       msg = 'MSG 1 BRANCH' ).
**    cl_abap_unit_assert=>assert_bound( act = cut->branch_address
*                                       msg = 'MSG 1 BRANCH ADDRESS ').
  ENDMETHOD.

  METHOD test_contingency_read.
    CREATE OBJECT cut->branch_address.

    cut->branch_address->set_land1( 'a' ).
    cut->branch_address->set_regio( 'a' ).
    cut->branch_info-bukrs = 'a'.
    cut->branch_info-branch = 'a'.
    cut->branch_info-model = 'a'.

    cl_abap_unit_assert=>assert_initial( cut->ls_set_cont ).


    DATA expected_set_cont TYPE j_1bnfe_contin.
    expected_set_cont-mandt       = '100'.      " Mandante SAP
    expected_set_cont-land1       = 'BR'.       " País - Brasil
    expected_set_cont-regio       = 'MG'.       " Região - Minas Gerais
    expected_set_cont-bukrs       = 'BR01'.     " Código da empresa
    expected_set_cont-branch      = '0001'.     " Código da filial
    expected_set_cont-model       = '55'.       " Modelo da nota fiscal eletrônica (ex: 55 = NF-e)
    expected_set_cont-contin_type = '01'.       " Tipo de contingência (ex: 01 = offline)

    DATA: dfe_std TYPE REF TO /s4tax/dfe_std.

    CREATE OBJECT cut->dfe_std.

    cut->contingency_read( is_branch_info = cut->branch_info
                           os_set_cont    = expected_set_cont ).

    cl_abap_unit_assert=>assert_not_initial( cut->ls_set_cont ).
  ENDMETHOD.

  METHOD test_nfe_server_check.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
**    me->setup_run_for_tests( ).
*
*    cl_abap_unit_assert=>assert_initial( cut->server_check_nfe-tpamb ).
*
*    cut->nfe_server_check( branch_info ).
*
*    cl_abap_unit_assert=>assert_not_initial( cut->server_check_nfe-tpamb ).
  ENDMETHOD.

  METHOD test_nfe_active_server.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
**    me->setup_run_for_tests( ).
*
*    cl_abap_unit_assert=>assert_initial( server_check_nfe_t ).
*
*    cut->server = NEW /s4tax/server( ).
*    cut->server->set_active_server( 'SVC' ).
*    cut->nfe_active_server( CHANGING server_check_nfe_t = server_check_nfe_t ).
*
*    cl_abap_unit_assert=>assert_not_initial( server_check_nfe_t ).
  ENDMETHOD.

  METHOD test_initialize_dao_and_server.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
*    cut->dao_document = mock_dao_document.
*    cut->initialize_dao_and_server( ).
*    cl_abap_unit_assert=>assert_bound( cut->dao_document ).
*    cl_abap_unit_assert=>assert_bound( cut->dao_dfe_cfg ).
  ENDMETHOD.

  METHOD test_read_dfe_cfg_list.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
**    cut->initialize_dao( ).
*
*    cut->dao_dfe_cfg = mock_dao_dfe_cfg.
*    cut->dfe_cfg_list = mock_dfe_cfg_t.
*    cut->read_dfe_cfg_list( ).
*    cl_abap_unit_assert=>assert_bound( cut->dfe_cfg ).
  ENDMETHOD.

  METHOD test_timestamp_cfg.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
**    cut->initialize_dao( ).
**    cut->read_dfe_cfg_list( ).
**    cut->load_branch_information( branch_info ).
**    cut->contingency_read( branch_info ).
*
*    cut->timestamp_cfg( ).
*    cl_abap_unit_assert=>assert_not_initial( cut->timestamp_now ).
*    cl_abap_unit_assert=>assert_not_initial( cut->timestamp_server ).
  ENDMETHOD.

  METHOD test_nfe_integration.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
**    me->setup_run_for_tests( ).
*
*    cl_abap_unit_assert=>assert_initial( cut->contingency_date ).
*
*    cut->nfe_integration( branch_info ).
*
*    cl_abap_unit_assert=>assert_not_initial( cut->contingency_date ).
  ENDMETHOD.

  METHOD test_dfe_server_check.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
**    me->setup_run_for_tests( ).
*
*    cl_abap_unit_assert=>assert_initial( cut->server_check_dfe-tpamb ).
*
*    branch_info-model = '57'.
*    cut->dfe_server_check( branch_info ).
*
*    cl_abap_unit_assert=>assert_not_initial( cut->server_check_dfe-tpamb ).
  ENDMETHOD.

  METHOD test_dfe_active_server.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
**    me->setup_run_for_tests( ).
*
*    cl_abap_unit_assert=>assert_initial( server_check_dfe_t ).
*
*    cut->server = NEW /s4tax/server( ).
*    cut->server->set_active_server( 'SVC' ).
*    cut->dfe_active_server( CHANGING server_check_dfe_t = server_check_dfe_t ).
*
*    cl_abap_unit_assert=>assert_not_initial( server_check_dfe_t ).
  ENDMETHOD.

  METHOD test_dfe_integration.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
**    me->setup_run_for_tests( ).
*
*    cl_abap_unit_assert=>assert_initial( cut->contingency_date ).
*
*    branch_info-model = '57'.
*    cut->dfe_integration( branch_info ).
*
*    cl_abap_unit_assert=>assert_not_initial( cut->contingency_date ).
  ENDMETHOD.

  METHOD test_main.
    cl_abap_unit_assert=>fail( msg = 'Needs implementation' level = if_abap_unit_constant=>severity-low ).
*    cut->main( EXPORTING is_branch_info     = mock_branch_info
*               IMPORTING server_check_nfe_t = server_check_nfe_t ).
*    cl_abap_unit_assert=>assert_not_initial( server_check_nfe_t ).
*
*    branch_info-model = '57'.
*    cut->main( EXPORTING is_branch_info     = mock_branch_info
*               IMPORTING server_check_dfe_t = server_check_dfe_t ).
*    cl_abap_unit_assert=>assert_not_initial( server_check_dfe_t ).
  ENDMETHOD.

ENDCLASS.